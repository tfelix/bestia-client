shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D displacement_map;

uniform float point_size : hint_range(0,128);
uniform vec3 camera_position = vec3(0.0);
uniform float wind_strenght : hint_range(0,1) = 1.0;
uniform float max_rotation : hint_range(0, 0.3) = 0.2;

const float PI2 = 2.0 * 3.1415926;

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

vec3 rotate_about_axis(vec3 v, float angle, vec3 normalized_axis, vec3 pivot) {
	vec3 shifted_v = v - pivot; 
	
	shifted_v = shifted_v * cos(angle) + cross(normalized_axis, shifted_v) * sin(angle) 
		+ normalized_axis * (dot(normalized_axis, shifted_v)) * (1.0 - cos(angle));
	
	return shifted_v + pivot;
}

void vertex() {
	mat4 model_matrix = inverse(WORLD_MATRIX);
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 mesh_world = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	
	vec2 mesh_world_uv = (mesh_world.xz + vec2(25.0)) / 50.0;
	
	vec3 displacement_sample = texture(displacement_map, mesh_world_uv).rgb;
	float hide = displacement_sample.b;
	// We must correct back again to our vector space
	vec2 displacement = displacement_sample.rg * 2.0 - vec2(1.0);
	
	if(hide > 0.1) {
		VERTEX = vec3(0.0);
	} else {
		float rotation_angle = length(displacement) * max_rotation * PI2;
		
		float d = vertex_world.y - mesh_world.y;
		vec3 pivot_point = vec3(vertex_world.x, vertex_world.y - d, vertex_world.z);
		
		vec3 rotation_axis = normalize(cross(vec3(displacement.x, 0.0, displacement.y), vec3(0.0, -1.0, 0.0)));
		
		rotation_angle = rotation_angle * COLOR.r;
		vec3 rotated = rotate_about_axis(vertex_world, rotation_angle, rotation_axis, pivot_point);
		
		// Add wind influence
		vec3 wind_displ = (large_scale_displ(mesh_world, TIME) + small_scale_displ(VERTEX, TIME)) * COLOR.r * wind_strenght;
		
		VERTEX = (model_matrix * vec4(rotated, 1.0)).xyz * 3.0 + wind_displ;
	}
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a;
	ALPHA_SCISSOR = 0.97;
}
