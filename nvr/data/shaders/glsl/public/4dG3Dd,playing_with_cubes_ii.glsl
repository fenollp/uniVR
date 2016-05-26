// Shader downloaded from https://www.shadertoy.com/view/4dG3Dd
// written by shadertoy user ManuManu
//
// Name: Playing with cubes II
// Description: Same as previous &quot;Playing with cubes&quot; shader, but this one with bending the space...
//    Probably as looking the previous one under acids...
#ifdef GL_ES
//precision mediump float;
precision highp float;
#endif

//#define CURVE_WORLD

#define FISH_EYE1 0
#define FISH_EYE2 0
#define FISH_EYE3 1


#define NB_ITER 256
#define FAR 	200.

#define PI 3.14159265


vec3 skyColor( vec2 uv)
{
    return vec3(.0);
	vec3 colEdge 	= vec3(.1, .5, .3);
	vec3 colCenter  = vec3(.0);
	return mix (colEdge, colCenter, 1.-length(uv ) / .9);
}


float Mylength( vec3 pos )
{
	return max(abs(pos.x), max( abs(pos.y), abs( pos.z)) );
}


vec3 rotationPos( vec3 pos, float angle )
{
    angle = mod(angle, 2.*PI);
    float c=cos(angle);
    float s=sin(angle);
    mat3 m = mat3( 1., 0., 0.,
                   0.,  c,  s,
                   0., -s,  c );
    return m*pos;
}

float cubeDist( vec3 pos, float radius)
{
    return Mylength( pos ) - radius;
}

float timeBorner( float t, float t1, float t2)
{
    return step( t1, t ) * ( 1.-step( t2, t ));
}

// 25 seconds
vec3 intro( float t, vec3 pos, float i, float j, inout vec3 col)
{
    pos.z += 65.;
    
    if ( t > 10.)
    {
        if ( t > 20.)
            pos.z -= 65.;
        else
            pos.z -= mix( .0, 65., (t-10.)/10.);
    }       
            
    pos = rotationPos(pos, PI*3.*cos(.3*t));
 
    return pos;
}
// 50 seconds
vec3 firstPart( float t, vec3 pos, float i, float j, inout vec3 col)
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    
    float s = .0;
    float upperlimit =  30.*timeBorner(t, 0., 5.)+
        				20.*timeBorner(t, 5., 10.)+
        				10.*timeBorner(t, 10., 15.)+
        				03.*timeBorner(t, 15., 49.);
    float upperlimity = 30.*timeBorner(t, 20., 23.)+
        				10.*timeBorner(t, 23., 27.)+
        				03.*timeBorner(t, 27., 42.);
    float sint = 3.*sin( 2.*t / PI );
    float dist = mod(2.*sint, upperlimit);
    float disty = mod(2.*t, upperlimity);
    float i2 = mod( i, upperlimit);
    float j2 = mod( j, upperlimity);
    s = PI*t * (1.-step( dist, i2) ) * step( dist, i2 +1.);
    if ( t > 20.)
    	s+=PI*t * (1.-step( disty, j2) ) * step( disty, j2 +1.);
 	pos = rotationPos( pos, s );
    return pos;
}
// 40 seconds
vec3 secondPart( float t, vec3 pos, float i, float j, inout vec3 col)
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    
    i-= 18.;
    j-= 17.;

    float s = .0;
    const float upperlimit = 100.;
    float dist = mod(5.*t, upperlimit); 
    s =PI*t * (1.-step( dist, i*i+j*j) );
    if (t > 20.)
    	col = mix(col1, col2, (1.-step( dist, i*i+j*j) ));
 	pos = rotationPos( pos, s );
    return pos;
}
// 70 seconds
vec3 thirdPart( float t, vec3 pos, float i, float j, inout vec3 col)
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    
    i-= 18.;
    j-= 17.;
    
	if ( t > 35.)
    {
        pos.z -= mix( .0, 120., (t-35.)/35.);
    }
    
    float i2 = mod( i + 15., 30.)-15.;
    float j2 = mod( j + 15., 30.)-15.;


    float s = .0;
    float dist = 60. + 40.*cos(5.*t);
    col = mix(col1, col2, (1.-step( dist, i2*i2+j2*j2) ));
    
	s += sin(t+j)*sin(t+j)						   * timeBorner(t, .0, 5.);
    s += (5.*i + 8.*j + iGlobalTime) 			   * timeBorner(t, 5., 10.);
    s += sin(t+j)*sin(t+j) * sin(t+i)*sin(t+i)	   * timeBorner(t, 10., 15.);
    s += sin(t + i - j )						   * timeBorner(t, 15., 20.);
    s += sin( .01*(i*i) - 5.*iGlobalTime)		   * timeBorner(t, 20., 25.);
    s += sin( .01*(j*j) - 5.*iGlobalTime)		   * timeBorner(t, 25., 30.);
    s += sin( .01*(i*i+j*j) - 2.*iGlobalTime)	   * timeBorner(t, 30., 35.);
 	pos = rotationPos( pos, s );

    return pos;
}
vec3 fourthPart( float t, vec3 pos, float i, float j, inout vec3 col)
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    
    i-= 18.;
    j-= 17.;
    
    pos.z -= mix( 0., 120., 1.-t/40.);
    
    float i2 = mod( i + 15., 30.)-15.;
    float j2 = mod( j + 15., 30.)-15.;


    float s = .0;
    float dist = 60. + 40.*cos(5.*t);
    float val1 = .5 + .5*sin( 5.*i + 8.*j + 20.* t);
    float val2 = .5 + .5*sin( .01*(i*i+j*j) - 2.*iGlobalTime);
    float val = mix( val1, val2, mod( t, 20.) / 20. );
    if ( t > 20.)
    	val = mix( val1, val2, mod( t, 20.) );
    col = mix(col1, col2, val);
    
    
	s += sin(t+j)*sin(t+j)						   * timeBorner(t, .0, 5.);
    s += (5.*i + 8.*j + iGlobalTime) 			   * timeBorner(t, 5., 10.);
    s += sin(t+j)*sin(t+j) * sin(t+i)*sin(t+i)	   * timeBorner(t, 10., 15.);
    s += sin(t + i - j )						   * timeBorner(t, 15., 20.);
    s += sin( .01*(i*i) - 5.*iGlobalTime)		   * timeBorner(t, 20., 25.);
    s += sin( .01*(j*j) - 5.*iGlobalTime)		   * timeBorner(t, 25., 30.);
    s += sin( .01*(i*i+j*j) - 2.*iGlobalTime)	   * timeBorner(t, 30., 35.);
 	pos = rotationPos( pos, s );

    return pos;
}

