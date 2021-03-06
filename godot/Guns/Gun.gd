class_name Gun
extends Node2D

enum MODE { NORMAL, AUTOMATIC, CHARGE }

export (PackedScene) var bullet_scene
export var shoot_rate := 0.25
export (MODE) var mode := MODE.NORMAL
export var max_charge_time := 2.0
export var spread_angle := 0.0

var direction := Vector2.ZERO
var charge_time := 0.0
var is_charging := false

onready var _shoot_timer := $ShootTimer
onready var _shoot_position := $ShootPosition


func _ready():
	_shoot_timer.wait_time = shoot_rate
	randomize()


func _physics_process(delta: float) -> void:
	var angle = Vector2(abs(direction.x), direction.y).angle()
	rotation = angle

	match mode:
		MODE.NORMAL:
			if Input.is_action_just_pressed("shoot") and _can_shoot():
				_shoot()
		MODE.AUTOMATIC:
			if Input.is_action_pressed("shoot") and _can_shoot():
				_shoot()
		MODE.CHARGE:
			if Input.is_action_pressed("shoot") and _can_shoot():
				is_charging = true
			if Input.is_action_just_released("shoot") and is_charging:
				is_charging = false
				_shoot()
			if is_charging:
				charge_time = min(charge_time + delta, max_charge_time)


func _shoot() -> void:
	_shoot_timer.start()

	var bullet = bullet_scene.instance()
	bullet.direction = direction.rotated(rand_range(-spread_angle, spread_angle))
	Projectiles.add_child(bullet)
	bullet.global_position = _shoot_position.global_position

	if "charge" in bullet:
		bullet.charge = charge_time / max_charge_time

	charge_time = 0.0


func _can_shoot() -> bool:
	return _shoot_timer.is_stopped()
