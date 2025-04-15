shader_type spatial;
render_mode unshaded;

uniform vec3 col;

void fragment() {
	ALBEDO = col;
}
