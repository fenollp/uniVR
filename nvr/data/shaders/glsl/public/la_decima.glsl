// Shader downloaded from https://www.shadertoy.com/view/MdsSD4
// written by shadertoy user ciberxtrem
//
// Name: La Decima
// Description: Test to learn how to make shapes a bit complex like cups or badges, and it is also a tribute for the Decima  &lt;img src=&quot;/img/emoticonHappy.png&quot;/&gt;.
#define PI 3.1415
#define EPSILON 0.05
#define MAX_DIST 9999.
#define STEP 0.1

float gTime;
float sampAvg;
float cupsTime = 25.;

vec3 rotate(vec3 v, vec3 k, float a){
    vec3 r = v*cos(a) + cross(v, k)*sin(a) + k*dot(k, v)*(1.-cos(a));
    return r;
}

float smin( float a, float b ){
    float k = 0.06;
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

// Primitives
float sdTorus( vec3 p, vec2 t ){
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

vec2 sdSegment( vec3 a, vec3 b, vec3 p ){
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return vec2( length( pa - ba*h ), h );
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdPlane( vec3 p, vec4 n ){
  return dot(p,n.xyz) + n.w;
}

// Geometry
float sdWings( vec3 p, vec2 h ){
	// Main Shape
	vec3 q = p - vec3(3.0, -0.8, 0.);
	q = rotate(q, vec3(0.,0.,1.), PI/1.85);
	q.x *= 0.32;
	vec3 ref = vec3(q.x, sin(q.x)*1.0, 0.) * (1.-step(PI* 0.928, abs(q.x)));
	float d = length(q - ref) - h.x;
	
	float cutPlane = sdPlane(p - vec3(0., 8.0, 0.), normalize(vec4(0,-1.,0., 0.)));
	d = max(-cutPlane, d);
	
	cutPlane = sdPlane(p - vec3(0., -4.0, 0.), normalize(vec4(0,1.,0., 0.)));
	d = max(-cutPlane, d);
	
	// Inner Shape
	q = p - vec3(3.68, 3.5, 0.);
	q = rotate(q, vec3(0.,0.,1.), PI/1.8);
	ref = vec3(q.x, sin(q.x), 0.) * (1.-step(PI*1.48, abs(q.x)));
	float d2 = mix(length(q - ref) - h.x, 1., step(4., q.x ));
	d = smin(d, d2);
	
	// Top Circle
	float circleY = 7.8;
	q = p - vec3(2.7, circleY, 0.0);
	q = rotate(q, vec3(1.,0.,0.), PI/2.);
	d2 = sdTorus(q, vec2(1.10, h.x - 0.035));
	
	cutPlane = sdPlane(p - vec3(0., 8.4, 0.), normalize(vec4(0.2, 1.,0., 0.)));
	d2 = max(-cutPlane, d2);
	
	d = smin(d, d2);
	return d;
}

vec2 sdLasso(vec3 p, vec2 h){
	float len = h.x;
	vec3 ref = vec3(0., p.y, sin(p.y + gTime + h.y) * abs(p.y - len) * 0.1 );
	float d = (length(p.xy - ref.xy) - (0.2 + smoothstep(0., len, abs(p.y - len)) * 0.6));
	
	d = max(mix(d, 1., step(len, abs(p.y))), abs(p.z - ref.z) - 0.2);
	
	return vec2(d, 3.);
}

float sdOne2D(vec3 p, vec2 s){return max(abs(p.x) - s.x, abs(p.y)-s.y);}
float sdZero2D(vec3 p, vec2 s){return abs(length(p.xy) - s.x) - s.y;}
float udBox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}

vec3 sdCL(vec3 p){
	vec3 q = p - vec3(0., 6., 0.);
	
	// main shape
	vec2 h = sdSegment(vec3(0.0, 0.0, 0.0), vec3(0.0, -7.0, 0.0), q);
	h.x = h.x - 3.5 + pow(h.y, 1.8) * 2.5;
	float d = h.x;
	float d2 = sdCappedCylinder(q - vec3(0., 3., 0.), vec2(4., 2.0));
	d = max(d, -d2);
	// up part
	d2 = sdCappedCylinder(q - vec3(0., 2.8, 0.), vec2(3.45, 2.0));
	float dy = 1. - pow(clamp(abs((q.y -2.8) / 2.0), 0., 1. ), 1.5);
	float dCutPlane = (q.y - 2.8);
	d2 = max(d2 + dy * 1.2, dCutPlane);
	d = smin(d, d2);
	// top part
	d2 = sdCappedCylinder(q - vec3(0., 3., 0.), vec2(2.5, 0.13));
	d = smin(d, d2);
	// bottom
	d2 = sdCappedCylinder(q - vec3(0., -8, 0.), vec2(2., 0.1));
	d = smin(d, d2);
	
	d2 = sdCappedCylinder(q - vec3(0., -8.20, 0.), vec2(2.5, 0.2));
	d = smin(d, d2);
	// wings
	vec3 q2 = q - vec3(-6., -2, 0.);
	d2 = sdWings(q2, vec2(0.25, 0.0));
	d = smin(d, d2);
	
	q2 = rotate(q - vec3(6., -2, 0.), vec3(0., 1., 0.), PI);
	d2 = sdWings(q2, vec2(0.25, 0.0));
	d = smin(d, d2);
	// lasso
	vec2 res = vec2(d, 2.);
	vec2 res2 = sdLasso(q - vec3(3., -1., 0.), vec2(5., 2.*PI));
	if(res2.x < res.x) {
		res = res2;
	}
	res2 = sdLasso(q - vec3(-3., -1., 0.), vec2(3.5, PI));
	if(res2.x < res.x) {
		res = res2;
	}
	// cube
	d = udBox(q - vec3(0., -11, 0.), vec3(2.5));
	if(d < res.x) {
		res = vec2(d, 4.);
	}
	
	return vec3(res.xy, d);
}

vec3 CLGroup(vec3 p)
{
	float c = 13.;
	vec3 q = p;
	q = mix((q - vec3(0., 0., -0.)) * vec3(1., 1.0, 1.0), q, step(26., abs(p.x)));
	q.x = mod(p.x,c)-0.5*c;
	
	vec3 res = sdCL(q);
	res = mix(res, vec3(1., -1., 9999.), step(65., abs(p.x)));
	return res;
}

vec3 map(vec3 p)
{	
	vec3 res = CLGroup(p - vec3(0., 0.0, 35.));
	vec2 res2 = vec2(sdPlane(p - vec3(0., -6.5, 0.), normalize(vec4(0,1., 0., 0.))), 1.);
	if(res2.x < res.x)
	{
		res.xy = res2.xy;
	}
	res2 = vec2(sdPlane(p - vec3(0., 0.0, 40.), normalize(vec4(0,0., -1., 0.))), 5.);
	if(res2.x < res.x)
	{
		res.xy = res2.xy;
	}
	return res;
}

vec3 calcNormal(vec3 p)
{
	vec3 e = vec3(EPSILON, 0., 0.);
	
	vec3 n = vec3
	(
		  map(p + e.xyy).x - map(p - e.xyy).x
		, map(p + e.yxy).x - map(p - e.yxy).x
		, map(p + e.yyx).x - map(p - e.yyx).x
	);
	
	return normalize(n);
}

vec3 intersect(vec3 ro, vec3 rd)
{
	float prec = 0.002;
	float k = 2.*prec;
	vec3 res = vec3(MAX_DIST, -1., 9999.);
	float bloom = MAX_DIST;
	
	for(int i = 0; i < 90; ++i)
	{
		if(res.x <= prec)
		{
			continue;
		}
		
		res = map(ro + k*rd);
		bloom = res.z < bloom ? res.z : bloom;
		k += res.x;
	}
	
	if(res.x > prec)
	{
		res.y = -1.;
		k = MAX_DIST;
	}
	
	res.x = k;
	res.z = bloom;
	
	return res;
}

vec3 colorBadge(vec3 p)
{
	vec3 bgColor =  vec3(0.43,0.5,0.55);
	vec3 bColor = bgColor;
	vec3 q = p - vec3(1., 25., 0.);
	
	// foreground
	float d = length(q.xy)- 8.2;
	bColor = mix(vec3(1.), bColor, step(0., d));
	
	float d2 = max(length(q.xy - vec2(q.x, q.x))- 3.5, length(q.xy) - 8.);
	bColor = mix(vec3(0., 0., 0.7), bColor, step(0., d2));
	d = min(d, d2);
	// main circle
	d2 = sdZero2D(q, vec2(8., 0.4));
	// color + border
	bColor = mix(mix(vec3(0.), vec3(1., 0.84, 0.), smoothstep(0., 0.2, abs(d2))), bColor, step(0., d2));
	d = min(d, d2);

	// sub circles
	vec3 q2 = q - vec3(-0.5, 0.0, 0.);
	d2 = mix(sdZero2D(q2, vec2(5.6, 0.4)), 1., step(-3.0, q2.x));
	q2 = q - vec3(0.5, 0.0, 0.);
	float d3 = mix(sdZero2D(q2, vec2(5.6, 0.4)), 1., step(-3.0, -q2.x));
	d2 = min(d2, d3);
	
	// m2
	q2 = q - vec3(-1.75, 2.9, 0.);
	d3 = max(length(q2.xy - vec2(q2.x, -q2.x))- 0.6, length(q2.xy) - 2.9);
	d2 = min(d2, d3);
	
	// c
	q2 = q - vec3(0.5, 0., 0.);
	d3 = mix(sdZero2D(q2, vec2(2.5, 0.4)), 1., step(1.8, -q2.x));
	d2 = min(d2, d3);
	
	// m1
	q2 = q - vec3(1.75, 2.9, 0.);
	d3 = max(length(q2.xy - vec2(q2.x, q2.x))- 0.6, length(q2.xy) - 2.9);
	d2 = min(d2, d3);
	
	// f
	q2 = q - vec3(-0.5,0.,0.);
	d3 = min(min(sdOne2D(q2, vec2(0.8, 0.5)), sdOne2D(q2 - vec3(1., -2.5, 0.), vec2(0.5, 3.0))), sdOne2D(q2 - vec3(0.,-1.2, 0.), vec2(0.8, 0.5)));
	d2 = min(d2, d3);
	// color + border
	bColor = mix(mix(vec3(0.), vec3(1., 0.84, 0.), smoothstep(0., 0.2, abs(d2))), bColor, step(0., d2));
	
	q2 = q - vec3(0.,0.5,0.);
	d3 = mix(sdZero2D(q2, vec2(10.0, 1.6)) + mix(0., sin(p.x*2.0)*sin(p.y)*0.2, step(10., q2.y)), 1., max(step(q2.y, -q2.x*1.5 + 2.5), step(q2.y, q2.x*1.5 + 2.5)));
	if(d3 < 0.)
	{
		bColor = mix(bColor, vec3(0.8,0.,0.), step(10., length(q.xy)));
		bColor = mix(vec3(1., 0.84, 0.), bColor, step(10., length(q.xy) + sin(p.x * 4.) * sin(p.y*5.) * 0.6 ));
		bColor = mix(vec3(0.), bColor, smoothstep(0., 0.4, abs(d3)));
	}
	d2 = min(d2, d3);
	
	// cross
	q2 = q - vec3(0.,13.7,0.);
	d3 = sdOne2D(q2, vec2(0.35, 2.6));
	bColor = mix(mix(vec3(0.5), vec3(1., 0.84, 0.), smoothstep(0., 0.3, abs(d3))), bColor, step(0., d3));
	d2 = min(d2, d3);
	
	q2 = q - vec3(0.,15.6,0.);
	d3 = sdOne2D(q2, vec2(1.0, 0.25));
	bColor = mix(mix(vec3(0.5), vec3(1., 0.84, 0.), smoothstep(0., 0.3, abs(d3))), bColor, step(0., d3));
	d2 = min(d2, d3);
	
	// top
	q2 = q - vec3(3.0,11.,0.);
	d3 = mix(sdZero2D(q2, vec2(2.0, 0.5)), 1., step(q2.y, -q2.x*0.8 + 1.5)) + sin(p.x * 6.) * sin(p.y*6.) * 0.1;
	bColor = mix(mix(vec3(0.5), vec3(1., 0.84, 0.), smoothstep(0., 0.3, abs(d3))), bColor, step(0., d3));
	d2 = min(d2, d3);
	
	q2 = q - vec3(-3.0,11.,0.);
	d3 = mix(sdZero2D(q2, vec2(2.0, 0.5)), 1., step(q2.y, q2.x*0.8 + 1.5)) + sin(p.x * 6.) * sin(p.y*6.) * 0.1;
	bColor = mix(mix(vec3(0.5), vec3(1., 0.84, 0.), smoothstep(0., 0.3, abs(d3))), bColor, step(0., d3));
	d2 = min(d2, d3);
	
	q2 = q - vec3(0.,12.,0.);
	d3 = mix(sdZero2D(q2, vec2(2.5, 0.5)), 1., step(q2.y, -1.)) + sin(p.x * 6.) * sin(p.y*6.) * 0.1;
	bColor = mix(mix(vec3(0.5), vec3(1., 0.84, 0.), smoothstep(0., 0.3, abs(d3))), bColor, step(0., d3));	
	d = min(min(d2, d3), d);
	
	if(d < 0.){ // Apply illumination to badge
		bColor += 1.5 * pow(max(dot(normalize(vec3(sin(gTime) * 0., 4., -10) - q), vec3(0.,0.,-1.)), 0.), 150.);
	}
	
	// One
	q = p - vec3(13., 26.5, 0.);
	float dNumber = mix(sdOne2D(q, vec2(2.0, 9.)), 1., smoothstep(-q.x*0.5 - 1.5, -q.x*0.5, q.y-6.));
	d = min(d, dNumber);
	vec3 colorOne = mix(vec3(1., 0.84, 0.), mix(vec3(1.), bgColor, smoothstep(0., 0.2, dNumber)), smoothstep(0., 0.3, abs(dNumber)));

	vec3 layer1 = mix(colorOne, bColor, smoothstep(0., 0.2, dNumber));
	layer1 = mix(bgColor, layer1, smoothstep(20., 45., gTime));
	
	
	// Zero
	//dNumber = length(max(abs(q - vec3(-13., -1.,0.)).xy-vec2(3., 3.).xy,0.0))-5.0;
	//dNumber = mix(1., dNumber, smoothstep(-5.5, 0., dNumber));
	//d = min(d, dNumber);
	//vec3 layer0 = mix(vec3(1., 0.84, 0.), mix(vec3(1.), bgColor, smoothstep(0., 0.2, dNumber)), smoothstep(0., 0.3, abs(dNumber)));
	//layer0 = mix(layer0, colorOne, smoothstep(0., 0.2, dNumber));
	
	// mix badge and number zero
	//bColor = mix(bgColor, mix(layer1, layer0, smoothstep(35., 46., gTime)), smoothstep(20., 35., gTime));
	
	//return bColor;
	return layer1;
}

vec4 mapColor(vec3 res, vec3 p, out vec2 colorExtra)
{
	colorExtra = vec2(1.); // r:diffFactor, g:specFactor
	vec4 col = vec4(1.);
	
	float currentCup = (68.5 - 3. * (p.x-70.)/140.) - floor(((max(gTime-4., 0.) / (cupsTime-2.)) * 10.)) * 0.1 * 140.;
	float cupIntensity = step(currentCup, p.x) * max(mix(fract((max(gTime-4., 0.) / (cupsTime-2.))*10.), 1., step(cupsTime, max(gTime-4., 0.))), 1. - step(abs(p.x - currentCup), 140.*0.1));
	
	if(res.y < 1.5){ //floor
		col = vec4(0., 0.,0.2, 1.);
		colorExtra = vec2(0.2, 0.1);
	}
	else if(res.y < 2.5){ //cl
		col = mix(vec4(0.), vec4(0.72,0.72,0.72, 0.5), cupIntensity);
		colorExtra = vec2(0.1, 0.5);
	}
	else if(res.y < 3.5){ // lasso
		col = vec4(1., 1., 1., 0.);
		colorExtra = vec2(0.5, 1.0);
	}
	else if(res.y < 4.5){ //Cube
		col = mix(vec4(0.), vec4(1., 1., 1., 0.), cupIntensity);
	}
	else if(res.y < 5.5) { // Wall
		col = vec4(colorBadge(p), 0.2);
		colorExtra = vec2(0.5, 0.1);
	}
	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	gTime = iGlobalTime;
	
	vec4 soundSampler = texture2D(iChannel0, vec2(0.5));
	sampAvg = (soundSampler.r + soundSampler.b + soundSampler.g) / 3.;
	
	float ar = iResolution.x / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = ((uv * 2.) - 1.) * vec2(ar, -1.);
	
	vec2 mouse = iMouse.xy / iResolution.xy * 2. -1.;
	vec3 mouseDir = vec3(-mouse.x*2., 0., 1.) * max((mouse.y+1.) * 20., 0.);
	
	float travelFactor = 1.-clamp(pow((max(0., (gTime-5.)*0.05)), 1.3), 0., 1.);
	vec3 ro = vec3(0. + 58.*travelFactor, 1.*travelFactor,-15. + 38.*travelFactor) + mouseDir; //vec3(0. + 60.*travelFactor, 0.0,-15. + 38.*travelFactor);
	float rotSpeed = 0.;
	ro = vec3(ro.x * cos(gTime*rotSpeed) - ro.z * sin(gTime*rotSpeed), ro.y, ro.z * cos(gTime*rotSpeed) + ro.x * sin(gTime*rotSpeed));
	vec3 camLA = ro + vec3(0. + 6.*travelFactor, 1. + 4.*travelFactor,30.) + vec3(-mouse.x, (mouse.y+1.)*0.5, 1.) * 0.1; //vec3(0. + 60.*travelFactor, 1. + 1.*travelFactor,30.);
	vec3 camFront = normalize(camLA - ro);
	vec3 camRight = normalize(cross(camFront, vec3(0,1,0)));
	vec3 camUp = normalize( cross(camFront, camRight) );
	
	float halffov = 38. * (PI/180.);
	float scale = tan(halffov);
	vec3 rd = normalize(camFront + camRight * uv.x * scale + camUp * uv.y * scale);
	
	float att = 1.;
	vec4 totalCol = vec4(0,0,0,1);
	vec2 bloom = vec2(0., 9999.);
	
	for(int i = 0;i < 2; ++i)
	{
		if(att < 0.01) {
			continue;
		}
		
		vec3 res = intersect(ro, rd);
		vec4 col = vec4(0,0,0,1);
		vec3 p = ro + res.x*rd;
		vec2 colorExtra = vec2(1.);
						  
		if(res.y > 0.) {	
			vec4 dif = mapColor(res, p, colorExtra);
			
			vec3 lightOr = vec3(0., 4., 0.);
			vec3 lightDir = normalize(lightOr - p);
			
			vec3 n = calcNormal(p);
			float difFac = pow(max(dot(n, lightDir), 0.), 4.) * 0.2;
						
			vec3 refl = normalize(rd + 2.*dot(-rd, n)*n);
			float specFac = pow(max(dot(lightDir, refl), 0.), 10.);
			float ambFac = 0.05;
			
			col.rgb += dif.rgb * (ambFac + difFac*(1.-ambFac)) * vec3(250,250,210)/255.;
			col.rgb += vec3(1.,0.9,0.82)* 2. * specFac * colorExtra.g;
			col.rgb += (dif.rgb * colorExtra.r);
			
			totalCol.rgb += col.rgb * att;
			
			ro = p;
			rd = refl, rd;
			
			att *= 0.7 * dif.a;
		}
		else {
			col = vec4(0,0,0,1);
			att = 0.;
		}
		
		// Save Bloom data
		bloom = mix(vec2(res.z, mix(1., sampAvg, step(45., gTime))), bloom, step(0.5, float(i)));
	}
	
	// Bloom
	totalCol.rgb = mix(totalCol.rgb + vec3(1., 0.84, 0.) * 2.0 * sampAvg * clamp(smoothstep(44., 45., gTime), 0., 1.), totalCol.rgb, smoothstep(0., 2.0, pow(bloom.x, 0.5)));
	
	// vigneting
	totalCol.rgb = mix(totalCol.rgb, totalCol.rgb * vec3(0), length(uv) * 0.4);
	
	fragColor = totalCol * smoothstep(0., 1., gTime * 0.1);
}