shader_type canvas_item;

uniform float intensity      : hint_range(0.0, 1.0)  = 0.4;
uniform float softness       : hint_range(0.0, 1.0)  = 0.3;
uniform float scroll_speed   : hint_range(-2.0, 2.0) = 0.1;
uniform vec4  vignette_color : source_color           = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // Scroll only X — UV.y stays fixed, so the vignette won't drift
    vec2 scroll_uv = vec2(UV.x - TIME * scroll_speed, UV.y);
    vec4 tex = texture(TEXTURE, scroll_uv);

    // Top/bottom only: 0.0 at center, 1.0 at top and bottom edges
    float dist_y = abs(UV.y - 0.5) * 2.0;

    // intensity pushes the vignette inward; softness controls gradient width
    float edge = 1.0 - intensity;
    float vignette = smoothstep(edge - softness * 0.5, edge + softness * 0.5, dist_y);

    // Blend vignette color over the texture
    COLOR = mix(tex, vec4(vignette_color.rgb, 1.0), vignette * vignette_color.a);
}