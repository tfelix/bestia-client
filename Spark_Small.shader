shader_type spatial;
render_mode blend_mix, cull_disabled;

uniform vec4 sparkColor: hint_color;
uniform float emissionIntensity = 1.0;

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

// Y-Billboard Mode
void vertex() {
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
}

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	
	float radialGradient = 1.0 - 2.01 * length(UV - center);
	float sparkNoise = noise(UV * 8.0);
	float clampedSpark = 1.0 - step(sparkNoise * radialGradient, 0.4);
	
	ALPHA = clampedSpark;
	ALPHA_SCISSOR = 0.4;
	EMISSION = sparkColor.rgb * emissionIntensity;
	ALBEDO = vec3(clampedSpark);
}