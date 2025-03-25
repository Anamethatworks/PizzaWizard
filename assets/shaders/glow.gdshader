shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D tex;

const float CAR_SCREEN_HEIGHT = 0.614896897588;

void fragment() {
	float a = 0.5 + 0.25 * sin(PI * TIME);
	ALBEDO = vec3(0.9, 1.f, 1.f) * a + (1.f - a) * texture(tex, UV).xyz;

	// Also apply the cutout effect
	float height = (INV_VIEW_MATRIX * vec4(VERTEX, 1.f)).y;
	if (height > 1.f) {
		// Calculate pixel distance from the car's position on the screen
		float dist = sqrt(pow(FRAGCOORD.x - VIEWPORT_SIZE.x * 0.5, 2.f) + pow(FRAGCOORD.y - VIEWPORT_SIZE.y * CAR_SCREEN_HEIGHT, 2.f));
		//float cutout_alpha = sigmoid(dist, 64.f);
		ALPHA = float(dist > 100.f);
	}
}
