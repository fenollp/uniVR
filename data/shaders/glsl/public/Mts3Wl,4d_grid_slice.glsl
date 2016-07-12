// Shader downloaded from https://www.shadertoy.com/view/Mts3Wl
// written by shadertoy user TekF
//
// Name: 4D Grid Slice
// Description: A 3D slice through a 4D grid. 
// Ben Quantock 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://creativecommons.org/licenses/by-nc-sa/3.0/

// consts
const float tau = 6.2831853;
const float phi = 1.61803398875;

vec2 Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec4 rg = texture2D( iChannel0, (uv+0.5)/256.0, -100.0 );
	return mix( rg.yw, rg.xz, f.z );
}



vec4 Map( vec3 p3 )
{
    // construct an orthonormal frame for the slice
//	um... there's no 4D cross product, is there? There can't be! Would need 3 inputs. balls.
    vec4 i = vec4(1,0,0,0);
    vec4 j = vec4(0,1,0,0);
    vec4 k = vec4(0,0,1,0);
    
    // rules for rotation should still behave afaik
    float a,c;
    vec2 s;
    a = iGlobalTime*.1;
    c = cos(a); s = vec2(1,-1)*sin(a);
    i.xz = i.xz*c + i.zx*s;
    j.xz = j.xz*c + j.zx*s;
    k.xz = k.xz*c + k.zx*s;
    i.yw = i.yw*c + i.wy*s;
    j.yw = j.yw*c + j.wy*s;
    k.yw = k.yw*c + k.wy*s;
    i.xw = i.xw*c + i.wx*s;
    j.xw = j.xw*c + j.wx*s;
    k.xw = k.xw*c + k.wx*s;
    i.yz = i.yz*c + i.zy*s;
    j.yz = j.yz*c + j.zy*s;
    k.yz = k.yz*c + k.zy*s;
    
    // form a basis perp to vec4(1,1,1,1)
//    actually easier than it sounds, just make it so dot prods sum to 0
/*    vec4 i = vec4(1,1,-1,-1)/2.0;
    vec4 j = vec4(-1,1,-1,1)/2.0;
    vec4 k = vec4(1,-1,-1,1)/2.0;*/
    
    //vec4 p = vec4(p3,0);
    vec4 p = i*p3.x + j*p3.y + k*p3.z;// + vec4(1,1,1,1)*.5*.25;

    return p;
}
    
float DistanceField( vec3 p3 )
{
    vec4 p = Map(p3);
    
    // offset to centre of cell
    float f = 100.0;
    
    // cells
    vec4 o = .5 - abs(fract(p+.5)-.5);
    f = min(f, .2 - min(min(min(o.x, o.y), o.z), o.w ) );
        
	// or grid edges (is this meaningful? - apparently, yes)
    f = min(f, min(min(min(min(min(length(o.xy),length(o.xz)),length(o.xw)),length(o.yz)),length(o.yw)),length(o.zw)) - .03);
    
    p = abs(p);
    return max( f, max(max(max(p.x,p.y),p.z),p.w)-1.53 );
}




vec3 Sky( vec3 ray )
{
	return mix( vec3(.8), vec3(0), exp2(-(1.0/max(ray.y,.01))*vec3(.4,.6,1.0)) );
}


