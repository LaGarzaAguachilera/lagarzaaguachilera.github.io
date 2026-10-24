# -*- coding: utf-8 -*-
"""
PROPOSED STABILIZED BLENDER 4.3 DESKTOP CONTROLLER
Project: La Garza Aguachilera — Milestone 1 & 4 Stabilization
Fixes the root cause of Antigravity crashes:
1. Eradicates zombie/headless Blender background processes (MainWindowHandle == 0).
2. Uses Windows ShellExecute (os.startfile) instead of fragile SetThreadDesktop / lpDesktop="WinSta0\\Default".
3. Enforces single-instance: re-uses existing visible Blender window instead of multi-spawning.
4. Removes infinite bpy.ops.screen.animation_play() loop that sat in background burning 100% CPU/GPU and crashing Electron.
5. Safely brings the visible Blender window to foreground.
"""

import os
import sys
import time
import subprocess
import ctypes
from ctypes import wintypes

BLENDER_EXE = r"C:\Program Files\Blender Foundation\Blender 4.3\blender.exe"
BLEND_FILE = r"d:\AG\la garza aguachilera\BLENDER\la_garza_aaa_stories.blend"
CONFIG_DIR = os.path.expandvars(r"%APPDATA%\Blender Foundation\Blender\4.3\config")
RECENT_FILES = os.path.join(CONFIG_DIR, "recent-files.txt")

user32 = ctypes.windll.user32
SW_MAXIMIZE = 3
SW_RESTORE = 9


def cleanup_headless_zombie_blender():
    """Kills any orphaned headless Blender instances that have no window."""
    try:
        ps_cmd = (
            "Get-Process -Name blender -ErrorAction SilentlyContinue | "
            "Where-Object { $_.MainWindowHandle -eq 0 } | "
            "ForEach-Object { Stop-Process -Id $_.Id -Force; Write-Output ('Killed zombie blender PID ' + $_.Id) }"
        )
        res = subprocess.run(["powershell", "-NoProfile", "-Command", ps_cmd], capture_output=True, text=True)
        if res.stdout.strip():
            print(f" [STABILIZATION] {res.stdout.strip()}")
    except Exception as e:
        print(f" [WARN] Zombie cleanup check: {e}")


def set_recent_files(blend_path):
    """Registers the project at top of Blender's Recent Files menu."""
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


def find_visible_blender_windows():
    """Finds genuine visible top-level windows belonging to Blender."""
    windows = []
    WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)

    def enum_cb(hwnd, lparam):
        if user32.IsWindowVisible(hwnd):
            length = user32.GetWindowTextLengthW(hwnd)
            if length > 0:
                buf = ctypes.create_unicode_buffer(length + 1)
                user32.GetWindowTextW(hwnd, buf, length + 1)
                title = buf.value
                if "blender" in title.lower():
                    pid = wintypes.DWORD()
                    user32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
                    windows.append((hwnd, pid.value, title))
        return True

    user32.EnumWindows(WNDENUMPROC(enum_cb), 0)
    return windows


def control_desktop_session():
    print("=" * 75)
    print(" STABILIZED BLENDER 4.3 DESKTOP CONTROLLER")
    print(f" Target .blend: {BLEND_FILE}")
    print("=" * 75)

    if not os.path.exists(BLEND_FILE):
        print(f" [FAIL] .blend no encontrado en: {BLEND_FILE}")
        return 1

    # 1. Limpieza preventiva de instancias fantasma que saturan GPU/VRAM
    cleanup_headless_zombie_blender()

    # 2. Registrar en lista de recientes
    set_recent_files(BLEND_FILE)

    # 3. Detectar si ya existe una ventana visible de Blender abierta con el proyecto
    visible_wins = find_visible_blender_windows()
    target_hwnd = None
    target_title = ""

    for hwnd, pid, title in visible_wins:
        if "la_garza_aaa_stories" in title.lower():
            target_hwnd = hwnd
            target_title = title
            print(f" [INFO] Proyecto ya abierto en ventana activa: PID {pid}, HWND {hex(hwnd)}")
            break

    # 4. Si no está abierto en ventana visible, lanzar mediante ShellExecute (os.startfile)
    if not target_hwnd:
        print(" [INFO] Abriendo proyecto en el escritorio del usuario mediante ShellExecute...")
        try:
            # os.startfile abre de forma nativa en el escritorio interactivo del usuario
            os.startfile(BLEND_FILE)
        except Exception:
            # Fallback a Start-Process de PowerShell
            subprocess.Popen(
                ["powershell", "-NoProfile", "-Command", f'Start-Process "{BLEND_FILE}"'],
                shell=False
            )

        # Esperar hasta 10s a que aparezca la ventana en el escritorio interactivo
        for _ in range(20):
            time.sleep(0.5)
            visible_wins = find_visible_blender_windows()
            for hwnd, pid, title in visible_wins:
                if "la_garza_aaa_stories" in title.lower() or "blender" in title.lower():
                    target_hwnd = hwnd
                    target_title = title
                    break
            if target_hwnd:
                break

    # 5. Traer la ventana interactiva al primer plano y maximizar
    if target_hwnd:
        print(f" [OK] Ventana de Blender localizada: HWND={hex(target_hwnd)}, Título='{target_title}'")
        user32.ShowWindow(target_hwnd, SW_MAXIMIZE)
        user32.SetForegroundWindow(target_hwnd)
        print(" [OK] Ventana visible y maximizada en el escritorio del usuario!")
    else:
        print(" [INFO] Blender lanzado a través de Windows Shell para visualización del usuario.")

    print("=" * 75)
    print(" CONTROL DE BLENDER 4.3 STABILIZADO EXITOSAMENTE")
    print("=" * 75)
    return 0


if __name__ == "__main__":
    sys.exit(control_desktop_session())
