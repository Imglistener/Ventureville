shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 20.0) = 4.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    float px = blur_amount / float(textureSize(screen_texture, 0).x);

    vec4 color = vec4(0.0);
    color += texture(screen_texture, SCREEN_UV + vec2(-2.0 * px, 0.0)) * 0.06136;
    color += texture(screen_texture, SCREEN_UV + vec2(-1.0 * px, 0.0)) * 0.24477;
    color += texture(screen_texture, SCREEN_UV + vec2( 0.0,      0.0)) * 0.38774;
    color += texture(screen_texture, SCREEN_UV + vec2( 1.0 * px, 0.0)) * 0.24477;
    color += texture(screen_texture, SCREEN_UV + vec2( 2.0 * px, 0.0)) * 0.06136;

    COLOR = color;
}