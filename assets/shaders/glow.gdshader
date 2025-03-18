shader_type spatial;
render_mode unshaded;

void fragment() {
	ALBEDO = vec3(0.9, 1.0, 1.0);
	ALPHA = 0.5 + 0.25 * sin(PI * TIME);
}
