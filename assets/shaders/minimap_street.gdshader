shader_type spatial;
render_mode unshaded, world_vertex_coords;

void vertex() {
	// Called for every vertex the material is visible on.
	if (VERTEX.y > 0.01) {
		COLOR = vec4(0.7, 0.7, 0.7, 1.0);
	} else {
		COLOR = vec4(0.4, 0.4, 0.4, 1.0);
	}
}

void fragment() {
	ALBEDO = COLOR.xyz;
}
