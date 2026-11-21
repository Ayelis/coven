extends Camera2D

@export var player: CharacterBody2D
@export var bg: Node2D

func _process(_delta:float) -> void:
	var scenery = bg.find_child("Backgrounds")
	var _lane_x: float = 0.5 
	#1376.768
	#470.260
	#var zooms = (abs(snapped((player.position.y - 155)/102,0.01)-1))*2.5+1 #[1.0 - 3.5]
	var player_y = player.depth #[0.0 - 1.8]
	# Use pow() > 1.0 so the near court moves steadily and the far court matches its pace
	var perspective_curve = 1.1 # Try values between 1.5 and 2.5
	var curved_depth = pow(player_y, perspective_curve)

	var zooms = snapped((curved_depth * 2.5) + 1.0, 0.01)
	scenery.scale = Vector2(zooms, zooms)
	
		# 1. Normalize player_depth (assuming 0.0 is front, 2.0 is max back)
	var _depth_progress = clamp(player_y / 2.0, 0.0, 1.0)
	#curved_depth = pow(depth_progress, 1.1) #1.25

	# 2. Expand horizontal player boundaries based on depth
	#-300 - 780
	#-1800 - 3100
	#235 - mid_x
	var min_x = lerp(23.0, -300.0, curved_depth)
	var max_x = lerp(445.0, 780.0, curved_depth)#var max_x = lerp(445.0, 3100.0, curved_depth)
	var _foreground_x = (player.position.x/(max_x - min_x)*422)+23

	player.position.x = clamp(player.position.x, min_x, max_x)
	
	# 3. Smoothly shift camera from locked center (234.0) to following player.position.x
	var screen_center_x = 234.0 # Halfway between 23 and 445
	#var screen_center_x = (max_x-min_x) /2
	var target_cam_x = lerp(screen_center_x, player.position.x, curved_depth)

	# 4. Clamp camera so it never shows past the edges of the scaled background
	var cam_limit_left = lerp(screen_center_x, -300.0, curved_depth) # Adjust -1600 to match art edge
	var cam_limit_right = lerp(screen_center_x, 780.0, curved_depth) # Adjust 2900 to match art edge
	
	#print("ppx",player.position.x,"cpx",camera.position.x)
	position.x = clamp(target_cam_x, cam_limit_left, cam_limit_right)
	
