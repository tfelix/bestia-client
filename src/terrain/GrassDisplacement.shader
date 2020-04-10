shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,depth_test_disable,shadows_disabled,ambient_light_disabled;

float circle(in vec2 _st, in float _radius){
    vec2 dist = _st - vec2(0.5);
	return 1. - smoothstep(_radius - (_radius * 0.01),
                         _radius + (_radius * 0.01),
                         dot(dist, dist) * 4.0);
}

void fragment() {
	const vec2 center = vec2(1.0);
	vec2 cs_pos = (vec2(0.5) - UV) * 2.0;
	
	vec2 pos = (cs_pos + 1.0) / 2.0;
	float d = smoothstep(1.0, 0.0, length(cs_pos));
	
	ALBEDO = vec3(pos.x * d, pos.y * d, 0.0);
	ALPHA = d;
}
