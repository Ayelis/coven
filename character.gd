extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float = 100
@export var depth: float = 0 # How far into the scenery
@onready var animation_player = $AnimationPlayer
@onready var character_sprite = $CharacterSprite

enum State {IDLE, WALK}
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
	if velocity.length() == 0:
		state = State.IDLE
	else:
		state = State.WALK
	if walkinOverHere == true:
		state = State.WALK

func handle_input() -> void:
	#get a normalized (0-1) movement direction
	#position += Vector2.RIGHT
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#aim... and FIRE!
	#position += direction * delta * speed
	# Slow down vertical (depth) movement to match 2.5D perspective
	depth=100*depth
	depth -= direction.y
	depth=depth/100
	depth = clamp(depth,0,2)
	if direction.y != 0:
		direction.y *= 0
		walkinOverHere = true
	else:
		walkinOverHere = false
	velocity = direction * speed

func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
	
func handle_animations() -> void:
	if state == State.IDLE:
		animation_player.play("idle")
	else:
		animation_player.play("walk")
