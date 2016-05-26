// Shader downloaded from https://www.shadertoy.com/view/4s3GW2
// written by shadertoy user Dave_Hoskins
//
// Name: Fractal Explorer
// Description: MOUSE click to turn. WASD (or cursor keys) to move. SPACE/SHIFT for speed up. Camera movement is click and drag.
// Fractal Explorer. January 2016
// by David Hoskins
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/4s3GW2

//--------------------------------------------------------------------------
#define SUN_COLOUR vec3(1., .9, .85)
#define FOG_COLOUR vec3(.15, 0.15, 0.17)
#define MOD3 vec3(.1031,.11369,.13787)
#define TAU 6.28318530718
#define STORE_DE

vec3 CSize;
vec4 eStack[2];
vec4 dStack[2];
vec2 fcoord;

vec2 camStore = vec2(0.0,  0.0);
vec2 rotationStore	= vec2(1.,  0.);
vec2 mouseStore = vec2(2.,  0.);
vec3 sunLight  = vec3(  0.4, 0.4,  0.3 );

// By TekF...
void BarrelDistortion( inout vec3 ray, float degree )
{
	ray.z /= degree;
	ray.z = ( ray.z*ray.z - dot(ray.xy,ray.xy) );
	ray.z = degree*sqrt(ray.z);
}

//--------------------------------------------------------------------------
vec3 loadValue3( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 ).xyz;
}
vec2 loadValue2( in vec2 re )
{
    return texture2D( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 ).xy;
}

//----------------------------------------------------------------------------------------
// From https://www.shadertoy.com/view/4djSRW
float Hash(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

mat3 RotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

//----------------------------------------------------------------------------------------
vec3 Colour( vec3 p)
{
    p = p.xzy;
	float col	= 0.0;
    float r2	= dot(p,p);
	for( int i=0; i < 5;i++ )
	{
		vec3 p1= 2.0 * clamp(p, -CSize, CSize)-p;
		col += abs(p.x-p1.z);
		p = p1;
		r2 = dot(p,p);
        //float r2 = dot(p,p+sin(p.z*.3)); //Alternate fractal
		float k = max((2.)/(r2), 0.027);
		p *= k;
	}
    return texture2D(iChannel3, vec2(p.x+p.z, p.y)*.2).xyz+vec3(.4, .2, 0.2);
}

//--------------------------------------------------------------------------

float Map( vec3 p )
{
	p = p.xzy;
	float scale = 1.;
	for( int i=0; i < 12;i++ )
	{
		p = 2.0*clamp(p, -CSize, CSize) - p;
		float r2 = dot(p,p);
        //float r2 = dot(p,p+sin(p.z*.3)); //Alternate fractal
		float k = max((2.)/(r2), .027);
		p     *= k;
		scale *= k;
	}
	float l = length(p.xy);
	float rxy = l - 4.0;
	float n = l * p.z;
	rxy = max(rxy, -(n) / 4.);
	return (rxy) / abs(scale);
}



//--------------------------------------------------------------------------
float Shadow( in vec3 ro, in vec3 rd)
{
	float res = 1.0;
    float t = 0.05;
	float h;
	
    for (int i = 0; i < 15; i++)
	{
		h = Map( ro + rd*t );
		res = min(5.0*h / t, res);
		t += h+.01;
	}
    return max(res, 0.0);
}

//--------------------------------------------------------------------------
vec3 DoLighting(in vec3 mat, in vec3 pos, in vec3 normal, in vec3 eyeDir, in float d, in float sh)
{
    vec3 sunLight  = normalize( vec3(  0.4, 0.4,  0.3 ) );
//	sh = Shadow(pos,  sunLight);
    // Light surface with 'sun'...
	vec3 col = mat * SUN_COLOUR*(max(dot(sunLight,normal), 0.0)) *sh;
    //col += mat * vec3(0., .0, .15)*(max(dot(-sunLight,normal), 0.0));
    
    normal = reflect(eyeDir, normal); // Specular...
    col += pow(max(dot(sunLight, normal), 0.0), 12.0)  * SUN_COLOUR * .5 *sh;
    // Abmient..
    col += mat * .2 * max(normal.y, 0.2);
    col = mix(FOG_COLOUR,col, min(exp(-d*d*.015), 1.0));
    
	return col;
}


//--------------------------------------------------------------------------
vec3 GetNormal(vec3 p, float sphereR)
{
	vec2 eps = vec2(sphereR*.5, 0.0);
	return normalize( vec3(
           Map(p+eps.xyy) - Map(p-eps.xyy),
           Map(p+eps.yxy) - Map(p-eps.yxy),
           Map(p+eps.yyx) - Map(p-eps.yyx) ) );
}

//--------------------------------------------------------------------------
float SphereRadius(in float t)
{
    t = t * .01*(400./iResolution.y);
    return (t*t+0.005);
}

//--------------------------------------------------------------------------
float Scene(in vec3 rO, in vec3 rD)
{
	float  alphaAcc = 0.0;
	float t = .05 * Hash(fcoord);
	
	vec3 p = vec3(0.0);
    int hits = 0;

	for( int j=0; j < 120; j++ )
	{
		if (hits == 8 || t > 14.0) break;
		p = rO + t*rD;
		float sphereR = SphereRadius(t);
		float de = Map(p);
        // Is it within the sphere?...
		if( de < sphereR)
		{
			// Accumulate the alphas with the scoop of geometry from the sphere...
            // Think of it as an expanding ice-cream scoop flying out of the camera! 
            // Rotate the stack and insert new value!...
            
			eStack[1].yzw = eStack[1].xyz; eStack[1].x = eStack[0].w;
			eStack[0].yzw = eStack[0].xyz;
            #ifdef STORE_DE
            eStack[0].x = de-.001;
            #else
            float alpha = (1.0 - alphaAcc) * min(((sphereR-de+.001) / sphereR), 1.0);
            
            eStack[0].x = alpha;
            #endif
			dStack[1].yzw = dStack[1].xyz; dStack[1].x = dStack[0].w;
			dStack[0].yzw = dStack[0].xyz; dStack[0].x = t;
			hits++;
            #ifndef STORE_DE
   			alphaAcc += alpha;
            #endif

        }
		t +=  de +.003;
         
	}
	
	return clamp(alphaAcc, 0.0, 1.0);
}

//--------------------------------------------------------------------------
vec3 PostEffects(vec3 rgb, vec2 xy)
{
	// Gamma first...
	rgb = pow(rgb, vec3(0.45));

	// Then...
	#define CONTRAST 1.4
	#define SATURATION 1.3
	#define BRIGHTNESS 1.3
	rgb = mix(vec3(.5), mix(vec3(dot(vec3(.2125, .7154, .0721), rgb*BRIGHTNESS)), rgb*BRIGHTNESS, SATURATION), CONTRAST);

	// Vignette...
	rgb *= .4+0.6*pow(180.0*xy.x*xy.y*(1.0-xy.x)*(1.0-xy.y), 0.35);	

	return clamp(rgb, 0.0, 1.0);
}

//--------------------------------------------------------------------------
vec3 TexCube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec3 x = texture2D( sam, p.yz ).xzy;
	vec3 y = texture2D( sam, p.zx ).xyz;
	vec3 z = texture2D( sam, p.xy ).yzx;
	return (x*abs(n.x) + y*abs(n.y) + z*abs(n.z))/(abs(n.x)+abs(n.y)+abs(n.z));
}

