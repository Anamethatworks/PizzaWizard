shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D tex;

const float CAR_SCREEN_HEIGHT = 0.638388959237;

float sigmoid(float x, float mid) {
	float y = x - mid;
	y /= 10.f;
	return 0.5 * (1.f + y / sqrt(1.f + y * y));
}

void fragment() {
	float a = 0.5 + 0.25 * sin(PI * TIME);
	ALBEDO = vec3(0.9, 1.f, 1.f) * a + (1.f - a) * texture(tex, UV).xyz;

	// Also apply the cutout effect
	float dist = sqrt(pow(FRAGCOORD.x - VIEWPORT_SIZE.x * 0.5, 2.f) + pow(FRAGCOORD.y - VIEWPORT_SIZE.y * CAR_SCREEN_HEIGHT, 2.f));
	ALPHA = sigmoid(dist, 100.f);
}
