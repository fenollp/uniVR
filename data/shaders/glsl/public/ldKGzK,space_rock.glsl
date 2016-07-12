// Shader downloaded from https://www.shadertoy.com/view/ldKGzK
// written by shadertoy user yibojiang
//
// Name: Space Rock
// Description: Here I experiment perlin noise and value noise in 3d space
#define FBM_Iteration 7
#define pi 3.14159

vec3 hash3(vec3 p){
    p=vec3( dot( p, vec3(127.1, 311.7,121.1) ),
            dot( p, vec3(269.5, 183.3,234.5) ),
            dot( p, vec3(629.5, 43.3,32.1) ) );

    return -1.0+2.0*fract(sin(p)*43758.5453123 );
}

vec2 hash2( vec2 p ) { p=vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))); return fract(sin(p)*43758.5453); }

float hash( float n ) { return fract(sin(n)*753.5453123); }

//background copy and paste from iq's Space Curvature https://www.shadertoy.com/view/llj3Rz 
vec3 fancyCube( sampler2D sam, in vec3 d, in float s, in float b )
{
    vec3 colx = texture2D( sam, 0.5 + s*d.yz/d.x, b ).xyz;
    vec3 coly = texture2D( sam, 0.5 + s*d.zx/d.y, b ).xyz;
    vec3 colz = texture2D( sam, 0.5 + s*d.xy/d.z, b ).xyz;
    
    vec3 n = d*d;
    
    return (colx*n.x + coly*n.y + colz*n.z)/(n.x+n.y+n.z);
}

vec2 voronoi( in vec2 x )
{
    vec2 n = floor( x );
    vec2 f = fract( x );

	vec3 m = vec3( 8.0 );
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2  g = vec2( float(i), float(j) );
        vec2  o = hash2( n + g );
        vec2  r = g - f + o;
		float d = dot( r, r );
        if( d<m.x )
            m = vec3( d, o );
    }

    return vec2( sqrt(m.x), m.y+m.z );
}


vec3 background( in vec3 d, in vec3 l )
{
    vec3 col = vec3(0.0);
         col += 0.5*pow( fancyCube( iChannel1, d, 0.05, 5.0 ).zyx, vec3(2.0) );
         col += 0.2*pow( fancyCube( iChannel1, d, 0.10, 3.0 ).zyx, vec3(1.5) );
         col += 0.8*vec3(0.80,0.5,0.6)*pow( fancyCube( iChannel1, d, 0.1, 0.0 ).xxx, vec3(6.0) );
    float stars = smoothstep( 0.3, 0.7, fancyCube( iChannel1, d, 0.91, 0.0 ).x );

    
    vec3 n = abs(d);
    n = n*n*n;
    vec2 vxy = voronoi( 50.0*d.xy );
    vec2 vyz = voronoi( 50.0*d.yz );
    vec2 vzx = voronoi( 50.0*d.zx );
    vec2 r = (vyz*n.x + vzx*n.y + vxy*n.z) / (n.x+n.y+n.z);
    col += 0.9 * stars * clamp(1.0-(3.0+r.y*5.0)*r.x,0.0,1.0);

    col = 1.9*col - 0.2;
    col += vec3(-0.05,0.1,0.0);

    float s = clamp( dot(d,l), 0.0, 1.0 );
    col += 0.4*pow(s,5.0)*vec3(1.0,0.7,0.6)*2.0;
    col += 0.4*pow(s,64.0)*vec3(1.0,0.9,0.8)*2.0;

    return col;

}


//perlin noise stuff
float perlin_noise3(vec3 p){
    vec3 p0=floor(p);
    vec3 d=fract(p);

    vec3 w= d*d*(3.0-2.0*d);
    
    float lerp1=mix( 
        mix( dot( hash3( p0 ) , d ) , dot( hash3( p0+vec3(1,0,0)  ), d -vec3(1,0,0) ) , w.x ) ,
        mix( dot( hash3( p0+vec3(0,1,0) ), d-vec3(0,1,0) ) , dot( hash3( p0+vec3(1,1,0)  ), d-vec3(1,1,0) ) , w.x ),
        w.y);
    
    float lerp2=mix( 
        mix( dot( hash3( p0+vec3(0,0,1) ),d-vec3(0,0,1) ) , dot( hash3( p0+vec3(1,0,1)  ), d -vec3(1,0,1) ) , w.x ) ,
        mix( dot( hash3( p0+vec3(0,1,1) ), d-vec3(0,1,1) ) , dot( hash3( p0+vec3(1,1,1)  ), d-vec3(1,1,1) ) , w.x ),
        w.y);
    
    return mix(lerp1,lerp2,w.z);
}


