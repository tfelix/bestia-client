shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,depth_test_disable,shadows_disabled,ambient_light_disabled;

uniform bool is_circular = false;

float circle(in vec2 _st, in float _radius){
    vec2 dist = _st - vec2(0.5);
	return 1. - smoothstep(_radius - (_radius * 0.01),
                         _radius + (_radius * 0.01),
                         dot(dist, dist) * 4.0);
}

void fragment() {
	ALBEDO = vec3(0.0, 0.0, 0.0);
	if(is_circular) {
		// float pct = distance(UV, vec2(0.5)) * 2.0;
		ALBEDO.b = circle(UV, 0.9);
	} else {
		// bottom-left
		vec2 bl = smoothstep(vec2(0.0), vec2(0.05), UV);
		float pct = bl.x * bl.y;
		// top-right
		vec2 tr = smoothstep(vec2(0.0), vec2(0.05), vec2(1.0) - UV);
		pct *= tr.x * tr.y;
		ALBEDO.b = pct;
	}
}
