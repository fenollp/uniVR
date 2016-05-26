// Shader downloaded from https://www.shadertoy.com/view/MdBGWG
// written by shadertoy user TekF
//
// Name: Brushed Metal
// Description: My  with a voronoi pattern.
// Ben Quantock 2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


vec2 Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec4 rg = texture2D( iChannel0, (uv+0.5)/256.0, -100.0 );
	return mix( rg.yw, rg.xz, f.z );
}


float DistanceField( vec3 pos )
{
	//pos = abs(pos); return max( pos.x, max( pos.y, pos.z ) )-1.0;
	
	float p = 16.0; pos = pow(abs(pos),vec3(p/2.0)); return pow( dot( pos, pos ), 1.0/p )-1.0;
	
	//return (length(pos-vec3(0,-1,0))-2.0 + sin(sqrt(pow(atan(length(pos.xz),pos.y),2.0)+1.0)*20.0/*-iGlobalTime*/)/20.0)*.707;
	
	//return (pos.y + sin(pos.x*1.0)*sin(pos.z*1.0)/1.0)*.7;
}


vec3 Sky( vec3 ray )
{
	return mix( vec3(.8), vec3(0), exp2(-(1.0/max(ray.y,.01))*vec3(.4,.6,1.0)) );
}


vec4 tap2( vec3 p )
{
	vec2 uv = p.xy+vec2(37.0,17.0)*p.z;
	return texture2D( iChannel0, (uv+0.5)/256.0, -100.0 );
}

vec3 VoronoiNode( vec2 seed )
{
	// position within an octahedron
	// input values are integers in [0,255]/255.0, so only 65536 possible values
	
	// I can't see a nice way to put points inside the octahedron, so just put it on the edges
	seed = seed-.5;
	float z = abs(seed.x)+abs(seed.y)-.5;
	if ( z > 0.0 )
	{
		// fold the corners back in
		seed = fract(seed)-.5;
		return vec3(seed,z);
	}
	else
	{
		return vec3(seed,z);
	}
}


struct VoronoiNeighbours {
	vec3 p0;
	float d0;
	vec3 p1;
	float d1;
	float d2;
};

void VoronoiTest( inout VoronoiNeighbours r, vec3 pos, vec3 node )
{
	float l = length(node-pos);
	if ( l < r.d0 )
	{
		r.d2 = r.d1;
		r.p1 = r.p0; r.d1 = r.d0;
		r.p0 = node; r.d0 = l;
	}
	else if ( l < r.d1 )
	{
		r.d2 = r.d1;
		r.p1 = node; r.d1 = l;
	}
	else if ( l < r.d2 )
	{
		r.d2 = l;
	}
}


