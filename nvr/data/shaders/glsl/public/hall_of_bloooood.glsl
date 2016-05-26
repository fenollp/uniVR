// Shader downloaded from https://www.shadertoy.com/view/ldySzW
// written by shadertoy user VirtuosoChris
//
// Name: Hall of Bloooood
// Description: it's blood.
const vec3 oceanFloorEmissive = vec3(.1, .02, .02);

const float PI=3.1415926545;
const float oceanWidth=1.0;

float intersectPlane(vec3 ray,float height)
{
    return height/ray.y;
}

vec3 cameraRay(vec2 uv)
{
	return normalize(vec3(uv.xy*2.0-1.0,-1.0)*vec3(iResolution.x/iResolution.y,1.0,1.0));
}

const float totalAmplitude = 0.787592;

float waveHeight(vec2 xz, float t, vec2 waveDir, float exponent, float wavelength, float amplitude, float speed)
{
    
    float frequency = 2.0 * 3.14159 / wavelength;

    float phaseConstant = speed * frequency;

    float trigParam = dot(waveDir, xz) * frequency + t * phaseConstant;
  
    float sineNum = sin(trigParam);

    float sineTerm = pow(.5 * (sineNum + 1.0), exponent);

	return sineTerm * amplitude;
}

vec2 waveGradient(vec2 xz, float t, vec2 waveDir, float exponent, float wavelength, float amplitude, float speed)
{
    
    
    float frequency = 2.0 * 3.14159 / wavelength;

    float phaseConstant = speed * frequency;

    float trigParam = dot(waveDir, xz) * frequency + t * phaseConstant;

    float cosineTerm = cos(trigParam);

    float sineNum = sin(trigParam);

    float sineTerm = pow(.5 * (sineNum + 1.0), exponent - 1.0);

    float waveFunc = exponent * frequency * amplitude * sineTerm * cosineTerm;

    vec2 derivs = waveDir * waveFunc;

    return derivs;
}


vec2 totalGradient(vec2 tc, float time)
{
    return waveGradient (tc, time, vec2(0.124943, 0.992164), 1.0, 1.88928, 0.141696, 1.71661)
	+waveGradient (tc, time, vec2(0.887061, 0.461651), 1.0, 1.84052, 0.138039, 1.69431)
	+waveGradient (tc, time, vec2(-0.0974991, 0.995236), 1.0, 0.988473, 0.0741355, 1.24167)
	+waveGradient (tc, time, vec2(0.843671, 0.53686), 1.0, 0.879293, 0.065947, 1.17109)
	+waveGradient (tc, time, vec2(0.159448, 0.987206), 1.0, 0.877588, 0.0658191, 1.16995)
	+waveGradient (tc, time, vec2(0.552634, 0.833424),1.0, 0.428791, 0.0321593, 0.817798)
	+waveGradient (tc, time, vec2(0.624894, 0.78071), 1.0, 0.399053, 0.029929, 0.788931)
    +waveGradient (tc, time, vec2(0.872831, 0.488022), 1.0, 0.394675, 0.0296006, 0.78459)
    +waveGradient (tc, time, vec2(0.926811, 0.375527), 1.0, 0.393116, 0.0294837, 0.783039)
    +waveGradient (tc, time, vec2(0.139784, 0.990182), 1.0, 0.377771, 0.0283328, 0.767605)
    +waveGradient (tc, time, vec2(0.370184, 0.928958), 1.0, 0.363149, 0.0272362, 0.752603)
    +waveGradient (tc, time, vec2(0.58627, 0.810116),1.0, 0.362489, 0.0271867, 0.751918)
    +waveGradient (tc, time, vec2(0.976126, -0.217206),1.0, 0.336881, 0.025266, 0.724872)
    +waveGradient (tc, time, vec2(0.780811, 0.624767), 1.0, 0.327074, 0.0245305, 0.714243)
    +waveGradient (tc, time, vec2(0.0217235, 0.999764), 1.0, 0.322161, 0.0241621, 0.708859)
    +waveGradient (tc, time, vec2(0.733764, 0.679405), 1.0, 0.320912, 0.0240684, 0.707484);
}

