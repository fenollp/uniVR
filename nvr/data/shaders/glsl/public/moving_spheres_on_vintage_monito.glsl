// Shader downloaded from https://www.shadertoy.com/view/MlB3WK
// written by shadertoy user ManuManu
//
// Name: Moving Spheres on vintage monito
// Description: Here I wanted two things :
//    * Apply the same transformation to all the pixel of one sphere ( so the sphere is not deformed ) in a repetition operator.
//    * Apply a vintage monitor effect.
//    
//    Made on GlSlSandbox here :
//    http://glslsandbox.com/e#24816.10
//    
//precision mediump float;
precision highp float;


float rand(vec2 co) { return fract(sin(dot(co.xy ,vec2(12.98,78.23))) * 43758.54); }


#define NB_ITER 128
#define FAR 	300.


//#define EDIT



vec4 mapFloor ( vec3 pos )
{
	const float rep = 5.0;
	float n1 = floor( pos.x / rep );
	float n2 =.1* floor( pos.z / rep );
	//float n = n1 + n2;
	float n = .1*pos.x + .0*sin(iGlobalTime) + .01*pos.z;
	float c = cos(.5*n);
	float s = sin( .05*n );
	mat2 m = mat2(c, -s, s, c);
	pos  = vec3( m*pos.xy, pos.z);
	vec3 col1 = vec3( 1., 0., 0.);
	vec3 col2 = vec3( 0., 1., 0.);
	float val = sign( fract( .25*pos.x) -.5 ) * sign( fract( .25*pos.z) -.5 );
	vec3 col =mix( col1, col2, val );
	float dist = pos.y;
	return vec4( col, dist );
}

vec4 mapSphere( vec3 pos )
{
	//vec4 ret = vec4( abs(atan (pos.x ) ) *abs(atan (pos.y ) )  );
	//float m = smoothstep( 0., 1.5, abs(pos.y) -1.5 );
	//ret = mix ( ret, vec4( 0., 1., 0., 0.), m );
	//vec4 ret = vec4(fract( pos.z ) > .5);
	float DEP_VAL =sin(iGlobalTime) +2.;
	float dist = length(  pos ) - 5.+ .2*sin(DEP_VAL *pos.x + sin(5.*iGlobalTime)) * sin(DEP_VAL *pos.y+ cos(6.*iGlobalTime)) * sin(DEP_VAL *pos.z+ sin(iGlobalTime));
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

	float repVal = 20.;
	float n = floor( (pos.z+repVal*.5) / repVal );
	float val = .2*n*sin(iGlobalTime);
	float c = cos(val);
	float s = sin( val );
	//float c = cos(.09*n);
	//float s = sin( .09*n );
	mat2 m = mat2(c, -s, s, c);
	pos  = vec3( m*pos.xy, pos.z);
	
	const float radius=5.0;
	float DEP_VAL =.5*sin(10.*iGlobalTime) +2.5;
	float dist = length( mod( pos+repVal*.5, repVal)-repVal*.5) -radius+ .2*sin(DEP_VAL *pos.x + sin(5.*iGlobalTime)) * sin(DEP_VAL *pos.y+ cos(6.*iGlobalTime)) * sin(DEP_VAL *pos.z+ sin(iGlobalTime));
	return vec4( col, dist);
}
vec4 mapLotsOfCubes( vec3 pos)
{
	vec3 col = vec3(.3, .8, .2 );
	const float radius=6.0;
	float dist = Mylength( mod( pos+8., 16.)-8.) -radius;
	return vec4( col, dist);
}


vec4 map( vec3 pos)
{
	return mapLotsOfSpheres(pos);
}

vec4 pixel3D( void ) {
#ifdef EDIT
	gl_FragColor = vec4( .1);
#else
	vec2 uv = ( gl_FragCoord.xy / iResolution.xy );
	uv -= .5;
	uv.x *= iResolution.x / iResolution.y;
	//uv.x += cos( uv.x)*3.02;
	//float fish_eye =  -length(uv)*1.+ sin(time);
	//float fish_eye = sin(5.*uv.x) + sin(5.*uv.y) + 1.;
	float fish_eye =  0.;
	vec3 dir = vec3( uv, 1.0 + fish_eye);
	dir = normalize(dir);
	
	vec3 pos = vec3( .0, 8.1, .0);
	//vec3 pos = vec3( 20.*sin(time), 8.1, 20.*cos(time));
	
	float nbIterF = 0.;
	vec4 result;
	for (int i =0; i < NB_ITER; i++)
	{
		result = map( pos );
		pos += result.w * dir;
		if ( (pos.z > FAR) || (abs(result.w) < .001)) break;
		
		nbIterF += 1.0;	
	}
	vec3 col = result.xyz;
	if ( pos.z> FAR ) 
	{
		col = vec3(.0, .0, .8);
	}
	else
	{
		vec3 lightPos = vec3(10.* sin(3.*iGlobalTime) + 10., 8.5, 10.*cos(3.*iGlobalTime) + 30. );
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
		col += vec3(pow( spec, 16.)) ;
		
	}
	//vec3 col = vec3( nbIterF/64. );
    
    // Monitor effect :
	col = mix( col, vec3(.0, .5, .5), pow(pos.z/float(FAR),sin(iGlobalTime*5.)+2.));
	col -= .2*rand( uv.xy *iGlobalTime);
	//col = vec3(1.0, .0, .0 );
	col *= .5+.5*sin( 20000.*uv.y+5.*iGlobalTime);
	col *= .7+.4*sin( 20.*uv.y+5.*iGlobalTime);
//	col = mix( col, vec3(.0, .5, .5), pos.z/float(FAR));
	return vec4( col, 1.0);
#endif
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ( gl_FragCoord.xy / iResolution.xy );
	uv -=.5;

	uv.x *= iResolution.x/ iResolution.y;
	fragColor = pixel3D();
}
