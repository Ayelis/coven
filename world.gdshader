shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 target_resolution = vec2(470.0, 260.0);

void fragment() {
    // Snap the screen UVs to a strict 470x260 grid
    vec2 pixelated_uv = (floor(SCREEN_UV * target_resolution) + 0.5) / target_resolution;
    
    // Sample the already-rendered background at the snapped coordinate
    COLOR = texture(screen_texture, pixelated_uv);
}
