shader_type spatial;
render_mode blend_mix, cull_back;

uniform sampler2D flameRamp: hint_albedo;
uniform float innerThreshold = 0.35;
uniform float outerThreshold = 0.15;
uniform float emissionEnergy = 3.0;

uniform float flameEdge = 0.02; 
uniform vec2 center = vec2(0.5, 0.8);

float random(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm(vec2 coord){
	int OCTAVES = 6;
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

float egg_shape(vec2 coord, float radius){
	vec2 diff = abs(coord - center);

	if (coord.y < center.y){
		diff.y /= 2.0;
	} else {
		diff.y *= 2.0;
	}

	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	float value = sqrt(1.0 - dist * dist);
	return clamp(value, 0.0, 1.0);
}

float overlay(float base, float top) {
	if (base < 0.5) {
		return 2.0 * base * top;
	} else {
		return 1.0 - 2.0 * (1.0 - base) * (1.0 - top);
	}
}

void vertex() {
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(WORLD_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, 1.0, 0.0, 0.0),vec4(0.0, 0.0, length(WORLD_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec2 coord = UV * 8.0;
	vec2 fbmCoord = coord / 6.0;
	
	float noise1 = noise(coord + vec2(TIME * 0.25, TIME * 4.0));
	float noise2 = noise(coord + vec2(TIME * 0.5, TIME * 12.0));
	float noise3 = noise(coord + vec2(TIME * 0.3, TIME * 3.0));
	float combinedNoise = (noise1 + noise2) / 2.0;
	
	float egg_s = egg_shape(UV, 0.4);
	egg_s += egg_shape(UV, 0.35) * noise3;
	
	float fbmNoise = fbm(fbmCoord + vec2(0.0, TIME * 3.0));
	fbmNoise = overlay(fbmNoise, UV.y);
	
	float flameShape = combinedNoise * fbmNoise * egg_s;
	vec4 flameColor = texture(flameRamp, vec2(flameShape, 0));
	
	if(flameShape < outerThreshold) {
		ALPHA = 0.0;
	} else if(flameShape < outerThreshold + flameEdge) {
		vec4 fadingFlame = mix(vec4(0.0), flameColor, (flameShape - outerThreshold) / flameEdge);
		ALPHA = fadingFlame.a;
		ALBEDO = fadingFlame.rgb;
	 } else {
		ALPHA = 1.0;
	}

	if(flameShape < outerThreshold) {
		ALPHA = 0.0;
	} else {
		ALBEDO = flameColor.rgb;
	}
	
	// Alpha out lower button
	float bottomAlpha = 1.0 - smoothstep(0.7, 1.0, UV.y);
	ALPHA *= bottomAlpha;
	
	if(flameShape > 0.3) {
		EMISSION = flameColor.rgb * emissionEnergy;
	} else {
		EMISSION = flameColor.rgb * emissionEnergy * 0.5;
	}
}