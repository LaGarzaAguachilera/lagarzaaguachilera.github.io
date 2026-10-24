# -*- coding: utf-8 -*-
"""
Integrador Web y Panel de Control para Spot 3D AAA Blender + RTX 4060
La Garza Aguachilera - Tampico y Ciudad Madero
"""

import os
import re

ROOT = r"d:\AG\la garza aguachilera"

def update_index_html():
    path = os.path.join(ROOT, "index.html")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Search for section 5.1
    old_target = """        <!-- Responsive HTML5 Video Player Container (9:16 vertical) -->
        <div class="relative z-10 flex flex-col items-center justify-center">
          <div class="w-full max-w-[320px] sm:max-w-[360px] bg-black rounded-3xl overflow-hidden border-2 border-emerald-400/70 shadow-[0_0_35px_rgba(16,185,129,0.35)] relative aspect-[9/16]">
            <video controls playsinline preload="metadata" src="VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4?v=170" class="w-full h-full object-cover rounded-3xl"></video>
          </div>"""

    replacement = """        <!-- Responsive HTML5 Dual Video Grid (9:16 vertical) -->
        <div class="relative z-10 grid grid-cols-1 md:grid-cols-2 gap-8 items-start justify-center max-w-4xl mx-auto">
          
          <!-- Video 1: 3D AAA Blender 4.3 + RTX 4060 Stories -->
          <div class="flex flex-col items-center bg-slate-950/80 rounded-3xl p-5 border-2 border-emerald-400/80 shadow-[0_0_35px_rgba(16,185,129,0.35)]">
            <div class="w-full text-center mb-3">
              <span class="inline-flex items-center gap-1.5 text-[11px] font-black uppercase tracking-wider text-emerald-300 bg-emerald-950/90 border border-emerald-500/50 px-3 py-1 rounded-full">
                <span>🔥</span> <span>3D AAA STORIES (BLENDER 4.3 &bull; RTX 4060)</span>
              </span>
              <h3 class="text-lg font-black text-white mt-2">El Crunch Definitivo 3D</h3>
              <p class="text-xs text-slate-300 font-medium">Stories 9:16 &bull; 60 FPS &bull; Cycles OptiX &bull; $170 MXN</p>
            </div>
            <div class="w-full max-w-[280px] bg-black rounded-2xl overflow-hidden border border-emerald-500/40 shadow-xl aspect-[9/16]">
              <video controls playsinline preload="metadata" src="VIDEOS/spot_la_garza_aaa_blender_rtx4060.mp4?v=170" class="w-full h-full object-cover rounded-2xl"></video>
            </div>
            <div class="mt-4 flex flex-wrap justify-center gap-1.5 text-[11px] font-bold">
              <span class="bg-emerald-950 text-emerald-300 border border-emerald-800 px-2 py-0.5 rounded-md">Blender 4.3 OptiX</span>
              <span class="bg-cyan-950 text-cyan-300 border border-cyan-800 px-2 py-0.5 rounded-md">RTX 4060 GPU</span>
              <span class="bg-yellow-950 text-yellow-300 border border-yellow-800 px-2 py-0.5 rounded-md">$170 MXN</span>
            </div>
          </div>

          <!-- Video 2: 2D Animated Episode 60 FPS -->
          <div class="flex flex-col items-center bg-slate-950/80 rounded-3xl p-5 border-2 border-cyan-400/80 shadow-[0_0_35px_rgba(6,182,212,0.35)]">
            <div class="w-full text-center mb-3">
              <span class="inline-flex items-center gap-1.5 text-[11px] font-black uppercase tracking-wider text-cyan-300 bg-cyan-950/90 border border-cyan-500/50 px-3 py-1 rounded-full">
                <span>⚡</span> <span>MINI-EPISODIO OFICIAL &bull; 60 FPS</span>
              </span>
              <h3 class="text-lg font-black text-white mt-2">La Resurrección de la Cruda</h3>
              <p class="text-xs text-slate-300 font-medium">&laquo;¡No estaban muertos... solo estaban crudos!&raquo;</p>
            </div>
            <div class="w-full max-w-[280px] bg-black rounded-2xl overflow-hidden border border-cyan-500/40 shadow-xl aspect-[9/16]">
              <video controls playsinline preload="metadata" src="VIDEOS/animacion_la_garza_episodio_crudos_60fps.mp4?v=170" class="w-full h-full object-cover rounded-2xl"></video>
            </div>
            <div class="mt-4 flex flex-wrap justify-center gap-1.5 text-[11px] font-bold">
              <span class="bg-cyan-950 text-cyan-300 border border-cyan-800 px-2 py-0.5 rounded-md">Lip-Sync Dinámico</span>
              <span class="bg-emerald-950 text-emerald-300 border border-emerald-800 px-2 py-0.5 rounded-md">Voces es-MX</span>
              <span class="bg-yellow-950 text-yellow-300 border border-yellow-800 px-2 py-0.5 rounded-md">$170 MXN</span>
            </div>
          </div>

        </div>"""

    # Normalize CRLF
    content_norm = content.replace("\r\n", "\n")
    old_target_norm = old_target.replace("\r\n", "\n")
    
    if old_target_norm in content_norm:
        content_norm = content_norm.replace(old_target_norm, replacement)
        # Restore CRLF
        content_final = content_norm.replace("\n", "\r\n")
        with open(path, "w", encoding="utf-8") as f:
            f.write(content_final)
        print("index.html actualizado exitosamente con doble reproductor.")
    else:
        print("No se encontró old_target exacto en index.html.")

