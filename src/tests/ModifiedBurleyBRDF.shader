shader_type spatial;

uniform vec4 albedo : hint_color;
uniform sampler2D albedo_texture : hint_albedo;
uniform vec2 albedo_uv_scale = vec2(1.0);

uniform sampler2D normal_texture : hint_normal;
uniform float normal_depth : hint_range(-16.0, 16.0) = 1.0;

uniform float specularity : hint_range(0.0, 1.0) = 0.5;
uniform float specular_tint : hint_range(0.0, 1.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float sheen : hint_range(0.0, 1.0) = 0.5;
uniform float sheen_tint : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.5;
uniform float subsurface : hint_range(0.0, 1.0) = 0.0;

void vertex(){}

// Calculate the color of the surface and the normals
void fragment(){
	vec2 uv = UV * albedo_uv_scale;
	vec4 albedo_tex = texture(albedo_texture, uv);
	vec4 normal_tex = texture(normal_texture, uv);
	ALBEDO = albedo.xyz * albedo_tex.xyz;
	NORMALMAP = normal_tex.xyz;
	NORMALMAP_DEPTH = normal_depth;
}

// Simplified fresnel equation taken from the Disney BRDF paper
float fresnel(float LdotH){
	return pow(clamp(1.0-LdotH, 0., 1.), 5.);
}

// Taken Straight from Disney BRDF. Loved the color space selection!
// Adds a nice little depth to the colors
vec3 mon2lin(vec3 color){
	return vec3(pow(color.x, 2.2),pow(color.y, 2.2),pow(color.z, 2.2));
	
}

// Use lambertian diffuse as the base
vec3 calculate_lambertian_diffuse(float NdotL, vec3 color, vec3 light_col){
	float PI = 3.14159265358979323846;
	float theta = smoothstep(0., 1., NdotL);
	vec3 diffuse_component = ((light_col * color)) * theta;
	return diffuse_component;
}

// Adjust lambertian diffuse using the scattering effect of micro facets
float calculate_scattering_diffuse(float LdotH, float fresnel_NdotL, float fresnel_NdotV){
	fresnel_NdotV = abs(fresnel_NdotV);
	fresnel_NdotL = abs(fresnel_NdotL);
	float adjacent_fresnel = 0.5 + 2. * pow(LdotH, 2.) * roughness;
	return mix(1., adjacent_fresnel, fresnel_NdotL) * mix(1., adjacent_fresnel, fresnel_NdotV);
}

// Adjust lambertian diffuse using subsurface scattering
float calculate_subsurface_diffuse(float LdotH, float fresnel_NdotL, float fresnel_NdotV, float NdotL, float NdotV){
	float adjacent_fresnel = pow(LdotH, 2.) * roughness;
	float subsurf_diffuse = mix(1., adjacent_fresnel, fresnel_NdotL) * 
							mix(1., adjacent_fresnel, fresnel_NdotV);
	float intensity_adjustment =  1.25 * (subsurf_diffuse * (1. / (NdotL + NdotV) - .5) + .5);
	return intensity_adjustment;
}

// Calculate specular based on the blinn-phong shader
vec3 calculate_lambertian_specular(float NdotH, float NdotL, vec3 color, vec3 light_col){
	float spec = pow(NdotH, 256.0 * max(0.0001, specularity));
	float theta = smoothstep(0., 1., NdotL);
	return (20.0 * metallic) * mix(color, mix(light_col, color, max(specular_tint, metallic)), specularity) * spec * theta;
}

// Add sheen fro the burley shader based on the luminance and viewing angle between light and view
vec3 calculate_burley_sheen(vec3 color, vec3 light, float luminance, float fresnel_LdotH){
	vec3 tint = luminance > 0. ? color/luminance : light;
    vec3 color_sheen = mix(light, tint, sheen_tint);
	return 2.*((fresnel_LdotH+subsurface) * color_sheen) * sheen;
}

void light(){
	float PI = 3.14159265358979323846;
	
	vec3 color = mon2lin(ALBEDO);
	vec3 light = mon2lin(LIGHT_COLOR);
	
	float lum = .3*color.x + .6*color.y  + .1*color.z;
	
	vec3 H = normalize(LIGHT+VIEW);
	float NdotL = dot(NORMAL, LIGHT);
	float NdotV = dot(NORMAL, VIEW);
	
	float NdotH = dot(NORMAL, H);
	float LdotH = dot(LIGHT, H);
	
	float fresnel_NdotL = fresnel(NdotL);
	float fresnel_NdotV = fresnel(NdotV);
	float fresnel_LdotH = fresnel(LdotH);

	NdotL = NdotL * 0.5 + 0.5;
	NdotV = NdotV * 0.5 + 0.5;
	NdotH = NdotH * 0.5 + 0.5;
	LdotH = LdotH * 0.5 + 0.5;
	
	DIFFUSE_LIGHT = calculate_lambertian_diffuse(NdotL, color, light);
	DIFFUSE_LIGHT *= mix(calculate_scattering_diffuse(LdotH, fresnel_NdotL, fresnel_NdotV), 
						 calculate_subsurface_diffuse(NdotH, fresnel_NdotL, fresnel_NdotV, 
													  NdotL, NdotV), subsurface);
	DIFFUSE_LIGHT *= (1.0 - metallic);
	DIFFUSE_LIGHT += mix(calculate_burley_sheen(color, light, lum, fresnel_LdotH), 
						 calculate_lambertian_specular(NdotH, NdotL, color, light), NdotH);
	DIFFUSE_LIGHT /= PI;
	DIFFUSE_LIGHT *= ATTENUATION;
}