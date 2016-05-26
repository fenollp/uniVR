// Shader downloaded from https://www.shadertoy.com/view/XddXR8
// written by shadertoy user dine909
//
// Name: Perspective vs Orthogonal
// Description: An experiment mixing perspective and orthogonal projection.&lt;br/&gt;&lt;br/&gt;Line #56 is responsible for the change. &lt;br/&gt;&lt;br/&gt;I think i'm going to be sick.
#define PI 3.14159265359
#define MAX_DIST 200.
#define MIN_DIST .00020
#define precis 0.00001


#define IF_EQ(a,b) step(abs(a-b),0.)
#define REP(p,c) (mod(p,c)-0.5*c)
#define mapMin(a,b) mix(a,b,step(b.x,a.x))
const  vec3 eps = vec3( 0.004, 0.0, 0.0 );
struct Ray{vec3 ro,rd;float tmin ,tmax;vec3 hit;vec3 nor;}T_Ray;
Ray newRay(vec3 ro,vec3 rd){return Ray(ro,rd,MIN_DIST,MAX_DIST,vec3(0.),vec3(0.));}

float isInside( vec2 p, vec2 c ) { vec2 d = abs(p-0.5-c) - 0.5; return -max(d.x,d.y); }


float sdBox( vec3 p, vec3 b )
{
    vec3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) +
        length(max(d,0.0));
}
vec3 map(vec3 p)
{
    vec3 res=vec3(100.);
    res=mapMin(res,vec3(p.y,1.,0.));
    res=mapMin(res,vec3(sdBox(REP(p,vec3(05.,9.,5.)),vec3(1.,1.,1.)),5.,0.));
    res=mapMin(res,vec3(p.z+10.,4.,0.));
    return res;
}
vec3 calcNormal( in vec3 pos )
{
   
    vec3 nor = vec3(map(pos+eps.xyy).x - map(pos-eps.xyy).x,map(pos+eps.yxy).x - map(pos-eps.yxy).x,map(pos+eps.yyx).x - map(pos-eps.yyx).x );
    return normalize(nor);
}
vec3 castRay(inout Ray ray){
    float t = ray.tmin;
    vec3 res=vec3(0.);
    ray.hit=vec3(0.);
    for( int i=0; i<200; i++ )
    {
        ray.hit=ray.ro+ray.rd*t;
        res = map( ray.hit );
        if( res.x<precis || t>ray.tmax ) break;
        t += res.x;
    }
    res.x=res.z;
    res.z=t;
    return res*=step(t,ray.tmax);
}

Ray getCamera(vec2 p,in vec3 pos)
{
    //camera
    float ort=0.5+0.5*sin(iGlobalTime*0.5);
    Ray ray = newRay(vec3(0.),normalize(vec3(mix(p,vec2(0.,0.),ort),-1.)));

    //adjustments for ortho
    ray.ro.y+=mix(0.,10.-pos.y,ort);
    ray.ro.xy+=(p)*20.*ort;

    //eye position 
    ray.ro+=pos.xyz;

    return ray;

}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    float srat=iResolution.x/iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x*=srat;
    
    vec3 col=vec3(0.);

    //initial view projection & sky
    vec4 vPos=vec4(iGlobalTime,02.,20.,0.);

    Ray ray=getCamera(uv-vec2(0.5*srat,0.5),vPos.xyz);

    vec3 res=castRay(ray);

    ray.nor = calcNormal( ray.hit );
    vec3 bcol = ((vec3(0.1, 0.7, .90)+ray.rd.y*-0.8)) *0.5 ;
	
    col += IF_EQ(5.,res.y) * (vec3(.5,.5,1.25) );

    #define PlaneTex(p) max(smoothstep(0.97,1.,cos(p.x*PI)),smoothstep(0.97,1.,cos(p.y*PI))))
	col += IF_EQ(1.,res.y) * (vec3(1.)* PlaneTex(ray.hit.xz) +.1;
    col += IF_EQ(4.,res.y) * (vec3(1.)* PlaneTex(ray.hit.xy) +.1;


    //lighting
    #define MDiffCol 	vec3(1.,1.,1.) *1.
    #define MSpecCol 	vec3(1.,1.,1.) *1.
    #define LCol 		vec3(1.,1.,1.)
    #define LPower 		30.
    #define MAmbient	 	vec3(1.) * 0.01

    vec3 lcol=vec3(1.);

    vec3 lig = (vec3(iGlobalTime-3.,07.,03.4));
    vec3 ref = reflect( (lig), ray.nor );
    float cosAlpha = clamp( dot( normalize(ray.rd),ref ), 0.,1. );
    float dis=pow(distance(lig,(ray.hit)),2.);
    lcol *= MAmbient + MDiffCol * LCol * LPower * clamp(dot( ray.nor,(lig) ),0.,1.) / dis;
    //   lcol += MSpecCol * LCol * LPower * pow(cosAlpha,5.) / dis;

    col=pow(col*lcol, vec3(1./2.2));

       col = mix( col, vec3(0.8,0.9,1.0)*0.35, 1.-MAmbient*(0.9)-exp( -0.000425*pow(res.z,2.) ) );

    fragColor = vec4(mix(col,bcol,IF_EQ(0.,res.y)),1.0);
}