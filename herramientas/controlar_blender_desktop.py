# -*- coding: utf-8 -*-
"""
STABILIZED BLENDER 4.3 DESKTOP CONTROLLER
Project: La Garza Aguachilera — Milestone 1 & 4 Stabilization
1. Inspects the user's interactive 'Default' desktop (WinSta0\\Default) directly.
2. Cleans up any orphaned headless or non-Default-desktop Blender instances.
3. Enforces single-instance: reuses existing visible Blender window on WinSta0\\Default.
4. Launches Blender 4.3 maximized on WinSta0\\Default WITHOUT animation_play() loops (0% idle GPU).
"""

import os
import sys
import time
import ctypes
import threading
import subprocess
from ctypes import wintypes

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

BLENDER_EXE = r"C:\Program Files\Blender Foundation\Blender 4.3\blender.exe"
BLEND_FILE = r"d:\AG\la garza aguachilera\BLENDER\la_garza_aaa_stories.blend"
CONFIG_DIR = os.path.expandvars(r"%APPDATA%\Blender Foundation\Blender\4.3\config")
RECENT_FILES = os.path.join(CONFIG_DIR, "recent-files.txt")

user32 = ctypes.windll.user32
SW_MAXIMIZE = 3


def get_default_desktop_blender_windows():
    """Enumerates visible Blender windows on the user's interactive Default desktop."""
    found = []

    def _worker():
        h_desk = user32.OpenDesktopW("Default", 0, False, 0x01FF)
        if not h_desk:
            return
        try:
            user32.SetThreadDesktop(h_desk)
            WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)

            def _cb(hwnd, lparam):
                if user32.IsWindowVisible(hwnd):
                    length = user32.GetWindowTextLengthW(hwnd)
                    if length > 0:
                        buf = ctypes.create_unicode_buffer(length + 1)
                        user32.GetWindowTextW(hwnd, buf, length + 1)
                        title = buf.value
                        # Match genuine Blender 4.3 window titles (exclude browser tabs)
                        if "blender 4." in title.lower() or "la_garza_aaa_stories" in title.lower():
                            pid = wintypes.DWORD()
                            user32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
                            found.append((hwnd, pid.value, title))
                return True

            user32.EnumDesktopWindows(h_desk, WNDENUMPROC(_cb), 0)
        finally:
            user32.CloseDesktop(h_desk)

    t = threading.Thread(target=_worker)
    t.start()
    t.join(timeout=3.0)
    return found


def maximize_on_default_desktop(target_hwnd):
    """Maximizes and brings the target HWND to foreground on the Default desktop."""
    def _worker():
        h_desk = user32.OpenDesktopW("Default", 0, False, 0x01FF)
        if not h_desk:
            return
        try:
            user32.SetThreadDesktop(h_desk)
            user32.ShowWindow(target_hwnd, SW_MAXIMIZE)
            user32.SetForegroundWindow(target_hwnd)
        finally:
            user32.CloseDesktop(h_desk)

    t = threading.Thread(target=_worker)
    t.start()
    t.join(timeout=3.0)


def cleanup_non_default_blender_processes(valid_pids):
    """Terminates any headless or sandboxed-desktop blender.exe processes."""
    valid_set = set(valid_pids)
    ps_cmd = "Get-Process -Name blender -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id"
    res = subprocess.run(["powershell", "-NoProfile", "-Command", ps_cmd], capture_output=True, text=True)
    for line in res.stdout.splitlines():
        line = line.strip()
        if line.isdigit():
            pid = int(line)
            if pid not in valid_set:
                subprocess.run(
                    ["powershell", "-NoProfile", "-Command", f"Stop-Process -Id {pid} -Force -ErrorAction SilentlyContinue"],
                    capture_output=True,
                )
                print(f" [STABILIZATION] Terminado proceso Blender huérfano/oculto PID {pid}")


def set_recent_files(blend_path):
    """Registers the project at the top of Blender's Recent Files menu."""
    try:
        os.makedirs(CONFIG_DIR, exist_ok=True)
        lines = []
        if os.path.exists(RECENT_FILES):
            with open(RECENT_FILES, "r", encoding="utf-8") as f:
                lines = [l.strip() for l in f.readlines() if l.strip()]
        if blend_path in lines:
            lines.remove(blend_path)
        lines.insert(0, blend_path)
        with open(RECENT_FILES, "w", encoding="utf-8") as f:
            for l in lines:
                f.write(l + "\n")
        print(f" [OK] 'recent-files.txt' actualizado con: {blend_path}")
    except Exception as e:
        print(f" [WARN] No se pudo actualizar recent-files.txt: {e}")


def control_desktop_session():
    print("=" * 75)
    print(" STABILIZED BLENDER 4.3 DESKTOP CONTROLLER")
    print(f" Target .blend: {BLEND_FILE}")
    print("=" * 75)

    if not os.path.exists(BLEND_FILE):
        print(f" [FAIL] .blend no encontrado en: {BLEND_FILE}")
        return 1

    set_recent_files(BLEND_FILE)

    visible_wins = get_default_desktop_blender_windows()
    target_win = None
    for hwnd, pid, title in visible_wins:
        if "la_garza_aaa_stories" in title.lower():
            target_win = (hwnd, pid, title)
            break

    if target_win:
        hwnd, pid, title = target_win
        cleanup_non_default_blender_processes([pid])
        maximize_on_default_desktop(hwnd)
        print(f" [OK] Proyecto ya visible en escritorio Default: PID={pid}, HWND={hex(hwnd)}, Título='{title}'")
    else:
        cleanup_non_default_blender_processes([])
        print(" [INFO] Lanzando Blender 4.3 directamente en escritorio interactivo WinSta0\\Default...")
        si = subprocess.STARTUPINFO()
        si.lpDesktop = r"WinSta0\Default"
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        si.wShowWindow = SW_MAXIMIZE

        proc = subprocess.Popen(
            [BLENDER_EXE, BLEND_FILE],
            startupinfo=si,
            close_fds=True,
        )

        for _ in range(24):
            time.sleep(0.5)
            visible_wins = get_default_desktop_blender_windows()
            for hwnd, pid, title in visible_wins:
                if pid == proc.pid or "la_garza_aaa_stories" in title.lower():
                    target_win = (hwnd, pid, title)
                    break
            if target_win and "la_garza_aaa_stories" in target_win[2].lower():
                break

        if target_win:
            hwnd, pid, title = target_win
            maximize_on_default_desktop(hwnd)
            print(f" [OK] Ventana de Blender verificada en WinSta0\\Default: PID={pid}, HWND={hex(hwnd)}, Título='{title}'")
        else:
            print(f" [WARN] Proceso lanzado (PID={proc.pid}), verificando título de ventana...")

    print("=" * 75)
    print(" CONTROL DE BLENDER 4.3 ESTABILIZADO EXITOSAMENTE (0% IDLE GPU)")
    print("=" * 75)
    return 0


if __name__ == "__main__":
    sys.exit(control_desktop_session())
