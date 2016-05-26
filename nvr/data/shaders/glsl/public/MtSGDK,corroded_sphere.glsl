// Shader downloaded from https://www.shadertoy.com/view/MtSGDK
// written by shadertoy user ManuManu
//
// Name: Corroded Sphere
// Description: I try to make a decomposed sphere
//    
//    Made on GlSlSandbox here : http://glslsandbox.com/e#25147.1

#ifdef GL_ES
//precision mediump float;
precision highp float;
#endif



// IT's strange, the version http://glslsandbox.com/e#25099.7
// does not compile on my (cheap) desktop computer (without any error line)
// but is ok on my old laptop...
//
// It looks like using a vec2 ( material , dist ) for the raymarching 
// is failing somewhere...
//
// Do you know why ?


#define NB_ITER 64
#define FAR 	100.


//#define EDIT

vec3 skyColor( vec2 uv)
{
	vec3 col1 = vec3(.0, .4, .6);
	vec3 col2  = vec3(.6, .6,.4);
	return mix (col1, col2, 1.-length(uv+vec2(.2, .3) ) / .5);
}
vec4 mapFloor ( vec3 pos )
{
	vec3 col1 = vec3( 1., 0., 0.);
	vec3 col2 = vec3( 0., 1., 0.);
	float val = sign( fract( .25*pos.x) -.5 ) * sign( fract( .25*pos.z) -.5 );
	vec3 col =mix( col1, col2, val );
	float dist = pos.y;
	return vec4( col, dist );
}

vec4 mapSphere( vec3 pos, float radius )
{
//	float DEP_VAL =sin(time) +2.;
	float dist = length(  pos ) - radius;//+ .2*sin(DEP_VAL *pos.x + sin(5.*time)) * sin(DEP_VAL *pos.y+ cos(6.*time)) * sin(DEP_VAL *pos.z+ sin(time));
	vec3 col = vec3( 1.0, .2, .2 );
	return  vec4( col, dist);
}


float Mylength( vec3 pos )
{
	return max(abs(pos.x), max( abs(pos.y), abs( pos.z)) );
}

float Mylength2( vec3 pos )
{
	return abs(pos.x) + abs(pos.y) + abs( pos.z);
}

vec4 mapCube( vec3 pos )
{
	//vec4 ret = vec4( abs(atan (pos.x ) ) *abs(atan (pos.y ) ), .0, .0, 1.  );
	//vec4 ret = vec4(fract( pos.z ) > .5);
	vec3 col = vec3( .0, .9, .1);
	float dist = Mylength(  pos ) - 5.0;
	return vec4( col, dist );
}


vec4 combine(vec4 val1, vec4 val2 )
{
	if ( val1.w < val2.w ) return val1;
	return val2;
}


vec4 subst( vec4 val1, vec4 val2 )
{
	float dist = max(-val2.w, val1.w);
	return vec4(vec3(val1), dist);
}


vec4 mapLotsOfSpheres( vec3 pos)
{
	vec3 col = vec3(.3, .8, .2 );
	const float radius=6.0;
	float dist = length( mod( pos+15., 30.)-15.) -radius;
	return vec4( col, dist);
}
vec4 mapLotsOfCubes( vec3 pos)
{
	vec3 col = vec3(.3, .8, .2 );
	const float radius=6.0;
	float dist = Mylength( mod( pos+8., 16.)-8.) -radius;
	return vec4( col, dist);
}

vec4 StrangeSphere( vec3 pos ) 
{
	//float move = sin(3.*time ) *.5 - 10.;
	float move = 10.;
	float rad = 10.;
	vec3 newPos = pos - vec3( .0+move, 5., 50.);
	vec4 val2 = mapSphere(newPos, rad );
	vec3 p = newPos;
	if (val2.w < .1 )	// Optimization, don't try the strange thing outside the sphere
	for (int i = 0; i < 5; i++)
	{
		float t = float(i)*.11+0.004*iGlobalTime;
		float c = cos(t);
		float s = sin(t);
		mat2 m = mat2(c,-s,s,c);
		p.xy = m*p.xy;
			      
		rad *= .5;
		p.x = p.x - rad*2.;
		vec3 p2 = p;
		p2.xzy=mod (p.xzy+rad, rad*2.5) -rad;
		//p2.z=mod (p.z+rad, rad*2.5) -rad;
		//p2=mod (p+rad, rad*2.5) -rad;

		//vec3 p2 = p;
		vec4 sph = mapSphere( p2, rad );
		//val2= combine(val2, sph);
		val2 = subst(val2, sph);
		//val2 = sph;
	}
	return val2;
}


