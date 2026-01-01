shader_type canvas_item;

uniform sampler2D noise_texture: repeat_enable, filter_nearest;
uniform float density: hint_range(0.0, 1.0) = 0.25;
uniform vec2 speed = vec2(0.02, 0.01);

void fragment() {
    vec2 uv1 = UV + TIME * speed;
    vec2 uv2 = UV + TIME * (speed * -0.5);
    float noise1 = texture(noise_texture, uv1).r;
    float noise2 = texture(noise_texture, uv2).r;
    float fog = mix(noise1, noise2, 0.5);
    COLOR = vec4(0.8, 0.8, 0.9, fog * density);
}