//Value Noise
float value_noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}


float fbm3(vec3 p){
    float n=0.0;
    n=value_noise(p);

    float a=0.5;
    for (int i=0;i<FBM_Iteration;i++){
        n+=a*value_noise(p);
        p=p*2.0;
        a=a*0.5;
    }
    return n;
}

float sphere(vec3 p,float r){
    return length(p)- (r+ 0.8*( 0.1 + ( 0.3 * fbm3( p * 3.0  )  ) ) ) ;
}


vec2 map(vec3 p){
    vec2 res=vec2(0.0,0.4);
    float planeCol=0.4;
    float sphereCol=11.3;

    res=vec2( sphere(p-vec3(0.9,0.5,0.2),0.8), sphereCol  ) ;
    return res;
}

vec3 caclNormal(vec3 p){
    vec3 eps=vec3(0.001,0.0,0.0);
    return normalize( vec3(
            map(p+eps.xyy).x- map(p-eps.xyy).x,
            map(p+eps.yxy).x- map(p-eps.yxy).x,
            map(p+eps.yyx).x- map(p-eps.yyx).x ) );
}

mat3 rotate(float an){
    return mat3(cos(an),0,-sin(an),
                0,1,0,
                sin(an),0,cos(an)
    );
}

const float precis=0.002;
vec2 raymarch(in vec3 ro, in vec3 rd){
    float tmin=0.1;
    float tmax=20.0;
    
    float t=tmin;
    float m=-1.0;
    
    for(int i=0;i<64;i++){
        vec2 res=map(ro+rd*t);
        if (res.x<precis || t>tmax) break;
        
        t+=res.x*0.6;
        m=res.y;
    }
    
    if(t>tmax) m=-1.0;
    return vec2(t,m);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 uv=fragCoord.xy / iResolution.xy;

    vec2 p=uv-vec2(0.5);

	p.y=p.y*iResolution.y/iResolution.x;
    float precis=0.01;

    float angle=0.1*iGlobalTime+6.0*iMouse.x/iResolution.x;;

    float watchDist=3.0;
    vec3 pos= vec3(watchDist* sin(angle),0.5+cos(angle*2.0)*0.2, -watchDist* cos(angle));

    vec3 ro=pos;
    vec3 rd=normalize(vec3(p.x,p.y,1.0) );
    

    rd=rd*rotate(angle);

    
    vec3 amb=vec3(0.0);
    vec3 finalCol=vec3(1.0);
    //finalCol=texture2D(iChannel0,uv).xyz;
    vec2 res=raymarch(ro,rd);
    float t=res.x;
    float m=res.y;
    
    vec3 bgCol=finalCol;
    vec3 lig=normalize(vec3(-3.0,-0.9,1.0));
    if (m>-0.5){
        //directional light
        
        vec3 hit=ro+rd*t;
        vec3 nor=caclNormal(hit);

        vec3 resCol=0.3 * sin( vec3(0.06,0.08,0.1)* res.y );
		//resCol=vec3(0.5);
        
        float diffuse=4.6*max(0.0,dot(-lig,nor) );
        vec3 ref=reflect(-rd,nor);
        vec3 h=normalize(-lig-rd);
        float specular=1.0*pow(max(0.0,dot(h, nor) ),1.0 );

        finalCol=resCol*(diffuse+specular) +amb;
        
        //float edge = smoothstep(0., 0.2, dot(hit, nor));
		//finalCol= mix(bgCol, finalCol, edge);

		//finalCol=ref;
    }
    else{

        vec3 bghit=ro-rd*100.0;
        //finalCol=textureCube (iChannel0,bghit).xyz;
       	finalCol = background( rd, -lig );
    }
	finalCol *= smoothstep( 0.0, 6.0, iGlobalTime );

    fragColor = vec4(finalCol.xyz,1.0);
}
