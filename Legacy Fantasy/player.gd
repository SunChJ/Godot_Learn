extends CharacterBody2D

const RUN_SPEED := 160.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.2 # 0~RunSpeed needs 0.2s
const AIR_ACCELERATION := RUN_SPEED / 0.02 # 0~RunSpeed needs 0.2s
const JUMP_VELOCITY := -320.0 # In 2D - Y direction, jump up means -XXX


var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()

func _physics_process(delta: float) -> void:
	# left -> -1 , right -> 1
	# left + right -> 0
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta

	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var shouldJump := can_jump and jump_request_timer.time_left > 0
	
	if shouldJump:
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		jump_request_timer.stop()
		
	if is_on_floor():
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0
	
	var was_on_floor := is_on_floor()
	move_and_slide()
	
	if is_on_floor() != was_on_floor:
		if was_on_floor and not shouldJump:
			coyote_timer.start()
		else:
			coyote_timer.stop()
