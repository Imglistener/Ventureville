// button_slide.gdshader
shader_type canvas_item;
uniform float offset_x : hint_range(-500.0, 500.0) = 0.0;

void vertex() {
    VERTEX.x += offset_x;
}