//--------------------------------------------------------------------------
vec3 Albedo(vec3 pos, vec3 nor)
{
    vec3 col = TexCube(iChannel1, pos*1.3, nor).zxy;
    col *= Colour(pos);
    return col;
}

//----------------------------------------------------------------------------------------

vec2 rot2D(inout vec2 p, float a)
{
    return cos(a)*p - sin(a) * vec2(p.y, -p.x);
}

//--------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fcoord = fragCoord;
	float m = (iMouse.x/iResolution.x)*20.0;
	float gTime = ((iGlobalTime+26.)*.2+m);
    vec2 xy = fragCoord.xy / iResolution.xy;
	vec2 uv = (-1. + 2.0 * xy) * vec2(iResolution.x/iResolution.y,1.0);

    CSize = vec3(1., 1., 1.3);
	
    vec3 cameraPos= loadValue3(camStore).xyz;
    vec2 mou = loadValue2(rotationStore);

    mou*= TAU;
    mat3 mZ = RotationMatrix(vec3(.0, .0, 1.0), sin(iGlobalTime*.2)*.1);
    mat3 mX = RotationMatrix(vec3(1.0, .0, .0),  mou.y);
    mat3 mY = RotationMatrix(vec3(.0, 1.0, 0.0),-mou.x);
    mX = mY * mX * mZ;
    vec3 dir = vec3(uv.x, uv.y, 1.2);
    BarrelDistortion(dir, .5);
    dir = mX * normalize(dir);
    


	vec3 col = vec3(.0);
	
    for (int i = 0; i < 2; i++)
    {
		dStack[i] = vec4(-20.0);
        eStack[i] = vec4(0.0);
    }
     #ifdef STORE_DE
    float alphaAcc = 0.0;
    Scene(cameraPos, dir);
    #else
	float alphaAcc = Scene(cameraPos, dir);
    #endif
	


    // Find the first hit for the shadow...
    float d = 0.;
    float de = -2.0;
     for (int s = 1; s >= 0; s--)
    {
		for (int i = 3; i >= 0; i--)
    	{
            if (dStack[s][i] > -19.0)
            {
            	d = dStack[s][i];
            }
        }
    }
    //...The gamble pays off it seems....
	vec3 p = cameraPos + dir * d;
    float sha = Shadow(p, sunLight);

        
    // Render both stacks...
    for (int s = 1; s >= 0; s--)
    {
		for (int i = 3; i >= 0; i--)
    	{
        	float d = dStack[s][i];
        	if (d  > -19.)
            {
                float sphereR = SphereRadius(d);

                 #ifdef STORE_DE
                float  de = eStack[s][i];
                float alpha = (1.0 - alphaAcc) * min(((sphereR-de) / sphereR), 1.0);
                #else
                float  alpha = eStack[s][i];
                #endif

                vec3 pos = cameraPos + dir * d;
                vec3 normal = GetNormal(pos, sphereR);
                vec3 alb = Albedo(pos, normal);
                col += DoLighting(alb, pos, normal, dir, d, sha) * alpha;
                #ifdef STORE_DE
                alphaAcc+= alpha;
                #endif
            }
		}
    }
    // Fill in the rest with fog...
   col += FOG_COLOUR *  clamp((1.0-alphaAcc), 0., 1.);
   
   
	col = PostEffects(col, xy) * smoothstep(.0, 2.0, iGlobalTime);	
	
	fragColor=vec4(col,1.0);
}

//--------------------------------------------------------------------------