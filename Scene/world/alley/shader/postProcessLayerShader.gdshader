shader_type canvas_item;

uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    float noise = random(UV + vec2(TIME, 0.0));
    vec2 center_uv = UV - vec2(0.5);
    float dist = length(center_uv);
    float vignette = smoothstep(0.5, 1.5 - vignette_intensity, dist);

    // Darkens the corners and adds grain
    COLOR = vec4(0.0, 0.0, 0.0, (dist * vignette_intensity) + (noise * grain_amount));
}