def update_panel_control():
    path = os.path.join(ROOT, "panel_control.html")
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    new_card = """      <!-- ============================================================== -->
      <!-- CARD 00: SPOT PUBLICITARIO 3D AAA (BLENDER 4.3 + RTX 4060)      -->
      <!-- ============================================================== -->
      <article class="media-card glass-card rounded-3xl p-5 flex flex-col justify-between space-y-4 shadow-2xl md:col-span-2 lg:col-span-2 border-2 border-emerald-400/80 bg-gradient-to-br from-[#041d15] via-[#031510] to-[#020b08]" data-category="all video3d facebook instagram tiktok">
        <div class="space-y-3">
          <div class="flex flex-wrap items-center justify-between gap-2">
            <span class="text-[11px] font-black uppercase tracking-wider text-garza-neonlime bg-emerald-950/90 px-3 py-1 rounded-full border border-emerald-500/60 flex items-center gap-1.5 shadow-sm">
              <span>🔥</span> NUEVO &bull; SPOT CINEMATOGRÁFICO 3D AAA (BLENDER 4.3 + RTX 4060)
            </span>
            <span class="text-xs font-mono font-bold text-emerald-400 bg-black/60 px-2.5 py-0.5 rounded-lg border border-emerald-500/40">
              1080 x 1920 px (Stories 9:16) &bull; 60 FPS &bull; Cycles OptiX
            </span>
          </div>

          <div>
            <h3 class="text-base sm:text-lg font-black text-white leading-snug">Spot Animado 3D AAA: &quot;El Crunch Definitivo en Miramar y Tampico&quot;</h3>
            <p class="text-xs text-slate-300 mt-1 leading-relaxed">
              Producción 3D CGI de máxima fidelidad desarrollada y renderizada nativamente con el motor <strong>Cycles OptiX</strong> en Blender 4.3 aprovechando la GPU <strong>NVIDIA GeForce RTX 4060</strong> del usuario. Los personajes icónicos (Juancho con lentes de sol, el Mapache Tostitero, el OVNI de Miramar y La Garza Chef) cobran vida con iluminación cinemática PBR, reflejos esmeralda, tipografía volumétrica en oro 24K y el crunch de <strong>$170 MXN</strong>.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 items-center pt-1">
            <div class="w-full max-w-[240px] mx-auto bg-black rounded-2xl overflow-hidden border-2 border-emerald-400/60 shadow-2xl relative aspect-[9/16]">
              <video src="VIDEOS/spot_la_garza_aaa_blender_rtx4060.mp4?v=170" controls playsinline preload="metadata" class="w-full h-full object-cover rounded-2xl"></video>
            </div>

            <div class="bg-slate-950/95 rounded-2xl p-4 border border-emerald-500/30 text-xs space-y-2.5 shadow-inner">
              <div class="flex items-center justify-between text-garza-neonlime font-extrabold pb-1.5 border-b border-slate-800">
                <span>⚡ Telemetría 3D AAA &bull; RTX 4060:</span>
                <span class="text-[10px] bg-emerald-950 px-2 py-0.5 rounded text-emerald-300 border border-emerald-700">CERTIFICADO QA</span>
              </div>
              <ul class="space-y-1.5 text-[11px] text-slate-300">
                <li class="flex justify-between"><span class="text-slate-500">Resolución:</span> <strong class="text-white">1080 x 1920 (Vertical 9:16)</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Frame Rate:</span> <strong class="text-emerald-400">60 FPS (Flujo 60/1 &bull; 1440 Cuadros)</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Motor de Render:</span> <strong class="text-cyan-300">Blender 4.3 Cycles (OptiX Raytracing)</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">GPU Hardware:</span> <strong class="text-emerald-400">NVIDIA RTX 4060 Laptop GPU</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Bitrate de Video:</span> <strong class="text-orange-400">6,081 kbps (&gt; 4,000 kbps)</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Audio Master:</span> <strong class="text-sky-300">AAC Estéreo (48 kHz, 273.9 kbps)</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Personajes 3D:</span> <strong class="text-yellow-300">Juancho, Mapache, OVNI &amp; Garza Chef</strong></li>
                <li class="flex justify-between"><span class="text-slate-500">Precio Oficial:</span> <strong class="text-emerald-400 font-black">$170 MXN (Oro 3D + Voz)</strong></li>
              </ul>
              <div class="pt-2 border-t border-slate-800 text-[10px] text-slate-400 leading-relaxed">
                📢 Anuncia explícitamente: Tostiaguachile Verde Tradicional a $170 MXN, ~100g de camarón mariposa, aguacate fresco, Envíos y Entregas por Pedido y WhatsApp 833 252 09 88.
              </div>
            </div>
          </div>

          <div class="space-y-1.5">
            <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400 flex items-center justify-between">
              <span>Caption &amp; 3 Hooks Virales para Stories / Reels / TikTok:</span>
              <span class="text-emerald-400">1 Clic para Copiar</span>
            </label>
            <pre id="caption-blender-3d" class="bg-slate-950/90 p-3 rounded-xl text-[11px] text-slate-300 font-mono whitespace-pre-wrap leading-relaxed border border-slate-800 max-h-36 overflow-y-auto">🔥 3 HOOKS VIRALES DE RETENCIÓN (A/B TESTING):
1️⃣ &quot;¿Creías que un aguachile no podía verse como película 3D? 🐊✨ Así cruje el verdadero Tostiaguachile Verde de Tampico en Playa Miramar...&quot;
2️⃣ &quot;¡Los alienígenas no vinieron a invadir Tampico! Vinieron por el Tostiaguachile Verde de La Garza Aguachilera con camarón mariposa 🛸🦐&quot;
3️⃣ &quot;100g de camarón mariposa, aguacate fresco garantizado y salsa secreta de la casa por $170 pesos. ¡El crunch que revivió a Juancho y al Mapache! 🔥💚&quot;

🎬 GUION COMERCIAL OFICIAL (DaliaNeural es-MX):
&quot;¡La Garza Aguachilera presenta el sabor más fresco de Tampico y Madero! Prueba nuestro legendario Tostiaguachile Verde Tradicional: cien gramos de camarón limpio en corte mariposa, aguacate cremoso y nuestra salsa secreta de la casa. ¡A solo ciento setenta pesos! Sábados y domingos por pedido en WhatsApp. ¡Haz tu pedido por WhatsApp al 833 252 09 88!&quot;

💰 Inversión: $170 MXN (~100g camarón mariposa + TOSTITOS SALSA VERDE).
🥑 Garantía de frescura: Aguacate fresco en toda orden y salsas secretas de la casa.
🛵 Servicio a domicilio y puntos de entrega: Envíos por WhatsApp.
📍 Salimos desde: Tampico y Ciudad Madero, Tamaulipas.

📲 ¡Aparta tu pedido por WhatsApp al 833 252 09 88!
https://wa.me/528332520988

#Tampico #CiudadMadero #PlayaMiramar #LaGarzaAguachilera #Tostiaguachile #Blender3D #Animacion3D #Juancho #MapacheTostitero #MariscosTampico</pre>
          </div>
        </div>

        <div class="space-y-2 pt-2 border-t border-slate-800/80">
          <button type="button" onclick="copyCaptionFromElement('caption-blender-3d', this)" class="btn-copy w-full font-bold text-xs py-2.5 rounded-xl flex items-center justify-center gap-1.5 shadow-sm">
            <span>📋</span>
            <span>Copiar Caption + 3 Hooks</span>
          </button>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
            <a href="VIDEOS/spot_la_garza_aaa_blender_rtx4060.mp4?v=170" download="spot_la_garza_aaa_blender_rtx4060.mp4" class="btn-download w-full font-extrabold text-xs py-3 rounded-xl flex items-center justify-center gap-2 shadow-sm text-center">
              <span>📥</span>
              <span>Descargar Spot 3D Stories (.MP4 &bull; 19.1 MB)</span>
            </a>
            <a href="BLENDER/la_garza_aaa_stories.blend" download="la_garza_aaa_stories.blend" class="btn-download w-full font-extrabold text-xs py-3 rounded-xl flex items-center justify-center gap-2 shadow-sm text-center bg-cyan-950 hover:bg-cyan-900 border border-cyan-500/40 text-cyan-300">
              <span>🎨</span>
              <span>Descargar Escena 3D (.BLEND &bull; 2.6 MB)</span>
            </a>
          </div>
        </div>
      </article>

"""

    content_norm = content.replace("\r\n", "\n")
    
    # Insert right at the top of multimedia-container
    container_marker = '<section id="multimedia-container" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">\n'
    if container_marker in content_norm:
        content_norm = content_norm.replace(container_marker, container_marker + new_card)
        
        # Also add a video3d filter tab in segmented-control
        tab_marker = '<button type="button" class="filter-tab active" data-filter="all" onclick="filterTab(\'all\', this)">'
        new_tab = """<button type="button" class="filter-tab" data-filter="video3d" onclick="filterTab('video3d', this)">
            <span>🎬</span>
            <span>Spot 3D AAA &amp; Videos</span>
            <span class="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-1.5 py-0.2 rounded-full font-bold ml-0.5 badge-count">3</span>
          </button>\n          """
        content_norm = content_norm.replace(tab_marker, tab_marker + "\n          " + new_tab)
        
        content_final = content_norm.replace("\n", "\r\n")
        with open(path, "w", encoding="utf-8") as f:
            f.write(content_final)
        print("panel_control.html actualizado exitosamente con CARD 00 y pestaña 3D.")
    else:
        print("No se encontró multimedia-container marker en panel_control.html.")

if __name__ == "__main__":
    update_index_html()
    update_panel_control()
