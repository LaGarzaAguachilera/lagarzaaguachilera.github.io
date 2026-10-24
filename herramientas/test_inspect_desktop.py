import ctypes
import threading
from ctypes import wintypes

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

def worker():
    hDesk = user32.OpenDesktopW("Default", 0, False, 0x1FF)
    print("OpenDesktopW:", hDesk)
    if hDesk:
        ok = user32.SetThreadDesktop(hDesk)
        print("SetThreadDesktop:", ok)
        
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
                        print(f"Found Blender window: HWND={hex(hwnd)}, PID={pid.value}, Title='{title}'")
            return True
        user32.EnumDesktopWindows(hDesk, WNDENUMPROC(enum_cb), 0)
        user32.CloseDesktop(hDesk)

if __name__ == "__main__":
    t = threading.Thread(target=worker)
    t.start()
    t.join()
