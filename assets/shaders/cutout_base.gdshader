shader_type spatial;
render_mode world_vertex_coords, cull_disabled, unshaded;

uniform sampler2D tex;

const float CAR_SCREEN_HEIGHT = 0.614896897588;

void fragment() {
	ALBEDO = vec3(0.f, 0.f, 0.f);
	float dist = sqrt(pow(FRAGCOORD.x - VIEWPORT_SIZE.x * 0.5, 2.f) + pow(FRAGCOORD.y - VIEWPORT_SIZE.y * CAR_SCREEN_HEIGHT, 2.f));
	//float cutout_alpha = sigmoid(dist, 64.f);
	ALPHA = float(dist <+ 100.f);
}
