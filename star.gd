extends Area2D

signal clicked(me)

signal hit_ally
signal hit_enemy

@export var power = 10
@export var speed = 100
var velocity = Vector2.ZERO
var color = "white"

var base_scale = Vector2(0.02,0.02)
func scaling_function(power):
	return power**(1.0/4.0)

var color_dict = {
	"white": Color.WHITE,
	"black": Color.BLACK,
	"red" : Color.RED,
	"green" : Color.GREEN,
	"blue" : Color.BLUE
}

var target = position
var parent = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$StarTimer.start()
	$Sprite2D.scale = base_scale * scaling_function(power)
	$Sprite2D.modulate = color_dict[color]
	$Label.text = str(power)
	target = position
	await get_tree().create_timer(1).timeout
	parent = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position != target:
		position = position.move_toward(target, speed * delta)
	$SelectionSprite.rotation += 1 * delta

func _on_star_timer_timeout():
	update_power(power+1)
	
func update_label(text):
	$Label.text = text
	
func update_color(color):
	$Sprite2D.modulate = color

func show_selected():
	$SelectionSprite.visible = true
	
func hide_selected():
	$SelectionSprite.visible = false

func stop_growth():
	$StarTimer.stop()
	
func set_target(pos):
	target = pos
	
func update_power(new_power):
	power = new_power
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", base_scale * scaling_function(power), 1)
	$Label.text = str(power)

func _on_area_entered(area):
	print(self)
	print(area)
	print(self.parent)
	print(area.parent)
	if area.parent == self or self.parent == area:
		pass
	elif position != target and area.position != area.target:
		if color == area.color:
			if power > area.power:
				call_deferred("update_power", power + area.power)
			if power < area.power:
				call_deferred("queue_free")
			if power == area.power:
				pass
		elif color != area.color:
			if power > area.power:
				call_deferred("update_power", power - area.power)
			if power <= area.power:
				call_deferred("queue_free")
	elif position != target and area.position == area.target:
		if color == area.color:
			call_deferred("queue_free")
		elif color != area.color:
			if power > area.power:
				call_deferred("update_power", power - area.power)
				$StarTimer.start()
			if power <= area.power:
				call_deferred("queue_free")
	elif position == target and area.position != area.target:
		if color == area.color:
			call_deferred("update_power", power + area.power)
		elif color != area.color:
			if power >= area.power:
				call_deferred("update_power", power - area.power)
			if power < area.power:
				call_deferred("queue_free")

func _on_control_gui_input(event):
	if event.is_action_pressed("mouse_click"):
		clicked.emit(self)