vec3 Shade( vec3 pos, vec3 ray, vec3 normal, vec3 lightDir, vec3 lightCol, float shadowMask, float distance )
{
    vec4 p = Map(pos);

    vec4 c = (p+1.5)/3.0;
    //vec3 albedo = (c.xyz);// + c.www)*.5;//vec3(.25);
//    vec3 albedo = vec3(.75,0,0)*c.x + vec3(.25,.5,0)*c.y + vec3(0,.5,.25)*c.z + vec3(0,0,.75)*c.w;
    
    vec4 o = .5 - abs(fract(p+.5)-.5);
    vec3 albedo = mix( vec3(1,0,0), vec3(1), step(.1,min(min(min(o.x, o.y), o.z), o.w )) );


	// direct light
	float ndotl = max(.0,dot(normal,lightDir));
	float lightCut = smoothstep(.0,.1,ndotl);//pow(ndotl,2.0);
	vec3 light = lightCol*shadowMask*ndotl;


	// ambient light
	vec3 ambient = mix( vec3(.2,.27,.4), vec3(.4), (-normal.y*.5+.5) ); // ambient

	// ambient occlusion, based on my DF Lighting: https://www.shadertoy.com/view/XdBGW3
	float aoRange = distance/20.0;
	float occlusion = max( 0.0, 1.0 - DistanceField( pos + normal*aoRange )/aoRange ); // can be > 1.0
	occlusion = exp2( -2.0*pow(occlusion,2.0) ); // tweak the curve
	ambient *= occlusion;


	// subsurface scattering
	float transmissionRange = 0.1;
	float transmission = DistanceField( pos + lightDir*transmissionRange )/transmissionRange;
	vec3 sslight = lightCol * smoothstep(0.0,1.0,transmission);
	vec3 subsurface = vec3(1,.8,.5) * sslight;


	// specular
	float specPower = 400.0;
	
	vec3 h = normalize(lightDir-ray);
    float specFres = mix( .02, 1.0, pow( 1.0 - dot(h,lightDir), 5.0 ) );
	vec3 specular = lightCol*shadowMask*pow(max(.0,dot(normal,h))*lightCut, specPower)*specFres*(specPower+6.0)/32.0;
	

	// reflections
	vec3 rray = reflect(ray,normal);
	vec3 reflection = Sky( rray );
	
	// reflection occlusion, adjust the divisor for the gradient we expect
	float specOcclusion = max( 0.0, 1.0 - DistanceField( pos + rray*aoRange )/(aoRange*max(.01,dot(rray,normal))) ); // can be > 1.0
	specOcclusion = exp2( -2.0*pow(specOcclusion,2.0) ); // tweak the curve
	
	// prevent sparkles in heavily occluded areas
	specOcclusion *= occlusion;

	reflection *= specOcclusion; // could fire an additional ray for more accurate results
	
	// fresnel
	float fresnel = pow( 1.0+dot(normal,ray), 5.0 );
	fresnel = mix( .02, 1.0, fresnel );
	
	vec3 result = vec3(0);

	
	// Combine all shading stages
	// comment these out to toggle various parts of the effect
	light += ambient;

//	light = mix( light, subsurface, .5 );
	
	result = light*albedo;

//	result = mix( result, reflection, fresnel );
	
	result += specular;

	return result;
}




// Isosurface Renderer
#ifdef FAST
const int traceLimit=40;
const float traceSize=.005;
#else
const int traceLimit=100;
const float traceSize=.001;//before *t: .002;
#endif	

float Trace( vec3 pos, vec3 ray, float traceStart, float traceEnd )
{
	float t = traceStart;
	float h;
	for( int i=0; i < traceLimit; i++ )
	{
		h = DistanceField( pos+t*ray );
		if ( h < traceSize*t || t > traceEnd )
			break;
		t = t+h;
	}
	
	if ( t > traceEnd )//|| h > .001 )
		return 0.0;
	
	return t;
}

float TraceMin( vec3 pos, vec3 ray, float traceStart, float traceEnd )
{
	float Min = traceEnd;
	float t = traceStart;
	float h;
	for( int i=0; i < traceLimit; i++ )
	{
		h = DistanceField( pos+t*ray );
		if ( h < .001 || t > traceEnd )
			break;
		Min = min(h,Min);
		t = t+max(h,.1);
	}
	
	if ( h < .001 )
		return 0.0;
	
	return Min;
}

vec3 Normal( vec3 pos, vec3 ray, float t )
{
	// in theory we should be able to get a good gradient using just 4 points

	float pitch = .2 * t / iResolution.x;
#ifdef FAST
	// don't sample smaller than the interpolation errors in Noise()
	pitch = max( pitch, .005 );
#endif
	
	vec2 d = vec2(-1,1) * pitch;

	vec3 p0 = pos+d.xxx; // tetrahedral offsets
	vec3 p1 = pos+d.xyy;
	vec3 p2 = pos+d.yxy;
	vec3 p3 = pos+d.yyx;
	
	float f0 = DistanceField(p0);
	float f1 = DistanceField(p1);
	float f2 = DistanceField(p2);
	float f3 = DistanceField(p3);
	
	vec3 grad = p0*f0+p1*f1+p2*f2+p3*f3 - pos*(f0+f1+f2+f3);
	
	// prevent normals pointing away from camera (caused by precision errors)
	float gdr = dot ( grad, ray );
	grad -= max(.0,gdr)*ray;
	
	return normalize(grad);
}


// Camera

vec3 Ray( float zoom, vec2 fragCoord )
{
	return vec3( fragCoord.xy-iResolution.xy*.5, iResolution.x*zoom );
}

