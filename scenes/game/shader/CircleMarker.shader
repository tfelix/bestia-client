shader_type spatial;
render_mode shadows_disabled;

vec3 rgb(float r, float g, float b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec4 circle(vec2 uv, vec3 color) {
	float radiusInner = 0.9 / 2.0;
	float radiusOuter = 1.0 / 2.0;
	float d = length(uv - vec2(0.5, 0.5));
	
	if(d > radiusInner && d < radiusOuter) {
		return vec4(color, 1.0);
	} else {
		return vec4(color, 0.0);
	}
}

void fragment() {
	vec2 uv = UV;
	
	// Circle
	vec3 red = rgb(225.0, 200.0, 0.0);
	vec4 circleColor = circle(uv, red);
	
	// Blend the two
	ALBEDO = circleColor.xyz;
	ALPHA = circleColor.a;
}