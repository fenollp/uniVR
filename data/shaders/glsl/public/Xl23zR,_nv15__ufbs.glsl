// Shader downloaded from https://www.shadertoy.com/view/Xl23zR
// written by shadertoy user andr00
//
// Name: [NV15] UFBs
// Description: Who are these mysterious invaders? What do they want?
vec2 hash2( vec2 p ) {
	return texture2D( iChannel0, (p+0.5)/256.0, -100.0 ).xy;
}

void rY(inout vec3 p, float a) {
	float c,s;vec3 q=p;
	c = cos(a); s = sin(a);
	p.x = c * q.x + s * q.z;
	p.z = -s * q.x + c * q.z;
}

float sphere(vec3 p, float r) {
    return length(p) - r;
}

float box(vec3 p, vec3 s) {
    return length(max(abs(p) - s, 0.0));
}

float mod1(inout float x, float m) {
	float r = floor(x/m);
	x = mod(x,m) - 0.5 * m;
	return r;
}

float aUfb(vec3 pos) {
    return 
		max(
        min(
        sphere(pos - vec3(-1.0,0.0,0.0), 2.0)
        ,sphere(pos - vec3(1.0,0.0,0.0), 2.0)
		),
       box(pos - vec3(0.0, 1.9,1.0), vec3(3.0,1.0,3.0))
        )
        ;	

}

float regularUfbs(vec3 pos) {
	pos.x -= iGlobalTime * 5.0;
	pos.y += 7.1;
	mod1(pos.x, 12.0);
	mod1(pos.z, 12.0);
	rY(pos, iGlobalTime * 0.5);
    return aUfb(pos);
}

void wavey( inout vec3 p )
{
	p.y += (sin(length(p-vec3(100.0,0.0,-100.0)) - iGlobalTime * 5.0) * 0.1)
		+ sin(length(p-vec3(-100.0,0.0,-100.0)) - iGlobalTime * 5.0) * 0.1
;
}

float xzplane(vec3 pos,float y) {
	return abs(pos.y - y);
}

float waterplane(vec3 pos) {
	wavey(pos);
	return xzplane(pos,12.0);
}

float distFunc(vec3 pos) {
    return min(regularUfbs(pos),waterplane(pos));
}

vec3 distNorm(vec3 pos) {
    const vec2 eps = vec2(0.0, 0.1);
    return normalize(vec3(
			 distFunc(pos + eps.yxx) - distFunc(pos - eps.yxx),
			 distFunc(pos + eps.xyx) - distFunc(pos - eps.xyx),
			 distFunc(pos + eps.xxy) - distFunc(pos - eps.xxy)));
}

vec4 lightUfb(vec3 pos, vec3 lig, vec3 rayDir) {
	vec3 normal = distNorm(pos);

	float ndl = clamp( dot(normal, lig), 0.0, 1.0 );
	float diffuse = max(0.0, dot(-rayDir, normal));
//	vec3 bcolor = vec3(1.0); // NASA
  vec3 bcolor = vec3(0.92, 0.82, 0.63); // strangely peachy
//	vec3 bcolor = vec3(0.92, 0.82, 0.01); // maybe these are minions

    vec3 color = bcolor * 0.1 + bcolor * ndl + ndl * 0.05 * pow(clamp(dot(normalize(-rayDir+lig),normal),0.0,1.0),1.0);

	return vec4(color, 1.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 p = fragCoord.xy / iResolution.xx;    
    float t = iGlobalTime;

	vec3 cameraOrigin = vec3(2.0, 4.0, 2.0);

    // You probably want to zero this out if you're viewing this in VR
    vec2 cameraNoise = hash2(vec2(iGlobalTime * 0.0001, iGlobalTime));

    vec3 cameraTarget = vec3(cameraNoise.xy * pow(sin(iGlobalTime),2.0) + vec2(0.0,3.0), 0.0);
       
    vec3 upDirection = normalize(vec3(0.1 - cameraNoise.x * 0.3, 1.0, 0.0));

	vec3 cameraDir = normalize(cameraTarget - cameraOrigin);    
    
	vec3 cameraRight = normalize(cross(upDirection, cameraOrigin));
	vec3 cameraUp = cross(cameraDir, cameraRight);
	vec2 screenPos = -1.0 + 2.0 * fragCoord.xy / iResolution.xy; 
	screenPos.x *= iResolution.x / iResolution.y;

	vec3 rayDir = normalize(cameraRight * screenPos.x + cameraUp * screenPos.y + cameraDir);


	const int MAX_ITER = 100; // 30 = eerie
	const float MAX_DIST = 800.0; 
	const float EPSILON = 0.001;

	float totalDist = 0.0;
	vec3 pos = cameraOrigin;
	float dist = EPSILON;

    vec2 cCoord = vec2(0.5,0.5);
    
    float d2 = pow(length(p-cCoord),2.0);

    float moreShade = clamp(0.5 - abs(0.3 - d2),0.0,1.0);
    vec4 halo = vec4(moreShade * 0.2);


	float reflectcount = 0.0;    
	float ix = 0.0;
	const float iterStep = 1.0 / float(MAX_ITER);

	for (float ix = 0.0; ix <= 1.0; ix += iterStep) {

	    if ((dist < EPSILON) || (totalDist > MAX_DIST))
     	   break;

        dist = distFunc(pos);
        totalDist += dist;
        pos += dist * rayDir; 

        vec3 lig = normalize( vec3(5.0, -1.4, 2.0) );
		
        if (dist < EPSILON) {
            if(waterplane(pos) < EPSILON && (reflectcount < 1.0)) {
			reflectcount += 1.0;

			pos.y -= 0.04; // corny
			rayDir = reflect(rayDir, distNorm(pos));
			dist = distFunc(pos);
            } else {
                // it's a ufb              
	            fragColor = lightUfb(pos, lig, rayDir);            
			   fragColor += vec4(ix);
		  }

        } else {
			fragColor = vec4(ix,ix,ix*0.8 + 0.2,1.0);
		}
	}
	fragColor += halo;
    
}
