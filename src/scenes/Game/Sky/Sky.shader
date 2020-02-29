shader_type canvas_item;

// USING https://www.shadertoy.com/view/XtBXDw (base on it)

uniform sampler2D noiseTexture;
uniform float COVERAGE: hint_range(0,1); //0.5
uniform float THICKNESS: hint_range(0,100); //25.
uniform float ABSORPTION: hint_range(0,10); //1.030725
uniform int STEPS: hint_range(0,100); //25

float noise(in vec3 x) {
	x*=0.01;
	float  z = x.z*256.0;
	vec2 offz = vec2(0.317,0.123);
	vec2 uv1 = x.xy + offz * floor(z); 
	vec2 uv2 = uv1  + offz;
	return mix(textureLod(noiseTexture, uv1 ,0.0).x, textureLod(noiseTexture, uv2 ,0.0).x, fract(z));
}

float fbm(in vec3 pos, in float lacunarity) {
	vec3 p = pos;
	float
	t  = 0.51749673 * noise(p); p *= lacunarity;
	t += 0.25584929 * noise(p); p *= lacunarity;
	t += 0.12527603 * noise(p); p *= lacunarity;
	t += 0.06255931 * noise(p);
	return t;
}

float get_noise(vec3 x) {
	float FBM_FREQ = 2.76434;
	return fbm(x, FBM_FREQ);
}

vec3 render_sky_color(vec3 rd){
	vec3 sun_color = vec3(1., .7, .55);
	vec3 SUN_DIR = normalize(vec3(0, abs(sin( .3)), -1));
	float sun_amount = max(dot(rd, SUN_DIR), 0.0);

	vec3  sky = mix(vec3(.0, .1, .4), vec3(.3, .6, .8), 1.0 - rd.y);
	sky = sky + sun_color * min(pow(sun_amount, 1500.0) * 5.0, 1.0);
	sky = sky + sun_color * min(pow(sun_amount, 10.0) * .6, 1.0);
	
	//return vec3(1.0, 0.0, .0);
	return sky;
}

bool sphere_intersect(vec3 SpPos, float SpRad, vec3 ro, vec3 rd, out float t, out vec3 norm) {
	ro -= SpPos;
	
	float A = dot(rd, rd);
	float B = 2.0*dot(ro, rd);
	float C = dot(ro, ro)-SpRad*SpRad;
	float D = B*B-4.0*A*C;
	if (D < 0.0) {
		return false;
	}

	D = sqrt(D);
	A *= 2.0;
	float t1 = (-B+D)/A;
	float t2 = (-B-D)/A;
	if (t1 < 0.0) t1 = t2;
	if (t2 < 0.0) t2 = t1;
	t1 = min(t1, t2);
	if (t1 < 0.0) {
		return false;
	}
	norm = ro+t1*rd;
	t = t1;
	
	return true;
}

float density(vec3 pos,vec3 offset,float t){
	vec3 p = pos * .0212242 + offset;
	float dens = get_noise(p);
	
	float cov = 1. - COVERAGE;
	dens *= smoothstep (cov, cov + .05, dens);
	return clamp(dens, 0., 1.);	
}


vec4 render_clouds(vec3 ro,vec3 rd, float time) {
	vec3 apos=vec3(0, -450, 0);
	float arad=500.;
	vec3 WIND=vec3(0, 0, -time * .02);
	vec3 C = vec3(0, 0, 0);
	float alpha = 0.;
	vec3 n;
	float tt;
	if(sphere_intersect(apos,arad,ro,rd,tt,n)) {
		float thickness = THICKNESS;
		int steps = STEPS;
		float march_step = thickness / float(steps);
		vec3 dir_step = rd / rd.y * march_step;
		vec3 pos =n;
		float T = 1.;
		
		for (int i = 0; i < steps; i++) {
			float h = float(i) / float(steps);
			float dens = density (pos, WIND, h);
			float T_i = exp(-ABSORPTION * dens * march_step);
			T *= T_i;
			if (T < .01) break;
			C += T * (exp(h) / 1.75) * dens * march_step;
			alpha += (1. - T_i) * (1. - alpha);
			pos += dir_step;
			if (length(pos) > 1e3) break;
		}
		return vec4(C, alpha);
	}
	return vec4(C, alpha);
}

float fbm2(in vec3 p, in float time) {
	float f = 0.;
	f += .50000 * noise(.5 * (p+vec3(0.,0.,-time*0.275)));
	f += .25000 * noise(1. * (p+vec3(0.,0.,-time*0.275)));
	f += .12500 * noise(2. * (p+vec3(0.,0.,-time*0.275)));
	f += .06250 * noise(4. * (p+vec3(0.,0.,-time*0.275)));
	return f;
}

vec3 cube_bot(vec3 d, vec3 c1, vec3 c2, float time) {
	return fbm2(d, time) * mix(c1, c2, d * .5 + .5);
}

vec3 rotate_y(vec3 v, float angle) {
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		vec3(+ca, +.0, -sa),
		vec3(+.0,+1.0, +.0),
		vec3(+sa, +.0, +ca));
}

vec3 rotate_x(vec3 v, float angle) {
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		vec3(+1.0, +.0, +.0),
		vec3(+.0, +ca, -sa),
		vec3(+.0, +sa, +ca)
	);
}

void panorama_uv(vec2 fragCoord, out vec3 ro,out vec3 rd, in vec2 iResolution) {
	float M_PI = 3.1415926535;
	float ymul = 2.0; float ydiff = -1.0;
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x = 2.0 * uv.x - 1.0;
	uv.y = ymul * uv.y + ydiff;
	ro = vec3(0., 5., 0.);
	rd = normalize(rotate_y(rotate_x(vec3(0.0, 0.0, 1.0),-uv.y*M_PI/2.0),-uv.x*M_PI));
}

void fragment(){
	vec2 resolution = 1./ TEXTURE_PIXEL_SIZE;
	vec2 fragCoord = UV * resolution;
	
	vec3 ro = vec3 (0.,0.,0.);
	vec3 rd = vec3(0.);
	vec3 col = vec3(0.);
	
	panorama_uv(fragCoord, ro, rd, resolution);
	
	vec3 sky = render_sky_color(rd);
	vec4 cld = vec4(0.);
	float skyPow = dot(rd, vec3(0.0, -1.0, 0.0));
	float horizonPow =1.-pow(1.0-abs(skyPow), 5.0);
	if(rd.y>0.) {
		cld = render_clouds(ro,rd, TIME);
		cld = clamp(cld,vec4(0.),vec4(1.));
		cld.rgb += 0.04 * cld.rgb * horizonPow;
		cld *= clamp((1.0 - exp(-2.3 * pow(max((0.0), horizonPow), (2.6)))),0.,1.);
	} else {
		// Below the horizon
		cld.rgb = cube_bot(rd,vec3(1.5,1.49,1.71), vec3(1.1,1.15,1.5), TIME);
		cld*=cld;
		cld.a=1.;
		cld*=clamp((  1.0 - exp(-1.3 * pow(max((0.0), horizonPow), (2.6)))),0.,1.);
		// cld = vec4(0.0, 1.0, 0.0, 1.0);
		discard;
	}
	col = mix(sky, cld.rgb / (0.0001+cld.a), cld.a);
	COLOR = vec4(col,1.0);
}