vec3 Rotate( inout vec3 v, vec2 a )
{
	vec4 cs = vec4( cos(a.x), sin(a.x), cos(a.y), sin(a.y) );
	
	v.yz = v.yz*cs.x+v.zy*cs.y*vec2(-1,1);
	v.xz = v.xz*cs.z+v.zx*cs.w*vec2(1,-1);
	
	vec3 p;
	p.xz = vec2( -cs.w, -cs.z )*cs.x;
	p.y = cs.y;
	
	return p;
}


// Camera Effects

void BarrelDistortion( inout vec3 ray, float degree )
{
	// would love to get some disperson on this, but that means more rays
	ray.z /= degree;
	ray.z = ( ray.z*ray.z - dot(ray.xy,ray.xy) ); // fisheye
	ray.z = degree*sqrt(ray.z);
}

vec3 LensFlare( vec3 ray, vec3 lightCol, vec3 light, float lightVisible, float sky, vec2 fragCoord )
{
	vec2 dirtuv = fragCoord.xy/iResolution.x;
	
	float dirt = 1.0-texture2D( iChannel1, dirtuv ).r;
	
	float l = (dot(light,ray)*.5+.5);
	
	return (
			((pow(l,30.0)+.05)*dirt*.1
			+ 1.0*pow(l,200.0))*lightVisible + sky*1.0*pow(l,5000.0)
		   )*lightCol
		   + 5.0*pow(smoothstep(.9999,1.0,l),20.0) * lightVisible * normalize(lightCol);
}


float SmoothMax( float a, float b, float smoothing )
{
	return a-sqrt(smoothing*smoothing+pow(max(.0,a-b),2.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 ray = Ray( .7, fragCoord );
	
	BarrelDistortion( ray, .5 );
	
	ray = normalize(ray);
	vec3 localRay = ray;

    vec2 rot = vec2(.2,0.0);
    
	float T = iGlobalTime*.13;
	vec2 mouse = vec2(.2,.5);
	if ( iMouse.z > .0 )
		rot += vec2(1.0,-6.3) * (vec2(.5)-iMouse.yx/iResolution.yx);
    else
        rot -= vec2(0,1)*T;
		
    float dist = 7.0;// * (-sin(iGlobalTime/10.0)+1.0);
	vec3 pos = dist*Rotate( ray, rot );
	//pos += vec3(0,.3,0) + T*vec3(0,0,-1);
	
	vec3 col;

	vec3 lightDir = normalize(vec3(3,1,-2));
	
	vec3 lightCol = vec3(1.1,1,.9)*1.0;
	
	// can adjust these according to the scene, even per-pixel to a bounding volume
	float near = .0;
	float far = 40.0;
	
	float t = Trace( pos, ray, near, far );
	if ( t > .0 )
	{
		vec3 p = pos + ray*t;
		
		// shadow test
		float s = 0.0;
		//s = TraceMin( p, lightDir, .05, far );
        s = Trace( p, lightDir, .01*t, far );
		
		vec3 n = Normal(p, ray, t);
		col = Shade( p, ray, n, lightDir, lightCol,
					//smoothstep( .0, .01, s ),
                    step( s, .001 ),
                    t );
		
		// fog
		float f = 200.0;
		col = mix( vec3(.8), col, exp2(-t*vec3(.4,.6,1.0)/f) );
	}
	else
	{
		col = Sky( ray );
	}
	
	// lens flare
	float s = TraceMin( pos, lightDir, .5, 40.0 );
	col += LensFlare( ray, lightCol, lightDir, smoothstep(.01,.1,s), step(t,.0), fragCoord );
	
	// vignetting:
	col *= smoothstep( 1.0, .0, dot(localRay.xy,localRay.xy) );
	
	// compress bright colours, ( because bloom vanishes in vignette )
	vec3 c = (col-1.0);
	c = sqrt(c*c+.05); // soft abs
	col = mix(col,1.0-c,.48); // .5 = never saturate, .0 = linear
	
	// grain
	vec2 grainuv = fragCoord.xy + floor(iGlobalTime*60.0)*vec2(37,41);
	vec2 filmNoise = texture2D( iChannel0, .5*grainuv/iChannelResolution[0].xy ).rb;
	col *= mix( vec3(1), mix(vec3(1,.5,0),vec3(0,.5,1),filmNoise.x), .1*filmNoise.y );
	
	// compress bright colours
	float l = max(col.x,max(col.y,col.z));//dot(col,normalize(vec3(2,4,1)));
	l = max(l,.01); // prevent div by zero, darker colours will have no curve
	float l2 = SmoothMax(l,1.0,.01);
	col *= l2/l;
	
	fragColor = vec4(pow(col,vec3(1.0/2.2)),1);
}
