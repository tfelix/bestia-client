shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform float rim : hint_range(0,1);
uniform float rim_tint : hint_range(0,1);
uniform sampler2D texture_rim : hint_white;
uniform float clearcoat : hint_range(0,1);
uniform float clearcoat_gloss : hint_range(0,1);
uniform sampler2D texture_clearcoat : hint_white;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform vec3 camera_position = vec3(0.0);
uniform float wind_strenght : hint_range(0,1) = 1.0;

vec3 wind_displ() {
	return vec3(0.0);
}

vec3 large_scale_displ(vec3 mesh_world_pos, float time) {
	float x = 2.0 * sin(1.0 * (mesh_world_pos.x + mesh_world_pos.y + mesh_world_pos.z + time)) + 1.0;
	float z = 1.0 * sin(2.0 * (mesh_world_pos.x + mesh_world_pos.y + mesh_world_pos.z + time)) + 0.5;
	
	return vec3(x, 0.0, z) * 0.5;
}

vec3 small_scale_displ(vec3 vertex, float time) {
	float d = 0.1 * sin(2.65 * (vertex.x + vertex.y + vertex.z + time));
	
	return vec3(1.0, 0.35, 1.0) * d;
}

float sampled_scale(vec3 vertex_world) {
	// We assume objects are placed within -25 to 25 in coordinates. Size must be adapted
	// if the field is dynamic in size
	vec2 uv_pos = vec2((vertex_world.x + 25.0) / 50.0, (vertex_world.z + 25.0) / 50.0); 
	
	// we must invert this channel as 0 means no change and blue means no grass at all.
	return 1.0; // - texture(hide_texture, uv_pos).b;
}


void vertex() {
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 mesh_world = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	
	float distance_falloff = 1.0 - smoothstep(0.1, 1.0, 0.025 * distance(camera_position, mesh_world));
	
	// If the distance gets to high and effect to little we stop evaluating costly vertex displacements
	if(distance_falloff > 0.01) {
		vec3 large_scale = large_scale_displ(mesh_world, TIME + float(INSTANCE_ID));
		vec3 small_scale = small_scale_displ(mesh_world, TIME);
		vec3 wind = wind_displ();
		VERTEX += wind_strenght * (small_scale + large_scale + wind) * COLOR.x * distance_falloff;
	}
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = (albedo.rgb * albedo_tex.rgb) * (0.8 * COLOR.r + 0.2);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	vec2 rim_tex = texture(texture_rim,base_uv).xy;
	RIM = rim*rim_tex.x;	RIM_TINT = rim_tint*rim_tex.y;
	vec2 clearcoat_tex = texture(texture_clearcoat,base_uv).xy;
	CLEARCOAT = clearcoat*clearcoat_tex.x;	CLEARCOAT_GLOSS = clearcoat_gloss*clearcoat_tex.y;
}
