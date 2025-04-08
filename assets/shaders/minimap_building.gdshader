shader_type spatial;
render_mode unshaded, world_vertex_coords;

void vertex() {
	COLOR.r = VERTEX.y + 2.0;
}

void fragment() {
	float val = COLOR.r * 0.15 + 0.1;
	ALBEDO = vec3(val, val, val);
}
