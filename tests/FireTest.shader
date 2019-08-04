shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D iChannel0;

uniform float pi = 3.14;
uniform float flameEdgeWidth = 0.1;
uniform float flameThinningFactor = 6.0;
uniform float flameRampCenter = 0.15;
uniform float flameBrightness = 2.25;
uniform float bgVignetteSize = 1.3;
uniform float bgJitterSpeed = 0.15;
uniform float bgJitterPower = 0.16;
uniform vec2 center = vec2(0.5, 0.5);
uniform vec2 bgOffset = vec2(0, -0.1);
uniform vec4 flameEdgeColor = vec4(0, 0.8, 1, 1);

uniform float flameNoiseScales1 = 9.25;
uniform float flameNoiseScales2 = 8.0;
uniform sampler2D flameGradient: hint_black;
 
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
    vec2 flameUV1 = UV / flameNoiseScales1 + TIME * flameNoiseScales1;
    vec2 flameUV2 = UV / flameNoiseScales2 + TIME * flameNoiseScales2 + center;

    // flame motion
    float fade = texture(iChannel0, flameUV1).r * texture(iChannel0, flameUV2).r;
    
    // adding some fill into the bottom of the flame before fading the edges
    fade = clamp(fade + (1.0 - UV.y) * 0.8, 0.0, 1.0);

    // thin the flame on the lateral edges
    if (abs(UV.x - 0.5) > 0.5 / flameThinningFactor)
    {
        // no need to continue math outside the lateral edges
        ALPHA = 0.0;
        return;
    } else {
    	fade *= cos((UV.x - 0.5) * pi * flameThinningFactor);
    }
    
    // create ovular shape of flame
    if (UV.y < 0.5)
    {
		fade *= circularVignette1(UV);   
    } else {
		fade *= 1.0 - abs(UV.x - center.x) / 0.5;
    }
    
    vec4 flameColor;
	float rampCenter = flameRampCenter;
    // float rampCenter = flameRampCenter + bgJitter.x * 0.1;
    
    // 3-color ramp
    if (UV.y < flameRampCenter) {
		flameColor = texture(flameGradient, vec2(UV.y / rampCenter, 0.0));
        // flameColor = mix(flameRampColors0, flameRampColors1, screenUV.y / rampCenter);
    } else UV
		flameColor = texture(flameGradient, vec2(1.0, 0.0));
        // flameColor = mix(flameRampColors1, flameRampColors2, (screenUV.y - rampCenter) / (1.0 - rampCenter));
    }
    
    // vertical flame death
    float clampVal = UV.y;
    
    // edge fade & edge coloring
    if (fade < clampVal)
    {
        ALPHA = 0.0;
        return;
    } else if (fade < clampVal + flameEdgeWidth) {
        fade = (fade - clampVal) / flameEdgeWidth;
        flameColor = mix(flameEdgeColor, flameColor, fade);
    } else {
		fade = 1.0;
    }

    flameColor *= flameBrightness * fade;
	ALBEDO = flameColor.rgb;
	ALPHA = fade;
}