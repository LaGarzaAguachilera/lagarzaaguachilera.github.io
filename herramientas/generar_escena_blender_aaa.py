# -*- coding: utf-8 -*-
"""
SCRIPT OFICIAL DE BLENDER 4.3 (BPY + CYCLES OPTIX GPU RTX 4060)
Construye el proyecto 3D 'BLENDER/la_garza_aaa_stories.blend' y renderiza
la tipografía 3D extruida/biselada con PBR Oro 24K + Neón Esmeralda,
anillos de energía 3D y escenario 3D para el Story AAA de 24 segundos.
Precio Oficial Único: $170 MXN
"""

import os
import math
import time
import bpy
from mathutils import Vector

PROJECT_ROOT = r"d:\AG\la garza aguachilera"
BLENDER_DIR = os.path.join(PROJECT_ROOT, "BLENDER")
RENDERS_DIR = os.path.join(BLENDER_DIR, "renders_hud")
os.makedirs(RENDERS_DIR, exist_ok=True)

BLEND_OUT = os.path.join(BLENDER_DIR, "la_garza_aaa_stories.blend")


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = 60
    scene.frame_start = 1
    scene.frame_end = 1440  # 24.0s @ 60fps
    scene.render.resolution_x = 1080
    scene.render.resolution_y = 1920
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"

    # Configurar Cycles con GPU NVIDIA RTX 4060 (OptiX estricto, CPU deshabilitado)
    scene.render.engine = "CYCLES"
    prefs = bpy.context.preferences.addons["cycles"].preferences
    prefs.compute_device_type = "OPTIX"
    prefs.get_devices()
    for d in prefs.devices:
        if "RTX 4060" in d.name or d.type == "OPTIX":
            d.use = True
            print(f" [CYCLES GPU ACTIVADO] Dispositivo: {d.name} ({d.type})")
        else:
            d.use = False
            print(f" [CYCLES CPU DESACTIVADO] Dispositivo: {d.name} ({d.type})")
    scene.cycles.device = "GPU"
    scene.cycles.samples = 32
    scene.cycles.use_denoising = True
    return scene


def make_pbr_material(name, base_color, metallic=0.9, roughness=0.18, emission_color=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = base_color
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
        if emission_color and "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission_color
            bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def make_image_plane(name, img_path, location, width=2.2, emission_strength=1.15):
    if not os.path.exists(img_path):
        return None
    img = bpy.data.images.load(img_path, check_existing=True)
    aspect = img.size[1] / max(1, img.size[0])
    height = width * aspect

    bpy.ops.mesh.primitive_plane_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (width, height, 1.0)
    obj.rotation_euler = (math.radians(90), 0.0, 0.0)

    mat = bpy.data.materials.new(name=f"Mat_{name}")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out_node = nodes.new(type="ShaderNodeOutputMaterial")
    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    tex = nodes.new(type="ShaderNodeTexImage")
    tex.image = img

    bsdf.inputs["Roughness"].default_value = 0.25
    if "Emission Strength" in bsdf.inputs:
        bsdf.inputs["Emission Strength"].default_value = emission_strength
        links.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])

    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    links.new(bsdf.outputs["BSDF"], out_node.inputs["Surface"])

    obj.data.materials.append(mat)
    return obj


def add_3d_star(name, location, scale=0.22, mat=None):
    mesh = bpy.data.meshes.new(name)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)

    verts = [(0, -0.06, 0), (0, 0.06, 0)]  # front/back centers
    for i in range(10):
        ang = math.pi / 2 + i * math.pi / 5
        r = scale if i % 2 == 0 else scale * 0.42
        verts.append((r * math.cos(ang), 0.0, r * math.sin(ang)))

    faces = []
    for i in range(10):
        nxt = 2 + ((i + 1) % 10)
        cur = 2 + i
        faces.append((0, cur, nxt))
        faces.append((1, nxt, cur))

    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj.location = location
    if mat:
        obj.data.materials.append(mat)
    return obj


