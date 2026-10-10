shader_type canvas_item;

uniform float bend_amount : hint_range(-1.0, 1.0) = 0.2;
uniform float curve_power : hint_range(1.0, 4.0) = 2.0;

void vertex() {
    // CanvasItem UV runs from 0.0 at the top to 1.0 at the bottom.
    // 1.0 - UV.y anchors the bottom (0.0 bend at base) and bends higher toward the top.
    float height_factor = 1.0 - UV.y;
    
    // Apply polynomial curve deformation along the X axis based on height
    VERTEX.x += pow(height_factor, curve_power) * bend_amount * 50.0;
}