//#define MOVING_OBJECTS
vec4 map( vec3 pos)
{
	vec4 ret = mapFloor( pos );

	vec4 res = combine( ret, StrangeSphere(pos));
	return res;
}

float ambientOcclusion(vec3 pos, vec3 norm)
{
    const int steps = 3;
    const float delta = 0.50;

    float a = 0.0;
    float weight = 1.0;
    for(int i=1; i<=steps; i++) {
        float d = (float(i) / float(steps)) * delta; 
        a += weight*(d - map(pos + norm*d).w);
        weight *= 0.5;
    }
    return clamp(1.0 - a, 0.0, 1.0);
}

float softshadow(in vec3 ro, in vec3 rd, in float mint, in float maxt, in float k) {
    float sh = 1.0;
    float t = mint;
    float h = 0.0;
    for(int i = 0; i < 15; i++) {
        if(t > maxt) continue;
        h = map(ro + rd * t).w;
        sh = min(sh, k * h / t);
        t += h;
    }
    return sh;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = ( fragCoord.xy / iResolution.xy );
	uv -= .5;
	uv.x *= iResolution.x / iResolution.y;
	//uv.x += cos( uv.x)*3.02;
	//float fish_eye =  -length(uv)*1.+ sin(iGlobalTime);
	//float fish_eye = sin(5.*uv.x) + sin(5.*uv.y) + 1.;
	float fish_eye =  1.;
	vec3 dir = vec3( uv, 1.0 + fish_eye);
	dir = normalize(dir);
	
	vec3 pos = vec3( .0, 8.1, .0);
	//vec3 pos = vec3( 20.*sin(iGlobalTime), 8.1, 20.*cos(iGlobalTime));
	
	float nbIterF = 0.;
	vec4 result;
	for (int i =0; i < NB_ITER; i++)
	{
		result = map( pos );
		pos += result.w * dir;
		if ( (pos.z > FAR) || (abs(result.w) < .001)) break;
		//if ( (pos.z > FAR)) break;
		nbIterF += 1.0;	
	}
	vec3 col = result.xyz;
	if ( pos.z> FAR ) 
	{
		col = skyColor(uv);
	}
	else
	{
		//vec3 lightPos = vec3(10.* sin(3.*iGlobalTime) + 10., 8.5, 10.*cos(3.*iGlobalTime) + 30. );
		vec3 lightPos = vec3(1.* sin(3.*iGlobalTime) + 10., 8.5, 1.*cos(3.*iGlobalTime) + 30. );
		vec3 light2Pos = normalize( lightPos - pos);
		vec3 eps = vec3( .1, .0, .0 );
		vec3 n = vec3( result.w - map( pos - eps.xyy ).w,
			       result.w - map( pos - eps.yxy ).w,
			       result.w - map( pos - eps.yyx ).w );
		n = normalize(n);
		//col =abs(n);
				
		float lambert = max(.0, dot( n, light2Pos));
		col *= vec3(lambert);
		
		//vec3 light = vec3( sin( time ), 20 , cos(time) );
		//col = col* vec3(dot ( -dir, n ));
		
		// specular : 
		vec3 h = normalize( -dir + light2Pos);
		float spec = max( 0., dot( n, h ) );
		col += vec3(pow( spec, 16.));
		col *= ambientOcclusion( pos, n );
		col *= softshadow(pos, light2Pos, .02, 5., 14. );
		//col = vec3(ambientOcclusion( pos, n ));
		
	}
	//vec3 col = vec3( nbIterF/64. );
	fragColor= vec4( col, 1.0);
}