def add_rounded_3d_pill(name, location, width, height, depth, mat_body, mat_rim, z_anchor="CENTER"):
    if z_anchor == "TOP":
        z_c = location[2] - height / 2.0
    elif z_anchor == "BOTTOM":
        z_c = location[2] + height / 2.0
    else:
        z_c = location[2]
    loc_c = (location[0], location[1], z_c)

    # Cuerpo biselado 3D
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc_c)
    body = bpy.context.active_object
    body.name = name
    body.scale = (width * 0.985, depth, height * 0.985)
    bpy.ops.object.transform_apply(scale=True)

    bev = body.modifiers.new(name="Bevel", type="BEVEL")
    bev.width = min(width, height) * 0.26
    bev.segments = 6
    body.data.materials.append(mat_body)

    # Borde metálico 3D trasero (ancho exterior estricto <= width para zona segura X en [90, 990])
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(loc_c[0], loc_c[1] + 0.03, loc_c[2]))
    rim = bpy.context.active_object
    rim.name = f"{name}_Rim"
    rim.scale = (width, depth * 0.85, height)
    bpy.ops.object.transform_apply(scale=True)
    bev_r = rim.modifiers.new(name="Bevel", type="BEVEL")
    bev_r.width = min(width, height) * 0.28
    bev_r.segments = 6
    rim.data.materials.append(mat_rim)
    return body, rim


def add_3d_text(name, body_text, location, size, extrude, bevel, mat, font_Loaded=None):
    bpy.ops.object.text_add(location=location)
    txt_obj = bpy.context.active_object
    txt_obj.name = name
    txt_obj.rotation_euler = (math.radians(90), 0.0, 0.0)
    data = txt_obj.data
    data.body = body_text
    data.align_x = "CENTER"
    data.align_y = "CENTER"
    data.size = size
    data.extrude = extrude
    data.bevel_depth = bevel
    data.bevel_resolution = 4
    if font_Loaded:
        data.font = font_Loaded
    data.materials.append(mat)
    return txt_obj


