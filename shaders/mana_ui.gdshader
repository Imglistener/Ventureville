shader_type canvas_item;

uniform float saturation : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate luminance using standard weights
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Mix between grayscale and original color based on saturation
    vec3 saturated = mix(vec3(gray), tex_color.rgb, saturation);
    
    COLOR = vec4(saturated, tex_color.a);
}