// Shader downloaded from https://www.shadertoy.com/view/4d2XD3
// written by shadertoy user ddoodm
//
// Name: My First Distance-Field Raymarch
// Description: I finished this a good while ago, and figured that I ought to make it public. Thanks for visiting!
//    (Just a learning experiment :) )
//    I borrowed a good chunk of code from Joates and iq.
// DDOODM's first raymarched distance field!
// Derived from:
// "monkey saddle by joates (Nov-2014)"
//
// Deinyon Davies & Joates, November 2014

// Thank you, IQ!
vec3 hash3( float n ) { return fract(sin(vec3(n,n+1.0,n+2.0))*43758.5453123); }

//#define IS_BOXED
const float size = 0.45;

// iq's Smooth Minimum
float smin( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float map( in vec3 p )
{
    float plane = p.y + 0.5 + 0.025*(sin(p.x*10.0+sin(p.z*14.0))+cos(p.z*10.0+sin(p.x*20.0)));
    plane = max(plane, length(p + vec3(0.0,0.5,0.0)) - 3.0);
    
    float d1 = length(p) - size;
    
    float d2 = max(p.y + p.x/2.0, p.y - p.x/2.0);
    
    float d3 = length(p) - size * 0.85;
    
    float d4 = length(p - vec3(0.0, 0.25*cos(iGlobalTime)-0.25, 0.0)) - size * 0.25*cos(iGlobalTime*1.2);

    float hem = max(d1,d2);
    
    float bow = max(hem, -d3);
    
    float metabowl = smin(d4, bow, 8.0);
    
    return min(metabowl, plane);
}

vec3 calcNormal( in vec3 p ) {
    vec2 e = vec2( 0.01, 0.0 );
    return normalize( vec3( map( p + e.xyy ) - map( p - e.xyy ),
                            map( p + e.yxy ) - map( p - e.yxy ),
                            map( p + e.yyx ) - map( p - e.yyx ) ) );
}

// Thank you, mu6k!
float amb_occ(vec3 p)
{
	float acc=0.0;
	#define ambocce 0.1

	acc+=map(p+vec3(-ambocce,-ambocce,-ambocce));
	acc+=map(p+vec3(-ambocce,-ambocce,+ambocce));
	acc+=map(p+vec3(-ambocce,+ambocce,-ambocce));
	acc+=map(p+vec3(-ambocce,+ambocce,+ambocce));
	acc+=map(p+vec3(+ambocce,-ambocce,-ambocce));
	acc+=map(p+vec3(+ambocce,-ambocce,+ambocce));
	acc+=map(p+vec3(+ambocce,+ambocce,-ambocce));
	acc+=map(p+vec3(+ambocce,+ambocce,+ambocce));
	return 0.5+acc;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = -1.0 + 2.0*(fragCoord.xy/iResolution.xy);
	uv.x *= iResolution.x/iResolution.y;

	float time = iGlobalTime*0.1;

    // view origin & direction
	vec3 ro = vec3( size );
	vec3 tp = vec3( 0.0 );
    tp.y = -0.25*size;

    // camera orbit
    float m = iMouse.x/iResolution.x * 6.0;
    ro.x = cos(time+m)*length(ro);
    ro.z = sin(time+m)*length(ro);
    ro.y = iMouse.y/iResolution.y;

    vec3 lit = vec3( 200.0, 75.0, 200.0 );
    vec3 ldir = normalize(lit);
    vec3 col = vec3( 0.0 );
    
    // camera view
	vec3 cw = normalize( tp-ro );
	vec3 cp = vec3( 0.0, 1.0, 0.0 );
	vec3 cu = normalize( cross(cw, cp) );
	vec3 cv = normalize( cross(cu, cw) );
	vec3 rd = normalize( uv.x*cu + uv.y*cv + 1.5*cw );

    float tmax = 200.0;
    float h = 1.0;
    float t = 0.0;
    float iterations = 0.0;
    for( int i = 0; i < 100; i++ ) {
        if( h < 0.0001 || t > tmax ) break;
        h = map( ro + t*rd );
        t += h;
        iterations = float(i);
    }

    if ( t < tmax ) {
        vec3 pos = ro + t*rd;
       	vec3 nor = calcNormal( pos );
        vec3 viw = normalize(-pos);
        
        // Ambient
       	col = vec3( 0.45, 0.23, 0.2 );

        // Diffuse
       	col += vec3( 1.3, 0.5, 0.2 ) * clamp( dot( nor, ldir ), 0.0, 1.0 );
        if(pos.y > -0.4)
        {
        	col *= texture2D(iChannel0, pos.xz * 4.0).xyz;
            
            // Reflection
        	//col += 0.2 * textureCube(iChannel2, -cw-viw).xyz;
            
        	// Specular
        	col += vec3( 0.5 ) * pow( clamp( dot( -reflect(nor, rd), ldir), 0.0, 1.0 ), 255.0);
        }
        else
        {
            col *= texture2D(iChannel1, pos.xz).xyz;
            
            // Fog?
            col *= clamp(2.5 - length(pos), 0.0, 1.0);
        }
        
        // Sky light
       	col += vec3( 0.0, 0.1, 0.18 ) * clamp( nor.y, 0.0, 1.0 );
        
        // AO
        col *= amb_occ(ro + (t-0.1)*rd);
    }
    else {
        // Hit the sky
        col = vec3( 0.30, 0.15, 0.1 ) * 0.7;
        col += clamp(vec3( 0.9, 0.4, 0.3 ) * dot(rd, ldir), 0.0, 1.0);
        col += clamp(vec3( 0.0, 0.1, 0.18 ) * dot(rd, -ldir), 0.0, 1.0);
    }
    
    // Gamma
    col = pow(col, vec3(0.8));
    
    // Contrast
    col = smoothstep( 0.0, 1.0, col );
    
    // Vigneting
    vec2 q = fragCoord.xy/iResolution.xy;
    col *= 0.2 + 0.8*pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.2);
    
    // Dithering
    //col += (1.0/255.0)*hash3(q.x+13.0*q.y);
    
    col += vec3(0.4, 0.3, 0.3) * iterations/75.0;
        
    fragColor = vec4( col, 1.0 );
}