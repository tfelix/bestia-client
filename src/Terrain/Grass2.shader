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

float sampled_scale(vec3 vertex_world) {
	// We assume objects are placed within -25 to 25 in coordinates. Size must be adapted
	// if the field is dynamic in size
	vec2 uv_pos = vec2((vertex_world.x + 25.0) / 50.0, (vertex_world.z + 25.0) / 50.0); 
	
	// we must invert this channel as 0 means no change and blue means no grass at all.
	return 1.0; // - texture(hide_texture, uv_pos).b;
}

vec3 rotateAboutAxis(vec3 v, float angle, vec3 normalized_axis, vec3 pivot) {
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
		float rotation_angle = length(displacement) * max_rotation;
		float rotation_angle_rad = PI2 * rotation_angle;
		
		// float pivot_offset = 0.1;
		// vec3 mesh_top_world = (WORLD_MATRIX * vec4(0.0, 1.0, 0.0, 1.0)).xyz;
		// vec3 pivot_point = mesh_world;
		// vec3 pivot_point = vertex_world - mesh_top_world * pivot_offset;
		
		vec3 rotation_axis = normalize(cross(vec3(displacement, 0.0), vec3(0.0, -1.0, 0.0)));
		
		rotation_angle_rad = rotation_angle_rad * COLOR.r;
		vec3 rotated = rotateAboutAxis(vertex_world, rotation_angle_rad, rotation_axis, mesh_world);
		VERTEX = (model_matrix * vec4(rotated, 1.0)).xyz * 3.0;
	}
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a;
	ALPHA_SCISSOR = 0.97;
}
