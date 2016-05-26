// Shader downloaded from https://www.shadertoy.com/view/4dK3Rt
// written by shadertoy user blueeyeworld
//
// Name: Audio Chill Tracer
// Description: audio chill tracer, with SoundCloud. 
#define SPHERE_COUNT 128

//Created by Nicky van de Groep
//www.nickyvandegroep.com


vec4 Light      = vec4(10.0,5.0, 0.0, 0.5);
vec4 LightColor = vec4(1.0,1.0, 1.0, 1.0);


vec3 CamPos, CamDirection;

struct Camera
{
 	vec3 pos;
    float left;
    float right;
    float top;
    float down;
    float near;
    float far;
};
    
Camera camera = Camera(vec3(0.0,0.0,-8.0), -1.6, 1.6, 1.0, -1.0, 1.0, 1.0);
    
mat4 Identity()
{
     return mat4(
        vec4( 1.0, 0.0, 0.0, 0.0),
        vec4( 0.0, 1.0, 0.0, 0.0),
        vec4( 0.0, 0.0, 1.0, 0.0),
        vec4( 0.0, 0.0, 0.0, 1.0)
    );
}

mat4 SetPosition(mat4 mat, vec3 pos)
{
    mat[3][0] = pos.x;
    mat[3][1] = pos.y;
    mat[3][2] = pos.z;
    return mat;
}

mat4 rotationZYX(vec3 radiansXYZ )
{
    float sX, cX, sY, cY, sZ, cZ, tmp0, tmp1;
    sX = sin( radiansXYZ[0]);
    cX = cos( radiansXYZ[0]);
    sY = sin( radiansXYZ[1]);
    cY = cos( radiansXYZ[1]);
    sZ = sin( radiansXYZ[2]);
    cZ = cos( radiansXYZ[2]);
    tmp0 = ( cZ * sY );
    tmp1 = ( sZ * sY );
    return mat4(
        vec4( ( cZ * cY ), ( sZ * cY ), -sY, 0.0 ),
        vec4( ( ( tmp0 * sX ) - ( sZ * cX ) ), ( ( tmp1 * sX ) + ( cZ * cX ) ), ( cY * sX ), 0.0 ),
        vec4( ( ( tmp0 * cX ) + ( sZ * sX ) ), ( ( tmp1 * cX ) - ( cZ * sX ) ), ( cY * cX ), 0.0 ),
        vec4(0.0, 0.0, 0.0,1.0)
    );
}


float IntersectSphere(vec3 start, vec3 dir, vec4 sphere, out vec3 pos, out vec3 normal, out float t)
{
    vec3 rc = start-sphere.xyz;
    float c = dot(rc, rc) - (sphere.w*sphere.w);
    float b = dot(dir, rc);
    float d = b*b - c;
	t = -b - sqrt(abs(d));
    
	float st = step(0.0, min(t,d));
    
    pos = start + dir * t;
    normal = pos - sphere.xyz;
    normal = normalize(normal);
    return mix(-1.0, t, st);
}

vec4 TraceScene(vec3 direction)
{  
    vec3  outpos;
    vec3  outnormal;
    float mint = 1000.0;
    float k = (1.0 / float(SPHERE_COUNT));
    
    float halfcount = float(SPHERE_COUNT) * 0.5;
    
    vec4 high  = texture2D(iChannel0, vec2(0.7, 0.0));
    vec4 bass1 = texture2D(iChannel0, vec2(0.1, 0.0));
    
    // camera.pos.z;
    float t;
    
    vec3 FinalNormal;
    vec3 FinalPosition;
    vec3 FinalColor;
    
     mat4 mat = Identity();
     mat *= rotationZYX(vec3(0.0,-iChannelTime[0] * 0.1, 0.0));
     vec4 newlightpos = mat * vec4(Light.xyz ,1.0);
      Light.xyz = newlightpos.xyz;
    
    
    float res = IntersectSphere(camera.pos, direction, Light, outpos, outnormal, t);
    if(res >= 0.0)
    {
        if(t < mint)
        {
            mint = t;
           	FinalNormal   = -outnormal;
            FinalPosition = outpos;
            FinalColor    = (LightColor * 2.0 * dot(vec3(0.0, 0.0, -1.0), outnormal)).xyz;
        }
    }
    
    for(int i = 0; i < SPHERE_COUNT; i++)
    {
        vec4 sound = texture2D(iChannel0, vec2(float(i) * k, 0.0));
        
        float x = -5.0 + (float(i) * k) * 10.0;
        float y =  -4.0 + sound.x * 8.0;
        
        mat4 mat = Identity();
        mat *= rotationZYX(vec3(iChannelTime[0] * 0.3, iChannelTime[0] * 0.1, 0.0));
        vec4 newpos = mat * vec4(x, y, 0.0 ,1.0);
        
        if(dot(direction, normalize(camera.pos - newpos.xyz)) > -0.99){ continue; }
        
        float res = IntersectSphere(camera.pos, direction, vec4(newpos.xyz , 0.1 + bass1.x * 0.2), outpos, outnormal, t);
    	if(res >= 0.0)
    	{  
           if(t < mint)
           {
               mint = t;
           	   FinalNormal   = outnormal;
               FinalPosition = outpos;
               FinalColor    = vec3(sound.x * direction.x * 2.0, sound.x * direction.y * 2.0, sound.z * direction.z) * 2.0; 
           }
    	}
    }
    
    
   	
    if(mint < 1000.0)
    {
         return vec4(FinalColor * LightColor.xyz * clamp( dot(Light.xyz - FinalPosition, FinalNormal), 0.1, 1.0) , 1.0);
    }
    
    
    
   	//float res = IntersectSphere(camera.pos, direction, Sphere1, outpos, outnormal);
    //if(res >= 0.0)
    //{
    //   //return vec4(1.0, 1.0, 1.0, 1.0);
    //    
    //    return vec4(vec3(1.0, 1.0, 1.0) *dot(vec3(0.1, 0.0, -0.9), outnormal) , 1.0);
    //}
    return vec4(0.1,0.1,0.1,1.0);
   
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float x = fragCoord.x;
    float y = fragCoord.y;
    float width  = iResolution.x;
    float height = iResolution.y;
    
    
     vec3 pixelPos = vec3(((camera.right - camera.left) * (x + 0.5)) / width + camera.left,
						((camera.top - camera.down) * (y + 0.5)) / height + camera.down,
						camera.pos.z + camera.near);
    
    
    vec3 direction = pixelPos - camera.pos;
	direction = normalize(direction);

    
    
    vec4 Color = TraceScene(direction);
    
    fragColor = Color; //texture2D(iChannel0, vec2(uv.x)) * vec4(uv,0.5+0.5*sin(iGlobalTime), 1.0 );
    
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}