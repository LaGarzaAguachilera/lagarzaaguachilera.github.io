# -*- coding: utf-8 -*-
"""
INCORPORA LOS 4 PLATES 3D CGI COMO FONDOS DE ESCENARIO EN BLENDER 4.3
Project: La Garza Aguachilera — Milestone 1 & 4
Actualiza 'BLENDER/la_garza_aaa_stories.blend' con los 4 plates de FRAMES/aaa_stories/
animados secuencialmente a través de los 4 actos (1440 frames @ 60fps) con Cycles OptiX RTX 4060.
"""

import os
import math
import bpy

PROJECT_ROOT = r"d:\AG\la garza aguachilera"
BLEND_FILE = os.path.join(PROJECT_ROOT, "BLENDER", "la_garza_aaa_stories.blend")
PLATES_DIR = os.path.join(PROJECT_ROOT, "FRAMES", "aaa_stories")

plates_spec = [
    (1, "Backdrop_Plate_Act1", os.path.join(PLATES_DIR, "aaa_act1_miramar_ufo.jpg"), 1, 360),
    (2, "Backdrop_Plate_Act2", os.path.join(PLATES_DIR, "aaa_act2_garza_chef_splash.jpg"), 361, 720),
    (3, "Backdrop_Plate_Act3", os.path.join(PLATES_DIR, "aaa_act3_beach_party_crunch.jpg"), 721, 1080),
    (4, "Backdrop_Plate_Act4", os.path.join(PLATES_DIR, "aaa_act4_hero_pedestal.jpg"), 1081, 1440),
]


def update_scene_with_plates():
    print(f" [INFO] Abriendo {BLEND_FILE}...")
    bpy.ops.wm.open_mainfile(filepath=BLEND_FILE)
    scene = bpy.context.scene

    # 1. Configurar Cycles con OptiX RTX 4060 estricto
    scene.render.engine = "CYCLES"
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
        prefs.compute_device_type = "OPTIX"
        prefs.get_devices()
        for d in prefs.devices:
            if "RTX 4060" in d.name or d.type == "OPTIX":
                d.use = True
                print(f" [CYCLES GPU ACTIVADO] {d.name} ({d.type})")
            else:
                d.use = False
                print(f" [CYCLES CPU DESACTIVADO] {d.name} ({d.type})")
        scene.cycles.device = "GPU"
        scene.cycles.samples = 32
        scene.cycles.use_denoising = True
    except Exception as e:
        print(f" [WARN] Cycles prefs config: {e}")

    # 2. Eliminar backdrops previos si ya existen
    for _, obj_name, _, _, _ in plates_spec:
        if obj_name in bpy.data.objects:
            bpy.data.objects.remove(bpy.data.objects[obj_name], do_unlink=True)

    # 3. Crear los 4 planos de fondo para cada acto
    # Relación 9:16 -> ancho 4.30, alto 4.30 * (16/9) = 7.64
    width = 4.30
    height = 7.64
    loc_y = 1.65  # justo detrás de los personajes (Y=0.3-0.6) y delante de las luces lejanas

    for act_num, obj_name, img_path, start_f, end_f in plates_spec:
        if not os.path.exists(img_path):
            print(f" [WARN] Imagen no existe: {img_path}")
            continue

        img = bpy.data.images.load(img_path, check_existing=True)

        bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0.0, loc_y, 0.0))
        plane = bpy.context.active_object
        plane.name = obj_name
        plane.scale = (width, height, 1.0)
        plane.rotation_euler = (math.radians(90), 0.0, 0.0)

        # Crear material con textura emisiva suave
        mat = bpy.data.materials.new(name=f"Mat_{obj_name}")
        mat.use_nodes = True
        nodes = mat.node_tree.nodes
        links = mat.node_tree.links
        nodes.clear()

        out_node = nodes.new(type="ShaderNodeOutputMaterial")
        bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
        tex = nodes.new(type="ShaderNodeTexImage")
        tex.image = img

        bsdf.inputs["Roughness"].default_value = 0.5
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = 0.35
            links.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])
        links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        links.new(bsdf.outputs["BSDF"], out_node.inputs["Surface"])

        plane.data.materials.append(mat)

        # Animar visibilidad en viewport y render para cada acto
        # Frame 1: oculto o visible según corresponda
        # Usamos keyframes en hide_render y hide_viewport
        for frame in [1, start_f - 1 if start_f > 1 else None, start_f, end_f, end_f + 1 if end_f < 1440 else None]:
            if frame is None or frame < 1 or frame > 1440:
                continue
            is_active = (start_f <= frame <= end_f)
            plane.hide_render = not is_active
            plane.hide_viewport = not is_active
            plane.keyframe_insert(data_path="hide_render", frame=frame)
            plane.keyframe_insert(data_path="hide_viewport", frame=frame)

        print(f" [OK] Creado {obj_name} para Acto {act_num} (frames {start_f}..{end_f})")

    # 4. Guardar proyecto .blend
    bpy.ops.wm.save_as_mainfile(filepath=BLEND_FILE)
    print(f" [OK] {BLEND_FILE} guardado exitosamente con los 4 stage backdrops y Cycles OptiX RTX 4060.")


if __name__ == "__main__":
    update_scene_with_plates()
