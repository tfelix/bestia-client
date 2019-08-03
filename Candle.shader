shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D iChannel0;

uniform float flameEdgeWidth = 0.1;
uniform float flameThinningFactor = 3.0;
uniform float flameRampCenter = 0.15;
uniform float flameBrightness = 2.25;

uniform vec2 center = vec2(0.5, 0.5);

uniform vec4 flameEdgeColor: hint_color = vec4(0, 0.8, 1, 1);
uniform vec4 flameRampColor1: hint_color = vec4(0.4, 0.4, 1, 1);
uniform vec4 flameRampColor2: hint_color = vec4(1, 0.25, 0.05, 1);
uniform vec4 flameRampColor3: hint_color = vec4(1, 1, 0.8, 1);
 
// Rekursions are not allowed so we need to have different names. Sucks.  
float circularVignette2(vec2 screenUV, vec2 offset, float scale)
{
    return 1.0 - (length(screenUV - offset - center) / 0.5) / scale;
}

float circularVignette1(vec2 screenUV) 
{ 
    return circularVignette2(screenUV, vec2(0, 0), 1.0); 
}

void fragment()
{
	float pi = 3.14;
	float flameNoiseScales1 = 9.25;
	float flameNoiseScales2 = 8.0;
	
	vec2 flameNoiseSpeeds1 = vec2(0.06, 0.27);
	vec2 flameNoiseSpeeds2 = vec2(0.03, 0.21);
	
	vec2 flameUV1 = UV / flameNoiseScales1 + TIME * flameNoiseSpeeds1;
    vec2 flameUV2 = UV / flameNoiseScales2 + TIME * flameNoiseSpeeds2 + center;
	
	float jitterTime = TIME * 0.2;
	float jitter = texture(iChannel0, vec2(jitterTime, 0)).r * 0.4; // +/- 0.5
	
	// flame motion
	float fade = (texture(iChannel0, flameUV1).r * texture(iChannel0, flameUV2).r) * 2.0;
	
	// adding some fill into the bottom of the flame before fading the edges
	fade = clamp(fade + UV.y * 0.8, 0.0, 1.0);
	
	// thin the flame on the lateral edges
	if (abs(UV.x - 0.5) > 0.5 / flameThinningFactor) {
		// no need to continue math outside the lateral edges
		ALPHA = 0.0;
		return;
	} else {
		fade *= cos((UV.x - 0.5) * pi * flameThinningFactor);
	}
	
	// create ovular shape of flame
    if (UV.y > 0.5) {
		fade *= circularVignette1(UV);   
    } else {
		fade *= 1.0 - abs(UV.x - center.x) / 0.5;
    }
	
	float rampCenter = flameRampCenter + jitter;
	
	vec4 flameColor;
	// 3-color ramp
	if (UV.y > 1.0 - rampCenter) { 
		flameColor = mix(flameRampColor1, flameRampColor2, (1.0 - UV.y) / rampCenter);
	} else {
		flameColor = mix(flameRampColor2, flameRampColor3, (1.0 - rampCenter - UV.y) / rampCenter);
	}
	
	// vertical flame death
	float clampVal = 1.0 - UV.y;
	
	if (fade < clampVal) {
		ALPHA = 0.0;
		return;
    } else if (fade < clampVal + flameEdgeWidth) {
		fade = (fade - clampVal) / flameEdgeWidth;
		flameColor = mix(flameEdgeColor, flameColor, fade);
    } else {
		fade = 1.0;
    }
	
	flameColor *= flameBrightness * fade;
	
	ALPHA = fade;
	ALBEDO = flameColor.rgb; // vec3(1.0, 0.0, 0.0);
}