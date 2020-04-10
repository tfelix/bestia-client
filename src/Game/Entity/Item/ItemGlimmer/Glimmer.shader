shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled,ambient_light_disabled;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

void vertex() {
	// UV=UV*uv1_scale.xy+uv1_offset.xy;
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
}

void fragment() {
	float rotation = 45.0;
	vec2 rel = UV - vec2(0.5, 0.5);
	// float angle = length(rel) * rotation;
	float angle = rotation;
	mat2 rot = mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	
	vec2 base_uv = rel * rot;
	base_uv = clamp(rel + vec2(0.5,0.5), vec2(0,0), vec2(1,1));
	
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