vec3 choreo( vec3 pos, float i, float j, inout vec3 col)
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    col = col1;

    float t;
    vec3 p;
    
    // for tests :
    //t = mod(iGlobalTime, 40.);
	//p = fourthPart(t, pos, i, j, col);
    
  
	t = mod(iGlobalTime, 250.);
    if ( t < 25.)
        p = intro( t, pos, i, j, col);
	else if ( t < 75.)
		p = firstPart( t-25., pos, i, j, col);
	else if ( t < 115.)
		p = secondPart( t-75., pos, i, j, col);
	else if ( t < 185.)
		p = thirdPart( t-115., pos, i, j, col);
    else if ( t < 225.)
		p = fourthPart( t-185., pos, i, j, col);
	else
        p = intro( 250.-t, pos, i, j, col);
    return p;
}

vec4 cubes(vec3 pos )
{
    vec3 col1 = vec3(.8, .0, .1 );
    vec3 col2 = vec3(.3, .8, .6 );
    pos.z -= 70.;

    const float repVal = 2.;

    //indexes :
	float i = float( int ( (pos.x+2.) / 4. ) );
    float j = float( int ( (pos.y+2.) / 4.) );

    
    // repetition :
    pos = vec3( mod( pos.x + repVal, 2.*repVal) - repVal,
                mod( pos.y + repVal, 2.*repVal) - repVal,
                pos.z);
    
    vec3 col;
    pos = choreo( pos, i, j, col );
    float dist = cubeDist( pos, 1.);
    return vec4( col, dist);
}

vec4 map( vec3 pos)
{
	return cubes(pos);
}

vec2 rot(vec2 r, float a) {
	return vec2(
		cos(a) * r.x - sin(a) * r.y,
		sin(a) * r.x + cos(a) * r.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ( fragCoord.xy / iResolution.xy );
	uv -= .5;
	uv.x *= iResolution.x / iResolution.y;
	//uv.x += cos( 10.*uv.y)*1.;
    float time = iGlobalTime;

#if FISH_EYE1
	float fish_eye =  -length(uv)*1.+ .2*sin(time);
#elif FISH_EYE2
	float fish_eye = sin(5.*uv.x + time*1.) + sin(5.*uv.y+time*.5) + 1.;
#elif FISH_EYE3
	float fish_eye1 =  -length(uv)*1.+ .2*sin(time);
	float fish_eye2 = sin(5.*uv.x + time*1.) + sin(5.*uv.y+time*.5) + 1.;
	float fish_eye = mix( fish_eye1, fish_eye2, .5+.5*sin(time) );
#else
	float fish_eye =  0.;
#endif
	vec3 dir = vec3( uv, 1.0 + fish_eye);
	dir = normalize(dir);
	
#ifdef CURVE_WORLD
	vec3 pos = vec3( 20.*sin(time), 8.1, 20.*cos(time));
#else
    vec3 pos = vec3( 70.0, 70.0, .0);
#endif // CURVE_WORLD
	
	float nbIterF = 0.;
	vec4 result;
	for (int i =0; i < NB_ITER; i++)
	{
		result = map( pos );
		pos += result.w * dir;
		if ( (pos.z > FAR) || (abs(result.w) < .001)) 
            break;
		nbIterF += 1.0;
#ifdef CURVE_WORLD
		dir.xy=rot(dir.xy,result.w*0.021);
		dir.yz=rot(dir.yz,result.w*0.01);
		dir.zx=rot(dir.zx,result.w*0.01);
#endif // CURVE_WORLD
    }
	vec3 col = result.xyz;
	if ( pos.z> FAR ) 
	{
		col = skyColor(uv);
	}
	else
	{
		vec3 lightPos = vec3(1.* sin(3.*iGlobalTime) + 100., 8.5, 1.*cos(3.*iGlobalTime)  - 200. );
		vec3 light2Pos = normalize( lightPos - pos);
		vec3 eps = vec3( .1, .0, .0 );
		vec3 n = vec3( result.w - map( pos - eps.xyy ).w,
			       result.w - map( pos - eps.yxy ).w,
			       result.w - map( pos - eps.yyx ).w );
		n = normalize(n);
				
		float lambert = max(.0, dot( n, light2Pos))+.2;
		col *= vec3(lambert);
		
	
		// specular : 
		vec3 h = normalize( -dir + light2Pos);
		float spec = max( 0., dot( n, h ) );
		col += vec3(pow( spec, 32.));
	}
	fragColor= vec4( col, 1.0);
}
