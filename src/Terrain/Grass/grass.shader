shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;

uniform vec4 gras_top : hint_color;
uniform vec4 gras_bottom: hint_color;
uniform vec4 transmission: hint_color;

uniform sampler2D height_map;
uniform float height_zero = 0.0;

uniform sampler2D displacement_map;

uniform float wind_strenght : hint_range(0,1) = 1.0;
uniform float max_rotation : hint_range(0, 0.3) = 0.2;
uniform float max_steepness : hint_range(0, 1.0) = 0.6;

const float PI2 = 2.0 * 3.1415926;

varying float height;

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
	const vec3 VERTEX_HIDE_OFFSET = vec3(-10000.0);
	mat4 model_matrix = inverse(WORLD_MATRIX);
	vec3 vertex_world = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 mesh_world = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	
	// Automate this by setting the maximum size
	// this is for 50
	// vec2 mesh_world_uv = (mesh_world.xz + vec2(25.0)) / 50.0;
	// for size 20
	vec2 mesh_world_uv = (mesh_world.xz + vec2(10.0)) / 20.0;
	
	vec3 displacement_sample = texture(displacement_map, mesh_world_uv).rgb;
	float hide = displacement_sample.b;
	// We must correct back again to our vector space to have a range of 0-1
	vec2 displacement = displacement_sample.rg * 2.0 - vec2(1.0);
	
	// Camera culling is at 20, we might need to feed this param into the shader as well.
	vec4 height_sample = texture(height_map, mesh_world_uv);
	height = height_sample.x;
	
	if(height_sample.g > max_steepness) {
		 VERTEX = VERTEX_HIDE_OFFSET;
	} else if(hide > 0.1) {
		// Try to put vertex so it gets culled
		VERTEX = VERTEX_HIDE_OFFSET;
	} else {
		float rotation_angle = length(displacement) * max_rotation * PI2;
		
		float d = vertex_world.y - mesh_world.y;
		vec3 pivot_point = vec3(vertex_world.x, vertex_world.y - d, vertex_world.z);
		
		vec3 rotation_axis = normalize(cross(vec3(displacement.x, 0.0, displacement.y), vec3(0.0, -1.0, 0.0)));
		
		rotation_angle = rotation_angle * COLOR.r;
		vec3 rotated = rotate_about_axis(vertex_world, rotation_angle, rotation_axis, pivot_point);
		
		// Add wind influence
		vec3 wind_displ = (large_scale_displ(mesh_world, TIME) + small_scale_displ(VERTEX, TIME)) * COLOR.r * wind_strenght;
		
		float height_offset = 20.0 * height_sample.x - 0.1;
		VERTEX = (model_matrix * vec4(rotated, 1.0)).xyz + wind_displ;
		VERTEX += vec3(0., height_offset, 0.0);
	}
}

void fragment() {
	ALBEDO = mix(gras_bottom.rgb, gras_top.rgb, COLOR.r);
	TRANSMISSION = transmission.rgb;
}