def build_and_render():
    t0 = time.time()
    scene = reset_scene()

    # Cargar fuentes del sistema Windows para geometría 3D sólida
    font_impact = None
    font_arialbd = None
    for fpath in [r"C:\Windows\Fonts\impact.ttf", r"C:\Windows\Fonts\arialbd.ttf"]:
        if os.path.exists(fpath):
            if "impact" in fpath.lower():
                font_impact = bpy.data.fonts.load(fpath)
            else:
                font_arialbd = bpy.data.fonts.load(fpath)

    # Materiales PBR de Estudio AAA
    mat_gold = make_pbr_material(
        "Mat_Gold_24K",
        (1.0, 0.80, 0.12, 1.0),
        metallic=0.98,
        roughness=0.14,
        emission_color=(1.0, 0.78, 0.15, 1.0),
        emission_strength=0.65,
    )
    mat_emerald = make_pbr_material(
        "Mat_Emerald_Neon",
        (0.08, 0.96, 0.44, 1.0),
        metallic=0.75,
        roughness=0.16,
        emission_color=(0.12, 1.0, 0.48, 1.0),
        emission_strength=1.45,
    )
    mat_crimson = make_pbr_material(
        "Mat_Crimson_Ruby",
        (0.82, 0.04, 0.12, 1.0),
        metallic=0.88,
        roughness=0.22,
        emission_color=(0.85, 0.05, 0.15, 1.0),
        emission_strength=0.35,
    )
    mat_obsidian = make_pbr_material(
        "Mat_Obsidian_Dark",
        (0.015, 0.035, 0.06, 1.0),
        metallic=0.92,
        roughness=0.18,
    )
    mat_white = make_pbr_material(
        "Mat_White_Crisp",
        (1.0, 1.0, 1.0, 1.0),
        metallic=0.2,
        roughness=0.15,
        emission_color=(1.0, 1.0, 1.0, 1.0),
        emission_strength=1.25,
    )

    # Cámara Vertical 9:16 (Orthographic/Perspective híbrida limpia)
    bpy.ops.object.camera_add(location=(0.0, -9.5, 0.0), rotation=(math.radians(90), 0.0, 0.0))
    cam = bpy.context.active_object
    cam.name = "Camera_Stories_AAA"
    cam.data.lens = 45.0
    scene.camera = cam

    # Iluminación de Estudio Cinematográfica (3-Point + Rim Lights)
    lights_spec = [
        ("Key_Light_Gold", (3.5, -6.0, 4.2), (math.radians(55), 0, math.radians(25)), 650.0, (1.0, 0.92, 0.75)),
        ("Fill_Light_Emerald", (-3.8, -5.5, 1.5), (math.radians(70), 0, math.radians(-30)), 480.0, (0.35, 1.0, 0.65)),
        ("Rim_Light_Bottom", (0.0, -5.0, -4.5), (math.radians(120), 0, 0), 520.0, (1.0, 0.84, 0.25)),
    ]
    for lname, loc, rot, energy, col in lights_spec:
        bpy.ops.object.light_add(type="AREA", location=loc, rotation=rot)
        l_obj = bpy.context.active_object
        l_obj.name = lname
        l_obj.data.energy = energy
        l_obj.data.color = col
        l_obj.data.size = 4.0

    # =========================================================================
    # 1. CORONA SUPERIOR 3D PERMANENTE (SAFE ZONE Y en ~[230, 370])
    # =========================================================================
    add_rounded_3d_pill("Top_Header_Pill", (0.0, 0.0, 2.90), width=3.50, height=0.55, depth=0.12, mat_body=mat_obsidian, mat_rim=mat_gold, z_anchor="TOP")
    add_3d_text("Txt3D_Brand_Title", "LA GARZA AGUACHILERA", (0.0, -0.10, 2.75), size=0.27, extrude=0.04, bevel=0.006, mat=mat_gold, font_Loaded=font_impact)
    add_3d_text("Txt3D_Brand_Sub", "TOSTIAGUACHILE VERDE • TAMPICO Y MADERO", (0.0, -0.10, 2.49), size=0.12, extrude=0.02, bevel=0.003, mat=mat_emerald, font_Loaded=font_arialbd)

    # Píldora Roja/Oro 3D de Precio Permanente ($170 MXN) (SAFE ZONE Y en ~[380, 470])
    add_rounded_3d_pill("Top_Price_Pill_170", (0.0, -0.05, 2.22), width=3.10, height=0.44, depth=0.14, mat_body=mat_crimson, mat_rim=mat_gold, z_anchor="CENTER")
    add_3d_text("Txt3D_Price_170", "¡A SOLO $170 MXN!", (0.0, -0.18, 2.21), size=0.28, extrude=0.045, bevel=0.007, mat=mat_gold, font_Loaded=font_impact)
    add_3d_star("Star3D_Left", (-1.22, -0.16, 2.21), scale=0.13, mat=mat_gold)
    add_3d_star("Star3D_Right", (1.22, -0.16, 2.21), scale=0.13, mat=mat_gold)

    # =========================================================================
    # 2. TARJETAS INFERIORES 3D POR ACTO (SAFE ZONE Y en ~[1380, 1580])
    # =========================================================================
    add_rounded_3d_pill("Bottom_Card_Pill", (0.0, 0.0, -2.35), width=3.52, height=0.68, depth=0.12, mat_body=mat_obsidian, mat_rim=mat_emerald, z_anchor="BOTTOM")

    acts_data = [
        ("hud_act1.png", "¡ANTOJO DE OTRO PLANETA!", "ABDUCIDOS EN PLAYA MIRAMAR • $170 MXN"),
        ("hud_act2.png", "PREPARADO FRENTE A TI", "AGUACATE FRESCO + SALSAS DE LA CASA"),
        ("hud_act3.png", "¡EL CRUNCH MÁS VIRAL!", "~100G CAMARÓN MARIPOSA • $170 MXN"),
        ("hud_act4.png", "WHATSAPP 833 252 09 88", "SÁB Y DOM 1-5 PM • COL. FLORES, TAMPICO"),
    ]

    txt_main = add_3d_text("Txt3D_Act_Main", acts_data[0][1], (0.0, -0.10, -1.88), size=0.28, extrude=0.045, bevel=0.007, mat=mat_gold, font_Loaded=font_impact)
    txt_sub = add_3d_text("Txt3D_Act_Sub", acts_data[0][2], (0.0, -0.10, -2.18), size=0.125, extrude=0.025, bevel=0.004, mat=mat_white, font_Loaded=font_arialbd)

    for out_name, l1, l2 in acts_data:
        txt_main.data.body = l1
        txt_sub.data.body = l2
        out_file = os.path.join(RENDERS_DIR, out_name)
        scene.render.filepath = out_file
        bpy.ops.render.render(write_still=True)
        print(f" [OK BLENDER CYCLES RTX 4060] Renderizado 3D HUD: {out_file}")

    # =========================================================================
    # 3. ESCENARIO 3D COMPLETO CON NUESTROS PERSONAJES PARA EL ARCHIVO .BLEND
    # =========================================================================
    # Agregamos en el centro del proyecto .blend a nuestros personajes y un OVNI 3D
    # con animación de fotogramas clave (1..1440) para que el archivo .blend sea un
    # estudio 3D interactivo completo y renderizamos una toma maestra del escenario 3D.
    p_comida = make_image_plane("Hero_Aguachile_3D", os.path.join(PROJECT_ROOT, "clean_comida.png"), (0.0, 0.3, -0.85), width=2.4)
    p_juancho = make_image_plane("Juancho_Cocodrilo_3D", os.path.join(PROJECT_ROOT, "clean_juancho.png"), (-1.08, 0.6, 0.25), width=1.88)
    p_mapache = make_image_plane("Mapache_Escolleras_3D", os.path.join(PROJECT_ROOT, "clean_mapache.png"), (1.08, 0.6, 0.15), width=1.85)
    p_ovni = make_image_plane("OVNI_Miramar_3D", os.path.join(PROJECT_ROOT, "clean_ovni.png"), (0.0, 0.4, 1.55), width=1.6)

    # Anillos de energía 3D alrededor del platillo
    bpy.ops.mesh.primitive_torus_add(location=(0.0, 0.3, -0.9), major_radius=1.45, minor_radius=0.035)
    ring1 = bpy.context.active_object
    ring1.name = "Emerald_Power_Ring_3D"
    ring1.rotation_euler = (math.radians(72), 0.0, 0.0)
    ring1.data.materials.append(mat_emerald)

    # Keyframes de animación 3D (frames 1 a 1440)
    for f in range(1, 1441, 60):
        scene.frame_set(f)
        t = f / 60.0
        if p_ovni:
            p_ovni.location.x = 0.45 * math.sin(t * 1.2)
            p_ovni.location.z = 1.50 + 0.12 * math.cos(t * 2.0)
            p_ovni.keyframe_insert(data_path="location", frame=f)
        if p_juancho:
            p_juancho.location.z = 0.25 + 0.06 * math.sin(t * 2.5)
            p_juancho.keyframe_insert(data_path="location", frame=f)
        if p_mapache:
            p_mapache.location.z = 0.15 + 0.06 * math.cos(t * 2.5)
            p_mapache.keyframe_insert(data_path="location", frame=f)
        ring1.rotation_euler.z = t * 1.5
        ring1.keyframe_insert(data_path="rotation_euler", frame=f)

    # Renderizar preview del escenario 3D completo (film_transparent True para RGBA transparente)
    scene.render.film_transparent = True
    world = bpy.data.worlds.new("World_Tampico_Night")
    scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs["Color"].default_value = (0.012, 0.035, 0.065, 1.0)
        bg_node.inputs["Strength"].default_value = 1.0

    stage_preview = os.path.join(RENDERS_DIR, "blender_3d_stage_master.png")
    scene.render.filepath = stage_preview
    bpy.ops.render.render(write_still=True)
    print(f" [OK BLENDER CYCLES RTX 4060] Escenario 3D Master renderizado: {stage_preview}")

    # Guardar archivo .blend oficial
    bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
    print(f" [OK ARCHIVO .BLEND GUARDADO] {BLEND_OUT} en {time.time() - t0:.1f}s")


if __name__ == "__main__":
    build_and_render()
