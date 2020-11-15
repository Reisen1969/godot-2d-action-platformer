class_name Player
extends Actor

signal ammo_changed(new_ammo)

const FLOOR_NORMAL := Vector2.UP
const GRAVITY := 1800
const JUMP_SPEED := -900
const DASH_SPEED := 2400

export (Array, PackedScene) var available_guns_scenes
var available_guns := []

var gun : Gun
var gun_index := 0

var velocity := Vector2.ZERO
var aim_direction := Vector2.RIGHT
var gravity_modifier := 1.0
var facing_direction := 1

onready var body = $Body
onready var gun_position = $Body/GunPosition


func _ready() -> void:
	for gun_scene in available_guns_scenes:
		var new_gun : Gun = gun_scene.instance()
		new_gun.connect("ammo_changed", self, "_on_gun_ammo_changed")
		available_guns.append(new_gun)
		
	gun = available_guns[0]
	gun_position.add_child(gun)


func _input(event) -> void:
	if event.is_action_pressed("Shoot"):
		gun.shoot_pressed()
	elif event.is_action_released("Shoot"):
		gun.shoot_released()
	
	if event.is_action_pressed("ChangeWeapon"):
		_set_gun(gun_index+1)


func _set_gun(index := 0) -> void:
	gun_position.remove_child(gun)
	gun_index = wrapi(index, 0, available_guns.size())
	gun = available_guns[gun_index]
	gun_position.add_child(gun)
	emit_signal("ammo_changed", gun.ammo)


func _physics_process(delta) -> void:
	
	if aim_direction.x != 0.0:
		facing_direction = sign(aim_direction.x)
	body.scale.x = facing_direction
	
	gun.direction = aim_direction
	
	velocity.y += GRAVITY * gravity_modifier * delta
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	get_global_mouse_position()


func _on_gun_ammo_changed(new_ammo):
	emit_signal("ammo_changed", new_ammo)
