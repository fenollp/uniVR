// Shader downloaded from https://www.shadertoy.com/view/XddSRB
// written by shadertoy user antonOTI
//
// Name: Alice isn't dead cover
// Description: Yet another reproduction of a cover.
//    
//    Original from https://www.youtube.com/watch?v=0DC_2eTAaEw
//    
//    Sorry for the add at the start of the track I feel like it don't belong on shadertoy
#define ORANGE vec3(255,87,30)/256.
#define RED vec3(255,0,0)/256.
#define BLACK vec3(32,28,30)/255.
#define WHITE vec3(1,1,1)
#define YELLOW vec3(255,199,10)/255.

float circle(vec2 uv, vec2 pos, float r)
{
    float d = distance(uv,pos);
	return smoothstep(d,d + .001,r);
}

float rectangle(vec2 uv, vec4 rect, vec2 sheer)
{
    rect.z += sheer.x * (uv.y - rect.y);
    rect.w += sheer.y * (uv.x - rect.x);
    rect.zw += rect.xy;
	return step(rect.x,uv.x) * step(uv.x,rect.z) * step(rect.y,uv.y) * step(uv.y,rect.w);
}

float rectangle(vec2 uv, vec4 rect)
{
	return rectangle(uv,rect,vec2(0.));
}

float skulltruck(vec2 uv, float hwi)
{
	float f = rectangle(uv,vec4(hwi + .1,.5,.055,.05));
    f = max(f,rectangle(uv,vec4(hwi, .565,.2,.075)));
    f = max(f,rectangle(uv,vec4(hwi, .640,.2,.085), vec2(-1.1,0.)));
    f = max(f,rectangle(uv,vec4(hwi, .565,.175,.155)));
    f = max(f,circle(uv,vec2(hwi + .145,.72),.03));
    f = max(f,rectangle(uv,vec4(hwi, .565,.1525,.184)));
   	f = max(f,rectangle(uv,vec4(hwi, .565,.110,.37)));
   	f = max(f,rectangle(uv,vec4(hwi, .92,.112,.06),vec2(-.5,0.)));
    f = max(f,rectangle(uv,vec4(hwi + .112,.780,.015,.10)));
    f = max(f,circle(uv,vec2(hwi + .117, .7825),.01));
    f = max(f,circle(uv,vec2(hwi + .117, .8815),.01));
    
    f = max(f,rectangle(uv,vec4(hwi + .104,.790,.015,.19)));
    
    float p = circle(uv,vec2(hwi + .100,.976),.020);
    p -=      circle(uv,vec2(hwi + .100,.976),.005);
    p = step(.975,uv.y) * step(hwi + .100,uv.x) * p;
    
    f = f + p;
   
    p = rectangle(uv,vec4(hwi+.005,.890,.100,.030));
    p = max(p,rectangle(uv,vec4(hwi+.005,.790,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.770,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.750,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.730,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.710,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.690,.050,.011)));
    p = max(p,rectangle(uv,vec4(hwi+.005,.670,.050,.011)));
    p = p * step(.662,uv.y - (uv.x - hwi) );
    p = max(p,circle(uv,vec2(hwi + .12, .660),.035));

    f -= p;
    
    return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    float wi = iResolution.x / iResolution.y;
    float hwi = wi/2.;
    
    uv.x = abs(uv.x - hwi) + hwi;
    
    float f = circle(uv,vec2(wi / 2.,.5),.45);
    
    vec3 col = ORANGE;
    vec3 white = vec3(1.);
    vec3 sunCol = mix(YELLOW,YELLOW * .5,uv.y*1.5 - 1.);
    col = mix(col,sunCol,f);
    
    f = rectangle(uv,vec4(hwi,.6,.08,.25));
    f = max(f,rectangle(uv,vec4(hwi,.889,.105,.031)));
    f = max(f,rectangle(uv,vec4(hwi + .05,.62,.11,.08)));
    col = mix(col,WHITE,f);
    
    f = skulltruck(uv,hwi);
    f = max(f,step(uv.y,.5));
    
    
    col = mix(col,BLACK,f);
    vec2 iuv = (uv - vec2(0.,.5)) * vec2(1.,-1.) + vec2(0.,.5);
    f = skulltruck(iuv,hwi);
    col = mix(col,WHITE,f);
    
    f = rectangle(iuv,vec4(hwi+.005,.890,.100,.030));
    f = f * step(uv.y * 5.5,texture2D(iChannel0,vec2(fragCoord.x/iResolution.x,.5)).x);
    col = mix(col,WHITE,f);
    
    float d = 1100.;
    float t = iGlobalTime/d;
    
    f = rectangle(iuv,vec4(hwi + .115,.650,.039,.099));
    f -= rectangle(iuv,vec4(hwi + .125,.650,.006,.099));
    f -= circle(iuv,vec2(hwi + .12, .660),.035);
    f = f * (t - .5);
    col = mix(col,RED,f);
    
    f = circle(iuv,vec2(hwi + .12, .660),.035);
    col = mix(col,mix(BLACK,RED,clamp(t,0.,1.)),f);
    
	fragColor = vec4(col,1.0);
}