shader_type canvas_item;

uniform vec2 shadow_offset = vec2(2.0, 2.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    vec2 offset_uv = UV - shadow_offset * TEXTURE_PIXEL_SIZE;
    vec4 shadow = texture(TEXTURE, offset_uv);

    vec4 shadow_col = vec4(shadow_color.rgb, shadow.a * shadow_color.a);

    COLOR = shadow_col * (1.0 - original.a) + original;
}