VoronoiNeighbours Voronoi( in vec3 x )
{
	vec3 p = floor(x+.5);
	vec3 d = vec3(-1,0,1);

	vec4 _00 = tap2(p+d.xxx); vec2 _000 = _00.yw; vec2 _001 = _00.xz;
	vec4 _01 = tap2(p+d.xyx); vec2 _010 = _01.yw; vec2 _011 = _01.xz;
	vec4 _02 = tap2(p+d.xzx); vec2 _020 = _02.yw; vec2 _021 = _02.xz;
	vec4 _10 = tap2(p+d.yxx); vec2 _100 = _10.yw; vec2 _101 = _10.xz;
	vec4 _11 = tap2(p+d.yyx); vec2 _110 = _11.yw; vec2 _111 = _11.xz;
	vec4 _12 = tap2(p+d.yzx); vec2 _120 = _12.yw; vec2 _121 = _12.xz;
	vec4 _20 = tap2(p+d.zxx); vec2 _200 = _20.yw; vec2 _201 = _20.xz;
	vec4 _21 = tap2(p+d.zyx); vec2 _210 = _21.yw; vec2 _211 = _21.xz;
	vec4 _22 = tap2(p+d.zzx); vec2 _220 = _22.yw; vec2 _221 = _22.xz;

	vec2 _002 = tap2(p+d.xxz).yw;
	vec2 _012 = tap2(p+d.xyz).yw;
	vec2 _022 = tap2(p+d.xzz).yw;
	vec2 _102 = tap2(p+d.yxz).yw;
	vec2 _112 = tap2(p+d.yyz).yw;
	vec2 _122 = tap2(p+d.yzz).yw;
	vec2 _202 = tap2(p+d.zxz).yw;
	vec2 _212 = tap2(p+d.zyz).yw;
	vec2 _222 = tap2(p+d.zzz).yw;

	VoronoiNeighbours r;
	r.p0 = vec3(0); r.d0 = 10.0;
	r.p1 = vec3(0); r.d1 = 10.0;

	VoronoiTest( r, x, VoronoiNode(_000)+d.xxx+p );
	VoronoiTest( r, x, VoronoiNode(_001)+d.xxy+p );
	VoronoiTest( r, x, VoronoiNode(_002)+d.xxz+p );
	VoronoiTest( r, x, VoronoiNode(_010)+d.xyx+p );
	VoronoiTest( r, x, VoronoiNode(_011)+d.xyy+p );
	VoronoiTest( r, x, VoronoiNode(_012)+d.xyz+p );
	VoronoiTest( r, x, VoronoiNode(_020)+d.xzx+p );
	VoronoiTest( r, x, VoronoiNode(_021)+d.xzy+p );
	VoronoiTest( r, x, VoronoiNode(_022)+d.xzz+p );
	VoronoiTest( r, x, VoronoiNode(_100)+d.yxx+p );
	VoronoiTest( r, x, VoronoiNode(_101)+d.yxy+p );
	VoronoiTest( r, x, VoronoiNode(_102)+d.yxz+p );
	VoronoiTest( r, x, VoronoiNode(_110)+d.yyx+p );
	VoronoiTest( r, x, VoronoiNode(_111)+d.yyy+p );
	VoronoiTest( r, x, VoronoiNode(_112)+d.yyz+p );
	VoronoiTest( r, x, VoronoiNode(_120)+d.yzx+p );
	VoronoiTest( r, x, VoronoiNode(_121)+d.yzy+p );
	VoronoiTest( r, x, VoronoiNode(_122)+d.yzz+p );
	VoronoiTest( r, x, VoronoiNode(_200)+d.zxx+p );
	VoronoiTest( r, x, VoronoiNode(_201)+d.zxy+p );
	VoronoiTest( r, x, VoronoiNode(_202)+d.zxz+p );
	VoronoiTest( r, x, VoronoiNode(_210)+d.zyx+p );
	VoronoiTest( r, x, VoronoiNode(_211)+d.zyy+p );
	VoronoiTest( r, x, VoronoiNode(_212)+d.zyz+p );
	VoronoiTest( r, x, VoronoiNode(_220)+d.zzx+p );
	VoronoiTest( r, x, VoronoiNode(_221)+d.zzy+p );
	VoronoiTest( r, x, VoronoiNode(_222)+d.zzz+p );

	return r;
}

vec3 Shade( vec3 pos, vec3 ray, vec3 normal, vec3 lightDir, vec3 lightCol )
{
	float ndotl = dot(normal,lightDir);
	vec3 light = lightCol*max(.0,ndotl);
	light += mix( vec3(.01,.04,.08), vec3(.1), (-normal.y+1.0) ); // ambient
	
	vec3 h = normalize(lightDir-ray);

	vec3 uvw = pos*4.0;
	VoronoiNeighbours v = Voronoi(uvw);

	// mix together - this gets sharp points where d2 is outside the voronoi's sample range, or where d3 would get close to d2
	float weight0 = max(.0,1.0-v.d0)*pow(v.d2-v.d0,2.0);
	float weight1 = max(.0,1.0-v.d1)*pow(v.d2-v.d1,2.0);

	// compute highlight for nearest 2 points, then blend highlights
	vec3 aniso0 = v.p0-uvw;
	vec3 aniso1 = v.p1-uvw;
	aniso0 -= normal*dot(aniso0,normal);
	aniso1 -= normal*dot(aniso1,normal);
	aniso0 = normalize(aniso0);
	aniso1 = normalize(aniso1);
	
	float anisotropy = .8;

	float nh = max(.0,dot(normal,h));
	float ah0 = abs(dot(h,aniso0)); // check if it's perpendicular to the striations
	float ah1 = abs(dot(h,aniso1));
	
	float q = exp2((1.0-anisotropy)*1.0);
	nh = pow( nh, q*10.0 );
	float nh0 = nh*pow( 1.0-ah0*anisotropy, 4.0 );
	float nh1 = nh*pow( 1.0-ah1*anisotropy, 4.0 );
	float specular0 = nh0*exp2((1.0-anisotropy)*4.0);
	float specular1 = nh1*exp2((1.0-anisotropy)*4.0);

	vec3 specular = lightCol*mix( specular0, specular1, weight1/(weight0+weight1) );

	
	// fade specular near terminator, to fake gradual occlusion of the micronormals
	specular *= smoothstep(.0,.5,ndotl);
	
	vec3 reflection = Sky( reflect(ray,normal) );
	float fresnel = pow( 1.0+dot(normal,ray), 5.0 );
	fresnel = mix( .0, .2, fresnel );

	
	//vec3 albedo = mix( fract(v.p0), fract(v.p1), weight1/(weight0+weight1) ); // show the brushed patches
	vec3 albedo = vec3(.2);
	
	return mix( light*albedo, reflection, fresnel ) + specular;
}



