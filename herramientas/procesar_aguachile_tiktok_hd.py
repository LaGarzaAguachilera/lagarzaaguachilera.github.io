#!/usr/bin/env python3
"""
Wrapper oficial para procesar_aguachile_tiktok_hd.py -> producir_video_tiktok_hd.py
Renderiza promo_aguachile_verde_final.mp4 y aguachile_video_1_tiktok_hd.mp4 con $170 MXN.
"""
import asyncio
from producir_video_tiktok_hd import main

if __name__ == "__main__":
    asyncio.run(main())
