extends CharacterBody2D

const GRAVITY:= 600

@export var health: int = 30
@export var damage: int = 4
@export var jump_intensity: float = 150
@export var speed: float = 100
@export var depth: float = 0 # How far into the scenery

@onready var animation_player = $AnimationPlayer
@onready var character_sprite = $CharacterSprite

enum State {IDLE, WALK, ATTACK, JUMPKICK, TAKEOFF, JUMP, LAND, TAKEOFF2, DJUMP}
var anim_map:={
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.JUMPKICK: "jumpkick",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.TAKEOFF2: "takeoff2",
	State.DJUMP: "djump",
	State.LAND: "land"
}
var state = State.IDLE
var walkinOverHere = false
var lastState = state
var height:= 0.0
var height_speed:= 0.0

#every frame
func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(_delta)
	character_sprite.position = Vector2.UP * height
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
	if(state != lastState):
		print(state)
		lastState=state

func handle_input() -> void:
	#get a normalized (0-1) movement direction
	#position += Vector2.RIGHT
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#aim... and FIRE!
	if direction.y != 0: #walk into 3d scene
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
	if Input.is_action_just_pressed("attack") && can_attack():
		state = State.ATTACK
	if Input.is_action_just_pressed("attack") && can_jumpkick():
		state = State.JUMPKICK
	if Input.is_action_just_pressed("jump") && (can_jump()):
		state = State.TAKEOFF
	if Input.is_action_just_pressed("jump") && (can_double_jump()):
		state = State.TAKEOFF2

func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
	
func handle_animations() -> void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

func handle_air_time(delta:float) -> void:
	if state == State.JUMP or state == State.DJUMP or state == State.JUMPKICK:
		height += height_speed * delta
		if height<0:
			height = 0
			state = State.LAND
		else:
			height_speed -= GRAVITY * delta

func can_move():
	return state == State.IDLE or state == State.WALK
func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK
func can_double_jump() -> bool:
	return state == State.JUMP
func can_jumpkick() -> bool:
	return state == State.JUMP or state == State.DJUMP
func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity
func on_takeoff2_complete() -> void:
	state = State.DJUMP
	height_speed = jump_intensity

func on_action_complete() -> void:
	state = State.IDLE
