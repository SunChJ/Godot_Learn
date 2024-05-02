extends CharacterBody2D

const RUN_SPEED := 160.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.2 # 0~RunSpeed needs 0.2s
const AIR_ACCELERATION := RUN_SPEED / 0.02 # 0~RunSpeed needs 0.2s
const JUMP_VELOCITY := -320.0 # In 2D - Y direction, jump up means -XXX


var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# left -> -1 , right -> 1
	# left + right -> 0
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		
	if is_on_floor():
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0
	
	move_and_slide()
