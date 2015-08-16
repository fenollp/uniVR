// Shader downloaded from https://www.shadertoy.com/view/4dBGDy
// written by shadertoy user fizzer
//
// Name: Green Discs
// Description: I revisited my 'particle tracing' shader and made it a bit nicer. This version has motion blur, alpha blending, and a shadow effect.
vec3 cam_origin;
mat3 cam_rotation;
vec2 frag_coord;
float time=0.0;

vec3 rotateX(float a, vec3 v)
{
	return vec3(v.x, cos(a) * v.y + sin(a) * v.z, cos(a) * v.z - sin(a) * v.y);
}

vec3 rotateY(float a, vec3 v)
{
	return vec3(cos(a) * v.x + sin(a) * v.z, v.y, cos(a) * v.z - sin(a) * v.x);
}

vec3 round(vec3 x)
{
	return floor(x + vec3(0.5));
}

float orbIntensity(vec3 p)
{
	if(length(p) < 4.0)
		return 1.0;
	
	return smoothstep(0.25, 1.0, cos(p.x * 10.0) * sin(p.y * 5.0) * cos(p.z * 7.0)) * 0.2 *
				step(length(p), 17.0);
}

vec3 project(vec3 p)
{
	// transpose the rotation matrix. unfortunately tranpose() is not available.
	mat3 cam_rotation_t = mat3(vec3(cam_rotation[0].x, cam_rotation[1].x, cam_rotation[2].x),
							   vec3(cam_rotation[0].y, cam_rotation[1].y, cam_rotation[2].y),
							   vec3(cam_rotation[0].z, cam_rotation[1].z, cam_rotation[2].z));
	
	// transform into viewspace
	p = cam_rotation_t * (p - cam_origin);
	
	// project
	return vec3(p.xy / p.z, p.z);
}

float orb(float rad, vec3 coord)
{
	return 1.0 - smoothstep(0.5, 0.55, distance(coord.xy, frag_coord) / rad);
}

float orbShadow(float rad, vec3 coord)
{
	return 1.0 - smoothstep(0.4, 1.1, distance(coord.xy, frag_coord) / rad) *
		mix(1.0,0.99,orb(rad,coord));
}

vec3 traverseUniformGrid(vec3 ro, vec3 rd)
{
	vec3 increment = vec3(1.0) / rd;
	vec3 intersection = ((floor(ro) + round(rd * 0.5 + vec3(0.5))) - ro) * increment;

	increment = abs(increment);
	ro += rd * 1e-3;
	
	vec4 accum = vec4(0.0,0.0,0.0,1.0);
	
	// traverse the uniform grid
	for(int i = 0; i < 40; i += 1)
	{
		vec3 rp = floor(ro + rd * min(intersection.x, min(intersection.y, intersection.z)));
		
		float orb_intensity = orbIntensity(rp);

		if(orb_intensity > 1e-3)
		{
			// get the screenspace position of the cell's centerpoint										   
			vec3 coord = project(rp + vec3(0.5));
			
			if(coord.z > 1.0)
			{
				// calculate the initial radius
				float rad = 0.55 / coord.z;// * (1.0 - smoothstep(0.0, 50.0, length(rp)));
				
				// adjust the radius
				rad *= 1.0 + 0.5 * sin(rp.x + time * 1.0) * cos(rp.y + time * 2.0) * cos(rp.z);
				
				float dist = distance(rp + vec3(0.5), ro);
				
				float c = smoothstep(1.0, 2.5, dist);
				float a = orb(rad, coord) * c;
				float b = orbShadow(rad, coord) * c;
				
				accum.rgb += accum.a * a * 1.5 *
					mix(vec3(1.0), vec3(0.4, 1.0, 0.5) * 0.5, 0.5 + 0.5 * cos(rp.x)) * exp(-dist * dist * 0.008);

				accum.a *= 1.0 - b;
			}
		}
		
		// step to the next ray-cell intersection
		intersection += increment * step(intersection.xyz, intersection.yxy) *
									step(intersection.xyz, intersection.zzx);
	}
	
	// background colour
	accum.rgb += accum.a * vec3(0.02);

	return accum.rgb;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// get the normalised device coordinates
	vec2 uv = fragCoord.xy / iResolution.xy;
	frag_coord = uv * 2.0 - vec2(1.0);
	frag_coord.x *= iResolution.x / iResolution.y;

	// defined the time interval for this frame
	float time0=iGlobalTime,time1=time0+0.04;
	
	float jitter=texture2D(iChannel0,uv*iResolution.xy/256.0).r;
	
	fragColor.rgb = vec3(0.0);
		
	for(int n=0;n<4;n+=1)
	{
		time=mix(time0,time1,(float(n)+jitter)/4.0)*0.7;
		
		cam_origin = rotateX(time * 0.3,
							 rotateY(time * 0.5, vec3(0.0, 0.0, -10.0)));
		
		// calculate the rotation matrix
		vec3 cam_w = normalize(vec3(cos(time) * 10.0, 0.0, 0.0) - cam_origin);
		vec3 cam_u = normalize(cross(cam_w, vec3(0.0, 1.0, 0.0)));
		vec3 cam_v = normalize(cross(cam_u, cam_w));
		
		cam_rotation = mat3(cam_u, cam_v, cam_w);
		
		vec3 ro = cam_origin,rd = cam_rotation * vec3(frag_coord, 1.0);
	
		// render the particles
		fragColor.rgb += traverseUniformGrid(ro, rd);
	}
	
	// good old vignet
	fragColor.rgb *= 0.5 + 0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.1 );

	fragColor.rgb = sqrt(fragColor.rgb / 4.0 * 0.8);
}
