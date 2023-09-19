shader_type canvas_item;

uniform vec4 color: source_color;
uniform float multipler = 0.2;
uniform float softnes = 2;

void fragment() {
    float value = distance(UV, vec2(0.5));
	COLOR = vec4(color.rgb, smoothstep(multipler, softnes, value));
}
