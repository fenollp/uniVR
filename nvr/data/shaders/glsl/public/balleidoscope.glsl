// Shader downloaded from https://www.shadertoy.com/view/Xsd3W7
// written by shadertoy user DrLuke
//
// Name: Balleidoscope
// Description: Deep
 #define MARCHLIMIT 70

vec3 camPos = vec3(0.0, 0.0, -1.0);
vec3 ld = vec3(0.0, 0.0, 1.0);
vec3 up = vec3(0.0, 1.0, 0.0);
vec3 right = vec3(1.0, 0.0, 0.0);
vec3 lightpos = vec3(1.5, 1.5, 1.5);


// Smooth HSV to RGB conversion 
vec3 hsv2rgb_smooth( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing	

	return c.z * mix( vec3(1.0), rgb, c.y);
}

vec4 range(vec3 p)
{

    // Sphere with Radius
    vec3 spherepos = vec3(0.0, 0.0, 0.0);
    float radius = log(sin(iGlobalTime*0.1)*0.05+1.0)+0.1;
	
    //float anim = floor(cos(iGlobalTime*0.4)+1.0);
    float anim = smoothstep(0., .1, cos(iGlobalTime*0.4)+1.0);
    
    //float anim2 = floor(-cos(iGlobalTime*0.4)+1.0);
    float anim2 = smoothstep(0., .1, -cos(iGlobalTime*0.4)+1.0);
    
    float xampl = sin(iGlobalTime*1.3)*0.4*anim;
    float yampl = sin(iGlobalTime*1.3)*0.4-(anim2*0.3);
    
    p.x += cos((max(-2.0+p.z-camPos.z,0.)))*xampl-xampl;
    p.y += sin((max(-2.0+p.z-camPos.z,0.)))*yampl;
    
    
    p = mod(p + vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0)) - vec3(0.5,0.5,0.5);
    spherepos = mod(spherepos + vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0)) - vec3(0.5,0.5,0.5);
    
    vec3 diff = p - spherepos;
    
    vec3 normal = normalize(diff);

    
    return vec4(normal, length(diff)-radius);
}

vec3 lerp(vec3 a, vec3 b, float p)
{
    p = clamp(p,0.,1.);
 	return a*(1.0-p)+b*p;   
}


vec4 march(vec3 cam, vec3 n)
{
    
    float len = 1.0;
    vec4 ret;
    
    for(int i = 0; i < MARCHLIMIT; i++)
    {
        ret = range(camPos + len*n)*0.5;
		len += ret.w;
    }
    
	return vec4(ret.xyz, len);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float colorangle = 0.;
    
	vec2 uv = (fragCoord.xy*2.0) / iResolution.xy - vec2(1, 1);
    uv.x *= iResolution.x / iResolution.y;
    
    float rotangle = iGlobalTime*0.08;
    vec2 newuv;
    newuv.x = uv.x*cos(rotangle)-uv.y*sin(rotangle);
    newuv.y = uv.x*sin(rotangle)+uv.y*cos(rotangle);
    uv = newuv;
    
    camPos = vec3(0.5, 0.5, iGlobalTime*1.0);

    //ld = normalize(vec3(0.0, sin(iGlobalTime*0.8)*0.1, cos(iGlobalTime*0.8)*0.5));
    float zoom = 0.6;
    vec3 n = normalize(vec3(sin(uv.x*3.1415*zoom),sin(uv.y*3.1415*zoom) ,ld.z*cos(uv.x*3.1415*zoom)*cos(uv.y*3.1415*zoom)));
    vec4 rangeret = march(camPos, n);
    float d = log(rangeret.w / 1.0 + 1.0);
    vec3 normal = rangeret.xyz;
    
    vec3 p = camPos + n*d;
    float angle = acos(dot(normal, n)/length(normal)*length(n));
    
	fragColor = vec4(hsv2rgb_smooth(lerp(vec3(d*0.1 + (colorangle + iGlobalTime)*0.01 + atan(uv.y/uv.x)*3.1415 , 2.0, max(1.0 - log(d),0.0)),vec3(d*0.1 + ((colorangle + iGlobalTime)+120.0)*0.01 , 2.0, max(1.0 - log(d),0.0)),cos(angle/10.0))),1.0);
}