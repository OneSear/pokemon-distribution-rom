#!/usr/bin/env python3
"""Regenerate docs/screenshots/ by driving SameBoy headlessly.

SameBoy's desktop app can't be scripted (it wants a window, and on macOS the
screen-recording and Accessibility permissions besides), but its libretro
build is the same emulator as a plain shared library. So we talk to that
directly over ctypes: no window, no permissions, and the frames come straight
out of the core's framebuffer rather than off a screen.

Point SAMEBOY_CORE at the core if it isn't where RetroArch puts it, build the
ROM first, then:

    python3 docs/capture_screenshots.py

Stdlib only -- the PNG writer at the bottom is here so this needs no pip.
"""
import ctypes as C
import os
import struct
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)

CORE = os.environ.get("SAMEBOY_CORE", os.path.expanduser(
    "~/Library/Application Support/RetroArch/cores/sameboy_libretro.dylib"))
ROM = os.path.join(REPO, "pokemon_distribution.gb")
OUT = os.path.join(HERE, "screenshots")

# libretro joypad button ids
B, SELECT, START, UP, DOWN, LEFT, RIGHT, A = 0, 2, 3, 4, 5, 6, 7, 8
RETRO_DEVICE_JOYPAD = 1
RETRO_MEMORY_SYSTEM_RAM = 2

# Core options we care about. Everything else falls through to the core's own
# default (GET_VARIABLE returns false).  Force plain DMG: the ROM's CGB flag is
# $00 and its SGB flag is set, so "auto" would pick SGB and draw a border.
OPTIONS = {
    b"sameboy_model": b"Game Boy",
    b"sameboy_border": b"disabled",
    b"sameboy_color_correction_mode": b"off",
}

# --- callback prototypes -------------------------------------------------
ENV_T = C.CFUNCTYPE(C.c_bool, C.c_uint, C.c_void_p)
VIDEO_T = C.CFUNCTYPE(None, C.c_void_p, C.c_uint, C.c_uint, C.c_size_t)
AUDIO_T = C.CFUNCTYPE(None, C.c_int16, C.c_int16)
AUDIO_BATCH_T = C.CFUNCTYPE(C.c_size_t, C.c_void_p, C.c_size_t)
POLL_T = C.CFUNCTYPE(None)
INPUT_T = C.CFUNCTYPE(C.c_int16, C.c_uint, C.c_uint, C.c_uint, C.c_uint)


class GameInfo(C.Structure):
    _fields_ = [("path", C.c_char_p), ("data", C.c_void_p),
                ("size", C.c_size_t), ("meta", C.c_char_p)]


class Variable(C.Structure):
    _fields_ = [("key", C.c_char_p), ("value", C.c_char_p)]


class Emu:
    def __init__(self):
        self.core = C.CDLL(CORE)
        self.frame = None          # (bytes, w, h, pitch) of the last real frame
        self.buttons = set()
        self._sysdir = C.c_char_p(OUT.encode())

        # Keep strong refs: ctypes callbacks are garbage collected otherwise.
        self._env = ENV_T(self._environment)
        self._video = VIDEO_T(self._video_refresh)
        self._audio = AUDIO_T(lambda l, r: None)
        self._audio_batch = AUDIO_BATCH_T(lambda data, frames: frames)
        self._poll = POLL_T(lambda: None)
        self._input = INPUT_T(self._input_state)

        self.core.retro_set_environment(self._env)
        self.core.retro_set_video_refresh(self._video)
        self.core.retro_set_audio_sample(self._audio)
        self.core.retro_set_audio_sample_batch(self._audio_batch)
        self.core.retro_set_input_poll(self._poll)
        self.core.retro_set_input_state(self._input)
        self.core.retro_init()

    # --- libretro callbacks ---
    def _environment(self, cmd, data):
        if cmd == 10:                                   # SET_PIXEL_FORMAT
            fmt = C.cast(data, C.POINTER(C.c_int))[0]
            if fmt != 1:                                # we only decode XRGB8888
                raise SystemExit(f"unexpected pixel format {fmt}")
            return True
        if cmd in (9, 31):                              # GET_SYSTEM/SAVE_DIRECTORY
            C.cast(data, C.POINTER(C.c_char_p))[0] = self._sysdir
            return True
        if cmd == 15:                                   # GET_VARIABLE
            var = C.cast(data, C.POINTER(Variable))
            override = OPTIONS.get(var[0].key)
            if override is None:
                return False                            # core default
            var[0].value = override
            return True
        if cmd == 17:                                   # GET_VARIABLE_UPDATE
            C.cast(data, C.POINTER(C.c_bool))[0] = False
            return True
        if cmd == 52:                                   # GET_CORE_OPTIONS_VERSION
            C.cast(data, C.POINTER(C.c_uint))[0] = 0    # legacy SET_VARIABLES
            return True
        if cmd == 16:                                   # SET_VARIABLES
            return True
        return False

    def _video_refresh(self, data, w, h, pitch):
        if data:                                        # NULL means "same as last"
            self.frame = (C.string_at(data, pitch * h), w, h, pitch)

    def _input_state(self, port, device, index, btn_id):
        if port == 0 and device == RETRO_DEVICE_JOYPAD and btn_id in self.buttons:
            return 1
        return 0

    # --- driving ---
    def load(self, path):
        with open(path, "rb") as f:
            blob = f.read()
        self._rom = C.create_string_buffer(blob, len(blob))
        info = GameInfo(path.encode(), C.cast(self._rom, C.c_void_p), len(blob), None)
        if not self.core.retro_load_game(C.byref(info)):
            raise SystemExit("retro_load_game failed")

    def run(self, frames=1):
        for _ in range(frames):
            self.core.retro_run()

    def press(self, btn, hold=6, after=10):
        self.buttons.add(btn)
        self.run(hold)
        self.buttons.discard(btn)
        self.run(after)

    def wram(self, addr):
        """Read GB address $C000-$DFFF out of the core's system RAM."""
        self.core.retro_get_memory_data.restype = C.c_void_p
        base = self.core.retro_get_memory_data(RETRO_MEMORY_SYSTEM_RAM)
        size = self.core.retro_get_memory_size(RETRO_MEMORY_SYSTEM_RAM)
        off = addr - 0xC000
        if not base or not (0 <= off < size):
            raise SystemExit(f"cannot read {addr:04x} (size {size})")
        return C.cast(base + off, C.POINTER(C.c_ubyte))[0]

    def wait(self, addr, value, limit=1800, label=""):
        for i in range(limit):
            if self.wram(addr) == value:
                return i
            self.run(1)
        raise SystemExit(f"timeout waiting for {label or hex(addr)} == {value} "
                         f"(saw {self.wram(addr)})")