// Isosurface Renderer

float traceStart = .1; // set these for tighter bounds for more accuracy
float traceEnd = 40.0;
float Trace( vec3 pos, vec3 ray )
{
	float t = traceStart;
	float h;
	for( int i=0; i < 60; i++ )
	{
		h = DistanceField( pos+t*ray );
		if ( h < .001 )
			break;
		t = t+h;
	}
	
	if ( t > traceEnd )//|| h > .001 )
		return 0.0;
	
	return t;
}

vec3 Normal( vec3 pos, vec3 ray )
{
	const vec2 delta = vec2(0,.001);
	vec3 grad;
	grad.x = DistanceField( pos+delta.yxx )-DistanceField( pos-delta.yxx );
	grad.y = DistanceField( pos+delta.xyx )-DistanceField( pos-delta.xyx );
	grad.z = DistanceField( pos+delta.xxy )-DistanceField( pos-delta.xxy );
	
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
	ray.z /= degree;
	ray.z = ( ray.z*ray.z - dot(ray.xy,ray.xy) ); // fisheye
	ray.z = degree*sqrt(ray.z);
}

vec3 LensFlare( vec3 ray, vec3 light, vec2 fragCoord )
{
	vec2 dirtuv = fragCoord.xy/iResolution.x;
	
	float dirt = 1.0-texture2D( iChannel1, dirtuv ).r;
	
	float l = max(.0,dot(light,ray));
	
	return (pow(l,20.0)*dirt*.1 + 1.0*pow(l,100.0))*vec3(1.05,1,.95);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 ray = Ray(1.0,fragCoord);
	BarrelDistortion( ray, .5 );
	ray = normalize(ray);
	vec3 localRay = ray;

	vec3 pos = 6.0*Rotate( ray, vec2(.4,iGlobalTime*.1+.7)+vec2(1.6,-6.3)*(iMouse.yx/iResolution.yx - .5) );
	
	vec3 col;

	vec3 lightDir = normalize(vec3(3,2,-1));
	
	float t = Trace( pos, ray );
	if ( t > .0 )
	{
		vec3 p = pos + ray*t;
		
		// shadow test
		float s = Trace( p, lightDir );
		
		vec3 n = Normal(p, ray);
		col = Shade( p, ray, n, lightDir, (s>.0)?vec3(0):vec3(.98,.95,.92) );
		
		// fog
		float f = 100.0;
//		col *= exp2(-t*vec3(.1,.6,1.0)/f);
		col = mix( vec3(.8), col, exp2(-t*vec3(.4,.6,1.0)/f) );
	}
	else
	{
		col = Sky( ray );
	}
	
	float sun = Trace( pos, lightDir );
	if ( sun == .0 )
	{
		col += LensFlare( ray, lightDir, fragCoord );
	}
	
	// vignetting:
	col *= smoothstep( .5, .0, dot(localRay.xy,localRay.xy) );

	// compress bright colours, ( because bloom vanishes in vignette )
	vec3 c = (col-1.0);
	c = sqrt(c*c+.01); // soft abs
	col = mix(col,1.0-c,.48); // .5 = never saturate, .0 = linear
	

	// grain
	vec2 grainuv = fragCoord.xy + floor(iGlobalTime*60.0)*vec2(37,41);
	vec2 filmNoise = texture2D( iChannel0, .5*grainuv/iChannelResolution[0].xy ).rb;
	col *= mix( vec3(1), mix(vec3(1,.5,0),vec3(0,.5,1),filmNoise.x), .1*filmNoise.y );

	
	fragColor = vec4(pow(col,vec3(1.0/2.6)),1);
}
