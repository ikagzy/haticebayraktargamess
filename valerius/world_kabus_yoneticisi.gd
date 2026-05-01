extends Node3D

@export_category("Kabus ve Zaman Kontrolü")
@export var yagmur_dugumu: GPUParticles3D
@export var donmus_su_damlasi_rengi: Color = Color(0.6, 0.8, 1.0, 0.8)

var donmus_yagmur: GPUParticles3D

func _ready():
	var ortam_sesi = AudioStreamPlayer.new()
	var ses_dosyasi = load("res://models/model/fbx/universfield-horror-background-atmosphere-06-199279.mp3")
	if ses_dosyasi:
		ses_dosyasi.loop = true
		ortam_sesi.stream = ses_dosyasi
		ortam_sesi.bus = "Master"
		ortam_sesi.volume_db = -10.0
		add_child(ortam_sesi)
		ortam_sesi.play()
	
	_donmus_yagmur_olustur()
	
	_surekli_zaman_kirilmasi_efekti()
		
	if not is_instance_valid(OyunVerisi):
		return
		
	if OyunVerisi.get("kabus_gordu") == true:
		_yagmuru_dondur()
		
		if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
			get_node("/root/GorevArayuzu")._on_gorev_guncellendi("Görev: Etrafı Araştır")

	if OyunVerisi.get("ormana_gecis_tamamlandi") == true:
		var oyuncu = get_tree().get_first_node_in_group("Player")
		if not oyuncu:
			oyuncu = get_node_or_null("CharacterBody3D")
		if oyuncu:
			oyuncu.global_position = Vector3(-45.397, -1.5, -51.504)
		
		OyunVerisi.ormana_gecis_tamamlandi = false
		
		if is_instance_valid(get_node_or_null("/root/GorevArayuzu")):
			get_node("/root/GorevArayuzu")._on_gorev_guncellendi("Görev: Şehrin ortasındaki garip ormanın içine gir")

func _donmus_yagmur_olustur():
	var damla_mat = StandardMaterial3D.new()
	damla_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	damla_mat.albedo_color = Color(0.75, 0.92, 1.0, 0.55)
	damla_mat.emission_enabled = true
	damla_mat.emission = Color(0.8, 0.95, 1.0)
	damla_mat.emission_energy_multiplier = 0.6
	damla_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	var damla_mesh = QuadMesh.new()
	damla_mesh.size = Vector2(0.08, 0.6)
	damla_mesh.surface_set_material(0, damla_mat)
	
	donmus_yagmur = GPUParticles3D.new()
	donmus_yagmur.name = "DonmusYagmur"
	donmus_yagmur.amount = 25000
	donmus_yagmur.lifetime = 10.0
	donmus_yagmur.explosiveness = 1.0
	donmus_yagmur.speed_scale = 0.01
	donmus_yagmur.emitting = true
	donmus_yagmur.one_shot = false
	donmus_yagmur.draw_pass_1 = damla_mesh
	
	donmus_yagmur.visibility_aabb = AABB(Vector3(-100, -100, -100), Vector3(200, 200, 200))
	
	donmus_yagmur.top_level = true
	
	var process_mat = ParticleProcessMaterial.new()
	
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(80, 30, 80)

	
	process_mat.direction = Vector3(0, -1, 0)
	process_mat.spread = 3.0
	process_mat.initial_velocity_min = 1.0
	process_mat.initial_velocity_max = 3.0
	process_mat.gravity = Vector3(0.0, -0.5, 0.0)
	
	process_mat.angle_min = -15.0
	process_mat.angle_max = 15.0
	
	donmus_yagmur.process_material = process_mat
	add_child(donmus_yagmur)
	
	set_process(true)

func _process(_delta):
	if is_instance_valid(donmus_yagmur):
		var oyuncu = get_tree().get_first_node_in_group("Player")
		if not oyuncu:
			oyuncu = get_node_or_null("../CharacterBody3D")
		if oyuncu:
			donmus_yagmur.global_position = oyuncu.global_position + Vector3(0, 12, 0)

func _surekli_zaman_kirilmasi_efekti():
	var canvas = CanvasLayer.new()
	canvas.layer = 90
	add_child(canvas)
	
	var soldurucu = ColorRect.new()
	soldurucu.set_anchors_preset(Control.PRESET_FULL_RECT)
	soldurucu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(soldurucu)
	
	var shader_kodu = """
	//Ekran filtresi (Kagan)
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float shatter_amount : hint_range(0.0, 1.0) = 0.0;
uniform float aberration_amount : hint_range(0.0, 5.0) = 0.0;

float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

void fragment() {
	float kose_maskes = step(0.65, SCREEN_UV.y) * step(SCREEN_UV.x, 0.35);
	
	vec2 grid = floor(SCREEN_UV * 10.0);
	vec2 offset = vec2(rand(grid) - 0.5, rand(grid + vec2(1.0)) - 0.5)
		* 0.035 * shatter_amount * kose_maskes;
	
	float ab = aberration_amount * 0.004 * kose_maskes;
	float r = texture(screen_texture, SCREEN_UV + offset + vec2(ab, 0.0)).r;
	float g = texture(screen_texture, SCREEN_UV + offset).g;
	float b = texture(screen_texture, SCREEN_UV + offset - vec2(ab, 0.0)).b;
	
	vec3 color = vec3(r, g, b);
	
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	color = vec3(gray);
	
	COLOR = vec4(color, 1.0);
}
"""
	var shader = Shader.new()
	shader.code = shader_kodu
	
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("shatter_amount", 0.8)
	mat.set_shader_parameter("aberration_amount", 2.5)
	soldurucu.material = mat
	
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/shatter_amount", 0.25, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/aberration_amount", 1.0, 2.0)

	var oyuncu = get_tree().get_first_node_in_group("Player")
	if not oyuncu:
		oyuncu = get_node_or_null("../CharacterBody3D")
		
	if oyuncu:
		var kamera = oyuncu.get_node_or_null("head/Camera3D")
		if kamera:
			var sarsinti = create_tween().set_loops(12)
			var base_rot = kamera.rotation.z
			var titreme_siddeti = deg_to_rad(1.2)
			sarsinti.tween_property(kamera, "rotation:z", base_rot + titreme_siddeti, 0.04)
			sarsinti.tween_property(kamera, "rotation:z", base_rot - titreme_siddeti, 0.04)
			
			get_tree().create_timer(0.6).timeout.connect(func():
				if sarsinti.is_valid():
					sarsinti.kill()
				create_tween().tween_property(kamera, "rotation:z", base_rot, 0.15)
			)

func _yagmuru_dondur():
	if is_instance_valid(yagmur_dugumu):
		yagmur_dugumu.speed_scale = 0.0
		var material = yagmur_dugumu.draw_pass_1.surface_get_material(0)
		if material and material is StandardMaterial3D:
			material.emission_enabled = true
			material.emission = donmus_su_damlasi_rengi
			material.emission_energy_multiplier = 2.0
	
	if is_instance_valid(donmus_yagmur):
		var mat = donmus_yagmur.draw_pass_1.surface_get_material(0)
		if mat:
			mat.emission_energy_multiplier = 1.5
			mat.albedo_color = Color(0.85, 0.97, 1.0, 0.75)
