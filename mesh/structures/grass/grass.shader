shader_type spatial;

uniform vec2 amplitude = vec2(0.2, 0.1);
uniform sampler2D texturemap : hint_albedo;
uniform vec4 grass_color: hint_color;

// Wind settings.
uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0);
uniform float maxStrength : hint_range(0.0, 1.0);
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform vec2 direction = vec2(1.0, 0.0);
uniform float heightOffset = 0.0;

vec3 getWind(mat4 worldMatrix, vec3 vertex, float timer){
	vec4 pos = worldMatrix * mix(vec4(1.0), vec4(vertex, 1.0), distortion);
	float time = timer * speed + pos.x + pos.z;
	float diff = pow(maxStrength - minStrength, 2);
	float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength);
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, vertex.y - heightOffset);
	vec2 dir = normalize(direction);
	
	return vec3(wind * dir.x, 0.0, wind * dir.y);
}

// See https://github.com/Maujoe/godot-simple-wind-shader
// Better grass: https://github.com/mreinfurt/Grass.DirectX
void vertex() {
	vec4 worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);
	worldPos.xyz += getWind(WORLD_MATRIX, VERTEX, TIME);
	// VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
	// NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	// UV = UV * vec2(1.0, 1.0) + vec2(0.0, 0.0);
}

void fragment() {
	vec4 color = texture(texturemap, UV);
	ALBEDO = length(color.rgb) * grass_color.rgb;
	ALPHA = color.a;
}