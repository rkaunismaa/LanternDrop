class_name Lantern
extends RigidBody2D
## One lantern in the jar: a physics circle with a glowing paper-lantern look.
## Merging is decided by MergeRules and handled by main.gd; this node only moves and draws.

var kind := 1
var age := 0.0  ## seconds since this lantern appeared (DangerWatch ignores fresh drops)
var merging := false  ## already promised to a merge this moment

var _visual: Node2D

static var _glow_texture: GradientTexture2D


func setup(p_kind: int) -> void:
	kind = p_kind
	var r := LanternKinds.radius(kind)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = r
	shape.shape = circle
	add_child(shape)
	mass = 1.0 + r * r / 400.0
	lock_rotation = true  # lanterns hang upright; spinning paper looks wrong
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	contact_monitor = true
	max_contacts_reported = 8
	var material := PhysicsMaterial.new()
	material.bounce = 0.05
	material.friction = 0.5
	physics_material_override = material

	var glow := Sprite2D.new()
	glow.texture = glow_texture()
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	glow.modulate = Color(LanternKinds.color(kind), 0.55)
	glow.scale = Vector2.ONE * (r * 4.2) / 256.0
	add_child(glow)

	_visual = Node2D.new()
	_visual.draw.connect(func() -> void: draw_lantern(_visual, kind, Vector2.ZERO, 1.0))
	add_child(_visual)


func _physics_process(delta: float) -> void:
	age += delta


## A quick swell when a merge creates this lantern.
func pop() -> void:
	_visual.scale = Vector2.ONE * 0.6
	create_tween().tween_property(_visual, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Soft round light, shared by every lantern.
static func glow_texture() -> GradientTexture2D:
	if _glow_texture == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.45))
		_glow_texture = GradientTexture2D.new()
		_glow_texture.gradient = g
		_glow_texture.fill = GradientTexture2D.FILL_RADIAL
		_glow_texture.fill_from = Vector2(0.5, 0.5)
		_glow_texture.fill_to = Vector2(1.0, 0.5)
		_glow_texture.width = 256
		_glow_texture.height = 256
	return _glow_texture


## Draw a paper lantern of this kind: glowing paper body, ribs, dark caps and a tassel.
## Shared by lanterns in the jar and the dropper's preview.
static func draw_lantern(ci: CanvasItem, kind: int, center: Vector2, alpha: float) -> void:
	var r := LanternKinds.radius(kind)
	var base := LanternKinds.color(kind)
	var body := base.darkened(0.25)
	body.a = alpha
	var core := base.lightened(0.55)
	core.a = alpha
	var rx := r
	var ry := r * 0.92
	ci.draw_set_transform(center, 0.0, Vector2(1.0, ry / rx))
	ci.draw_circle(Vector2.ZERO, rx, body)
	ci.draw_circle(Vector2(0, -rx * 0.08), rx * 0.62, Color(base, alpha))
	ci.draw_circle(Vector2(0, -rx * 0.12), rx * 0.3, core)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var rib := base.darkened(0.55)
	rib.a = 0.55 * alpha
	for i in range(-2, 3):
		var x := i * rx * 0.36
		var span := sqrt(maxf(rx * rx - x * x, 0.0)) * (ry / rx)
		ci.draw_line(center + Vector2(x, -span * 0.96), center + Vector2(x * 1.08, 0), rib, maxf(1.0, r / 22.0))
		ci.draw_line(center + Vector2(x * 1.08, 0), center + Vector2(x, span * 0.96), rib, maxf(1.0, r / 22.0))
	var cap := Color(0.12, 0.08, 0.06, alpha)
	var cap_w := rx * 0.7
	var cap_h := maxf(3.0, r * 0.14)
	ci.draw_rect(Rect2(center + Vector2(-cap_w / 2, -ry - cap_h * 0.6), Vector2(cap_w, cap_h)), cap)
	ci.draw_rect(Rect2(center + Vector2(-cap_w / 2, ry - cap_h * 0.4), Vector2(cap_w, cap_h)), cap)
	var tassel := base.darkened(0.3)
	tassel.a = alpha
	ci.draw_line(center + Vector2(0, ry + cap_h * 0.6), center + Vector2(0, ry + cap_h * 0.6 + r * 0.35), tassel,
		maxf(1.5, r / 16.0))
