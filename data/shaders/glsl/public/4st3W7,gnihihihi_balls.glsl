// Shader downloaded from https://www.shadertoy.com/view/4st3W7
// written by shadertoy user DrLuke
//
// Name: Gnihihihi Balls
// Description: Just some Raymarching balls
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
	
    // Sinewave effect
    //										  V this cosine with floor acts as a toggle 
    float xampl = sin(iGlobalTime*1.3)*0.4*floor(cos(iGlobalTime*0.4)+1.0);
    float yampl = sin(iGlobalTime*1.3)*0.4-(floor(-cos(iGlobalTime*0.4)+1.0)*0.3);
    
    p.x += cos((max(-2.0+p.z-camPos.z,0.)))*xampl-xampl;
    p.y += sin((max(-2.0+p.z-camPos.z,0.)))*yampl;
    
    // Pulsating effect
    p.x *= -min(+2.0+p.z-camPos.z,0.)*sin(iGlobalTime*3.0)*0.1 + 1.0;
    p.y *= -min(+2.0+p.z-camPos.z,0.)*sin(iGlobalTime*3.0)*0.1 + 1.0;
    
    p = mod(p + vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0)) - vec3(0.5,0.5,0.5);
    spherepos = mod(spherepos + vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0)) - vec3(0.5,0.5,0.5);
    
    vec3 diff = p - spherepos;
    
    vec3 normal = normalize(diff);

    
    return vec4(normal, length(diff)-radius);
}

// Basic linear interpolation (Only used in the fresnel effect
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
	vec2 uv = (fragCoord.xy*1.0) / iResolution.xy - vec2(0.5, 0.5);
    uv.x *= iResolution.x / iResolution.y;
    
    float rotangle = iGlobalTime*0.08;
    vec2 newuv;
    newuv.x = uv.x*cos(rotangle)-uv.y*sin(rotangle);
    newuv.y = uv.x*sin(rotangle)+uv.y*cos(rotangle);
    uv = newuv;
    
    camPos = vec3(0.5, 0.5, iGlobalTime*1.0);

    ld = normalize(vec3(0.0, sin(iGlobalTime*0.8)*0.1, cos(iGlobalTime*0.8)*0.5));
    
    // This is the raymarching vector. It is calculated by interpreting the uv coordinates as angles, and thus rotating
    // the ld (lookdirection) vector by the given angle. It is then used as the direction for the ray to march in.
    // With this projection you can see the full 360° around you. Try changing the zoom to something like 1.5
    float zoom = 0.6;
    vec3 n = normalize(vec3(sin(uv.x*3.1415*zoom),sin(uv.y*3.1415*zoom) ,ld.z*cos(uv.x*3.1415*zoom)*cos(uv.y*3.1415*zoom)));
    
    vec4 rangeret = march(camPos, n); // March rays from the camera in the direction of n
    
    float d = log(rangeret.w / 1.0 + 1.0);	// Take logarithm of distance to make transition more smooth for further away objects
    vec3 normal = rangeret.xyz;	// Extract normal from return vector
    
    // Calculate angle between the raymarching ray and normal (I think this is broken, but it looks good)
    vec3 p = camPos + n*d;
    float angle = acos(dot(normal, n)/length(normal)*length(n));
    
    //                | I'm Using the HSV colorspace for fancy colors 
    //                |               | Interpolation between normal color and reflection color depending on the angle of the normal
    //                |               |    | Fade through colors depending on distance and time (H), also fade to black in the distance (V), (S) stays fixed to 2
    //                |               |    |                                                         | reflection color is just a color from the current time +120second
    //                |               |    |                                                         |                                                                   | parameter used for lerp
	fragColor = vec4(hsv2rgb_smooth(lerp(vec3(d*0.1 + iGlobalTime*0.01, 2.0, max(1.0 - log(d),0.0)),vec3(d*0.1 + (iGlobalTime+120.0)*0.01 , 2.0, max(1.0 - log(d),0.0)),cos(angle/10.0))),1.0);
}