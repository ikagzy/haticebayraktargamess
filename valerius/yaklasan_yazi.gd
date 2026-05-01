@tool
extends Area3D

@export_category("Yaklaşınca Beliren Yazı")
@export_multiline var metin: String = "BANA YARDIM ET"
@export var renk: Color = Color(0.6, 0.0, 0.0)
@export var yazi_boyutu: int = 72
@export var gecis_hizi: float = 1.5
@export var gorus_mesafesi: float = 4.0

@onready var label = $Label3D

var tween: Tween

func _ready():
	if not Engine.is_editor_hint():
		if label:
			label.text = metin
			label.modulate = renk
			label.modulate.a = 0.0
			label.font_size = yazi_boyutu
			label.outline_size = 6
			label.outline_modulate = Color(0, 0, 0, 1)
			
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if Engine.is_editor_hint(): return
	if body is CharacterBody3D or body.is_in_group("Player"):
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, gecis_hizi).set_trans(Tween.TRANS_SINE)

func _on_body_exited(body):
	if Engine.is_editor_hint(): return
	if body is CharacterBody3D or body.is_in_group("Player"):
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, gecis_hizi).set_trans(Tween.TRANS_SINE)

func _process(_delta):
	if Engine.is_editor_hint() and label:
		label.text = metin
		label.modulate = renk
		label.font_size = yazi_boyutu
		if has_node("CollisionShape3D") and $CollisionShape3D.shape:
			$CollisionShape3D.shape.size = Vector3(gorus_mesafesi, gorus_mesafesi, gorus_mesafesi)
