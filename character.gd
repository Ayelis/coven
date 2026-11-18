extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float = 100
@export var depth: float = 0 # How far into the scenery
@onready var animation_player = $AnimationPlayer
@onready var character_sprite = $CharacterSprite

enum State {IDLE, WALK, ATTACK, JUMP}
var state = State.IDLE
var walkinOverHere = false

#every frame
func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	flip_sprites()
	move_and_slide()

func handle_movement():
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
		if walkinOverHere == true:
			state = State.WALK
	else:
		velocity = Vector2.ZERO

func handle_input() -> void:
	#get a normalized (0-1) movement direction
	#position += Vector2.RIGHT
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#aim... and FIRE!
	if can_move() and direction.y != 0: #walk into 3d scene
		#4 directions: position += direction * delta * speed
		# Slow down vertical (depth) movement to match 2.5D perspective
		depth=100*depth
		depth -= direction.y
		depth=depth/100
		depth = clamp(depth,0,2)
		direction.y *= 0
		walkinOverHere = true
	else:
		walkinOverHere = false
	velocity = direction * speed
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	if Input.is_action_just_pressed("jump"):
		state = State.JUMP

func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
	
func handle_animations() -> void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")
	elif state == State.ATTACK:
		animation_player.play("punch")
	elif state == State.JUMP:
		animation_player.play("jump")

func can_move():
	return state == State.IDLE or  state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or  state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or  state == State.WALK

func can_jumpkick() -> bool:
	return state == State.JUMP

func can_double_jump() -> bool:
	return state == State.JUMP

func on_action_complete() -> void:
	state = State.IDLE