float totalWaveHeight(vec2 tc, float time)
{
	return waveHeight (tc, time, vec2(0.124943, 0.992164), 1.0, 1.88928, 0.141696, 1.71661)
	+waveHeight (tc, time, vec2(0.887061, 0.461651), 1.0, 1.84052, 0.138039, 1.69431)
	+waveHeight (tc, time, vec2(-0.0974991, 0.995236), 1.0, 0.988473, 0.0741355, 1.24167)
	+waveHeight (tc, time, vec2(0.843671, 0.53686), 1.0, 0.879293, 0.065947, 1.17109)
	+waveHeight (tc, time, vec2(0.159448, 0.987206), 1.0, 0.877588, 0.0658191, 1.16995)
	+waveHeight (tc, time, vec2(0.552634, 0.833424),1.0, 0.428791, 0.0321593, 0.817798)
	+waveHeight (tc, time, vec2(0.624894, 0.78071), 1.0, 0.399053, 0.029929, 0.788931)
    +waveHeight (tc, time, vec2(0.872831, 0.488022), 1.0, 0.394675, 0.0296006, 0.78459)
    +waveHeight (tc, time, vec2(0.926811, 0.375527), 1.0, 0.393116, 0.0294837, 0.783039)
    +waveHeight (tc, time, vec2(0.139784, 0.990182), 1.0, 0.377771, 0.0283328, 0.767605)
    +waveHeight (tc, time, vec2(0.370184, 0.928958), 1.0, 0.363149, 0.0272362, 0.752603)
    +waveHeight (tc, time, vec2(0.58627, 0.810116),1.0, 0.362489, 0.0271867, 0.751918)
    +waveHeight (tc, time, vec2(0.976126, -0.217206),1.0, 0.336881, 0.025266, 0.724872)
    +waveHeight (tc, time, vec2(0.780811, 0.624767), 1.0, 0.327074, 0.0245305, 0.714243)
    +waveHeight (tc, time, vec2(0.0217235, 0.999764), 1.0, 0.322161, 0.0241621, 0.708859)
    +waveHeight (tc, time, vec2(0.733764, 0.679405), 1.0, 0.320912, 0.0240684, 0.707484);

}

vec2 gradient(vec3 pos)
{
	return totalGradient(pos.xz,iGlobalTime)*.01;
}

float height(vec3 pos)
{
    return totalWaveHeight(pos.xz,iGlobalTime)*.01;
}

float binsearch(float tbottom,float ttop,vec3 a,vec3 b)
{
    float t=0.0;
    for(int i=0;i<16;i++)
    {
        t=(tbottom+ttop)*0.5;
        
        if((height(a+b*t)-a.y)/b.y > (1.0-t))
        {
        	ttop=t;   
        }
        else
        {
        	tbottom=t;   
        }
    }
    return t;
}

vec3 reflectedRay(vec3 ray,float cameraHeight, out vec3 normal)
{
    float tTop=intersectPlane(ray,-cameraHeight+oceanWidth);
    float tBottom=intersectPlane(ray,-cameraHeight);
    vec3 oceanTopIntersect=ray*tTop+vec3(0.0,cameraHeight,0.0);
	vec3 oceanBottomIntersect=ray*tBottom+vec3(0.0,cameraHeight,0.0);
    
	vec3 a=oceanTopIntersect;
    vec3 b=oceanBottomIntersect-oceanTopIntersect;
    
   
    
    float t=0.0;
    float mint=0.0;
    const int numiters=16;
    vec3 pos;
    for(int i=0;i<numiters;i++)
    {
        t=float(i)/float(numiters);
        pos=a+b*t;
		float to=(height(pos)-a.y)/b.y;
        to=abs(to);
        if((1.0-to) < t)
        {
           break;   
        }
    }
    
  
    
    t=binsearch(t-1.0/float(numiters),t,a,b);
    pos=a+b*t;
    vec3 n=vec3(-gradient(pos),1.0);
    
    n = n.xzy;
    
    n=normalize(n);
    
    normal = n;
    
    //y.y=-ray.y;
   //ay.x=-ray.x;
    ray=reflect(ray,n);
   
    return ray;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 ray=cameraRay(uv);
    
    float cameraHeight=2.;
    float t=intersectPlane(ray,-cameraHeight-oceanWidth);

   
    if(t > 0.0)
    {
    
    
        vec3 normal;
     
        vec3 ray = normalize(reflectedRay(ray,cameraHeight, normal));
        
        ray.y=-ray.y;
        
        normal = normalize(normal);
        ray = normalize(ray);
        
        vec3  colorTex = 2.0*textureCube(iChannel0,ray).rgb;		
        
        const vec3 specularColor = vec3(1, .02, .02); 
        
    	float interp =  pow(1.0 - clamp(dot(-ray, normal),0.0,1.0),3.5);
    	vec3 reflectance = specularColor + (vec3(1.0) - specularColor)*interp;
    
    	/// output color in linear space
    	vec3 linearColor = mix( oceanFloorEmissive, reflectance*colorTex, interp);
        fragColor = vec4(linearColor, 1.0);
        
    }
    else
    {
        ray.y=-ray.y;
     	fragColor = 2.0*vec4(textureCube(iChannel0,ray).rgb,1.0);   
    }
    
    
    
    
}