def save_png(frame, path, scale=3):
    """Write the XRGB8888 framebuffer out as a scaled PNG (stdlib only)."""
    buf, w, h, pitch = frame
    rows = []
    for y in range(h):
        line = bytearray()
        base = y * pitch
        for x in range(w):
            b, g, r = buf[base + x * 4], buf[base + x * 4 + 1], buf[base + x * 4 + 2]
            line += bytes((r, g, b)) * scale
        rows.extend([bytes(line)] * scale)

    raw = b"".join(b"\x00" + row for row in rows)          # filter type 0

    def chunk(tag, payload):
        return (struct.pack(">I", len(payload)) + tag + payload
                + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", w * scale, h * scale, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 9))
           + chunk(b"IEND", b""))
    with open(path, "wb") as f:
        f.write(png)
    return w * scale, h * scale


def main():
    wDistMonCursor, wDistLevel = 0xDEE7, 0xDEE8
    wPartyCount, wCurMap = 0xD168, 0xD363
    VIRIDIAN_POKECENTER = 0x29

    for path, what in ((CORE, "SameBoy libretro core"), (ROM, "ROM (run `make`)")):
        if not os.path.exists(path):
            raise SystemExit(f"missing {what}: {path}")
    os.makedirs(OUT, exist_ok=True)

    emu = Emu()
    emu.load(ROM)
    shots = {}

    def shot(name):
        px = save_png(emu.frame, os.path.join(OUT, name + ".png"))
        shots[name] = px
        print(f"  {name}.png {px[0]}x{px[1]}")

    # Title: logo, "DISTRIBUTION ROM", Mew. Needs ~650 frames before Start takes.
    emu.run(700)
    shot("title")

    # Start drops into the gift menu; DistributionMain writes the default level
    # before it draws anything, so that is the reliable "we are in" signal.
    emu.press(START)
    emu.wait(wDistLevel, 50, label="wDistLevel")
    emu.run(120)

    # Up from entry 0 wraps to #151 Mew -- the distribution mon.
    emu.press(UP)
    emu.wait(wDistMonCursor, 150, label="wDistMonCursor")
    emu.run(150)                       # let the pic decompress and copy
    shot("menu")

    emu.press(START)                   # jump-to-a-number prompt
    emu.run(40)
    shot("jump")
    emu.press(B)
    emu.run(40)

    emu.press(SELECT)                  # settings
    emu.run(60)
    shot("settings")
    emu.press(B)
    emu.run(60)

    emu.press(A)                       # choose Mew -> level screen
    emu.run(60)
    shot("level")

    # Confirm: the party is built, then DistReadyScreen draws its box and sits
    # waiting for A/B -- so the ready screen is a screen in its own right.
    emu.press(A)
    emu.wait(wPartyCount, 1, label="wPartyCount")
    emu.run(40)
    shot("ready")

    # Not used in the README: the link receptionist stands at (11, 2) of a map
    # only 14 coords wide, so the camera shows a few columns of the map's own
    # border block ($0, solid) on the right. That is stock Gen 1 behaviour at
    # that spot, not a fault, but it reads as a broken screenshot.
    emu.press(A)                       # dismiss -> warp into the Pokémon Center
    emu.wait(wCurMap, VIRIDIAN_POKECENTER, label="wCurMap")
    emu.run(420)                       # the map fades in; let it finish
    shot("pokecenter")

    print(f"party count = {emu.wram(wPartyCount)}, "
          f"map = ${emu.wram(wCurMap):02x}, level = {emu.wram(wDistLevel)}")
    return shots


if __name__ == "__main__":
    main()
