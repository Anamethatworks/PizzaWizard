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
	// Use the texture tex for the model.
	ALBEDO = texture(tex, UV).xyz;

	//float height = (INV_VIEW_MATRIX * vec4(VERTEX, 1.f)).y;
	//if (height > 1.f) {
	// Calculate pixel distance from the car's position on the screen
	float dist = sqrt(pow(FRAGCOORD.x - VIEWPORT_SIZE.x * 0.5, 2.f) + pow(FRAGCOORD.y - VIEWPORT_SIZE.y * CAR_SCREEN_HEIGHT, 2.f));
	ALPHA = sigmoid(dist, 100.f);
	//ALPHA = float(dist > 100.f);


}
