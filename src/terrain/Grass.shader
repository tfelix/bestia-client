shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx;

uniform vec3 camera_position = vec3(0.0);
uniform vec4 albedo : hint_color;
uniform sampler2D hide_texture;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;

uniform float displacement_strength : hint_range(0,1) = 1.0;
uniform float scale = 3.0;

uniform float alpha_scissor_threshold : hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform vec4 transmission : hint_color;

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
	return 1.0 - texture(hide_texture, uv_pos).b;
}

vec3 sampled_displacement(vec3 vertex_world) {
	// We assume objects are placed within -25 to 25 in coordinates. Size must be adapted
	// if the field is dynamic in size
	vec2 uv_pos = vec2((vertex_world.x + 25.0) / 50.0, (vertex_world.z + 25.0) / 50.0); 
	
	// We must bring the displacement back into the range from of 0 - 1.0 to -1 - 1.
	// We should not use black a neutral color but rather setup the rendered texture to
	// a value of r and g to 0.5 which means neutral position. But this currently messes
	// up the color mixing of the pusher shaders.
	vec2 sampled = texture(hide_texture, uv_pos).rg;
	
	if(sampled.x == 0.0 && sampled.y == 0.0) {
		return vec3(0.0);
	}
	
	sampled = sampled - 0.5 * 2.0;
	
	return vec3(sampled.x, 0.0, sampled.y);
}

void vertex() {
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 mesh_world = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	
	float sampled_scale = sampled_scale(vertex_world);
	VERTEX *= (scale * sampled_scale);
	float distance_falloff = 1.0 - smoothstep(0.1, 1.0, 0.025 * distance(camera_position, mesh_world));
	
	// If the distance gets to high and effect to little we stop evaluating costly vertex displacements
	if(distance_falloff > 0.01) {
		vec3 large_scale = large_scale_displ(mesh_world, TIME + float(INSTANCE_ID));
		vec3 small_scale = small_scale_displ(mesh_world, TIME);
		vec3 wind = wind_displ();
		vec3 displacement = sampled_displacement(mesh_world) * 3.0 * COLOR.x;
		// VERTEX += displacement;
		VERTEX += (small_scale + large_scale + wind) * displacement_strength * COLOR.x * distance_falloff;
	}
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	// Start with 20% of black from vertex color
	ALBEDO = (albedo.rgb * albedo_tex.rgb) * (0.8 * COLOR.r + 0.2);
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = albedo.a * albedo_tex.a;
	TRANSMISSION = transmission.rgb;
	ALPHA_SCISSOR = alpha_scissor_threshold;
}
