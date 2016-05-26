// Shader downloaded from https://www.shadertoy.com/view/MtfSzX
// written by shadertoy user Aspect
//
// Name: Raymarching First Attempt
// Description: Updates: Fixed reflection colors. Soft shadows. Cleaned up my main.  Improved the speed a bit.
//My first raymarching attempt. Shadow rays + 1 bounce reflection.
// I tried to improvise as much as I could, and "steal" the minimum amount of code
//References were iq's articles and the /r/twotriangles raymarching tutorial on reddit. 

float sphere(vec3 pos, float radius)
{
    
    return length(pos) - radius ;
}

//http://www.iquilezles.org/www/articles/smin/smin.htm
vec2 smin( vec2 a, vec2 b, float k )
{
    float minid=(a.x<b.x)? a.y:b.y;
    float h = clamp( 0.5+0.5*(b.x-a.x)/k, 0.0, 1.0 );
    return vec2(mix( b.x, a.x, h ) - k*h*(1.0-h),minid);
}

//from iq's raymarching primitives
vec2 box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return vec2(min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)),-44.0);
}

vec2 boxTwist( vec3 p,vec3 size )
{
    float c = cos(5.0*p.y);
    float s = sin(5.0*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xz,p.y);
    return box(q,size);
}
vec2 plane(vec3 pos)
{
 return vec2(pos.y+90.0,-99.0);   
}

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
vec2 boxDisplace( vec3 p,vec3 size )
{
    vec2 d1 = box((abs(cos(0.25*iGlobalTime))*.25-0.7)*p,size);
    float d2 =1.0;
    
    return vec2(d1.x+d2,d1.y);
}

vec2 spheremore(vec3 pos,float radius)
{
    float min = 10000.0;
    int mindex=-1;

    
    for(int i=0;i<5;i++)
    {
     vec3 center=vec3(16.5*cos(float(i))*sin(iGlobalTime),0.0,float(i)*11.5*cos(iGlobalTime));
     float distance = length(pos-center)-radius;
     if((distance)<(min)) 
     {
         min=distance;
         mindex=i;
     }

    }
    
    return vec2(min,float(mindex));
}


//http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

vec2 distfunc(vec3 pos)
{  
    vec2 inter=smin(( spheremore(pos/1.0,2.0)),boxDisplace(pos-vec3(0.0-7.0*cos(iGlobalTime),-10.0,4.0*sin(0.3*iGlobalTime)),vec3(5.0,5.0,5.0)),3.0 );
    vec2 ops=opU(plane(pos),inter );
    return ops;

}


vec3 retcol(float identif)
{
 vec3 color=vec3(0.0);
    
    if(identif==0.0)
    {
        color=vec3(0.7,0.7,0.9);
    }
    else if(identif==1.0)
    {
     	color=vec3(0.0,0.0,0.00);   
    }
     else if(identif==2.0)
    {
     	color=vec3(0.1,0.2,0.8);   
    }
     else if(identif==3.0)
    {
     	color=vec3(0.1,0.6,0.9);   
    }
     else if(identif==4.0)
    {
     	color=vec3(0.2,0.9,0.6);   
    }
     else if(identif==-44.0)
    {
     	color=vec3(1.0,1.0,1.0);   
    }
     else if(identif==-99.0)
    {
     	color=vec3(0.8,0.1,0.2);   
    }
    else
    {
        color=vec3(0.0,1.0,1.0);   
    }
    
    return color;
    
}

vec3 rayMarch(vec3 pos,vec3 rayDir,float EPSILON,out vec2 dist)
{
    float mini=999999.0;
    float origid=dist.y;
    for (int i = 0; i < 120; i++)
    {       
        if ((dist.x < EPSILON)&&(dist.y!=origid))   continue;   
        
        dist = distfunc(pos); 
        pos += dist.x * rayDir;
        if(dist.x<mini) mini=dist.x;
        dist.x=mini;
    }
    return pos;
}

vec3 shadowMarch(vec3 pos,vec3 rayDir,float EPSILON,out vec2 dist)
{
    float mini=999999.0;
    float origid=dist.y;
    for (int i = 0; i < 40; i++)
    {       
        if ((dist.x < EPSILON)&&(dist.y!=origid))   continue;   
        
        dist = distfunc(pos); 
        pos += dist.x * rayDir;
        if(dist.x<mini) mini=dist.x;
        dist.x=mini;
    }
    return pos;
}



//https://www.reddit.com/r/twotriangles/comments/1hy5qy/tutorial_1_writing_a_simple_distance_field/
vec3 calculateNormal(float EPSILON, vec3 pos)
{
  	vec2 eps = vec2(0.0, EPSILON);
	vec3 normal = normalize(vec3(
    distfunc(pos + eps.yxx).x - distfunc(pos - eps.yxx).x,
    distfunc(pos + eps.xyx).x - distfunc(pos - eps.xyx).x,
    distfunc(pos + eps.xxy).x - distfunc(pos - eps.xxy).x));
            
    return normal;
}

vec3 tempNormal(vec3 pos,float id,float EPSILON)
{
    vec3 normal=vec3(0.0);
    if(id>=0.0)
    {
         normal=normalize(pos-vec3(16.5*cos(float(id))*sin(iGlobalTime),0.0,float(id)*11.5*cos(iGlobalTime)));

    }
    else if(id==-99.0)
    {
        normal=normalize(vec3(0.0,pos.y+90.01,0.0));
    }
    else
    {
        normal=calculateNormal(EPSILON,pos);
    }
   return normal;
    
}

void getRay(vec2 screenPos,out vec3 cameraOrigin,out vec3 rayDir)
{
    cameraOrigin = vec3(2.0+3.0*cos(iGlobalTime), +16.0+6.0*cos(iGlobalTime), 5.0+1.0*cos(iGlobalTime));  
    vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
    vec3 upDirection = vec3(0.0, 1.0, 0.0);
    vec3 cameraDir = normalize(cameraTarget - cameraOrigin);
    vec3 cameraRight = normalize(cross(upDirection, cameraOrigin));
	vec3 cameraUp = cross(cameraDir, cameraRight);
    rayDir = normalize(cameraRight * screenPos.x + cameraUp * screenPos.y + cameraDir);
   

}


vec4 render(vec2 ScreenPos)
{
    vec3 rayDir=vec3(0.0);
    vec3 pos=vec3(0.0);
    getRay(ScreenPos,pos,rayDir);
    
 
    const int MAX_ITER = 100;
    const float MAX_DIST = 20.0; 
    float EPSILON = 0.01;
    float totalDist = 0.0;
    vec2 dist = vec2(EPSILON,0.0);
    vec3 lightpos=vec3(25.0,55.0,0.0);

    //initial march towards objects
    pos=rayMarch(pos,rayDir,EPSILON,dist);
                     
   if (dist.x <EPSILON)
{
     vec3 normal=tempNormal(pos,dist.y,EPSILON);
    
   
    vec3  lightdir=   normalize(lightpos-pos);  
    vec3 halfvec= normalize(lightdir-rayDir);
    vec3 reflected= normalize(reflect(rayDir,normal));
    vec3 color=vec3(0.0);
    
    EPSILON=0.01;
        
    //shadow ray 
    vec2 shadowdist=vec2(EPSILON,dist.y);
    vec3 shadowpos=shadowMarch(pos+2.0*lightdir,lightdir,EPSILON,shadowdist);
    if((shadowdist.x<EPSILON)&&(shadowdist.y!=dist.y))
    {
        color=vec3(0.0,0.0,0.0);
    }
    else
    {
     
        
    float diffuse = max(0.0, dot(lightdir, normal));
    float specular = pow(dot(normal,halfvec), 64.0);
    color = vec3(retcol(dist.y)*(diffuse + specular));
          
     //soft shadows
    float penumbra=75.0;
    if(shadowdist.x<penumbra*EPSILON) color*=shadowdist.x/(penumbra*EPSILON);  
            
    //reflection rays  
    EPSILON=0.0001;    
        
    vec2 reflectdist=vec2(EPSILON,dist.y);
    vec3 reflecpos=shadowMarch(pos+0.1*reflected,reflected,EPSILON,reflectdist);
      if((reflectdist.x<EPSILON)&&(reflectdist.y!=dist.y))
      {
              
        vec3 lightdir2= normalize(lightpos-reflecpos);
        vec3 halfvec2= normalize(lightdir2-reflected);
        
        //check if reflection point is in shadow
        vec2 shadowrefdist=vec2(EPSILON,reflectdist);
        vec3 shadowrefpos= shadowMarch(reflecpos+0.01*lightdir2,lightdir2,EPSILON,shadowrefdist);                      
                 if((shadowrefdist.x>=EPSILON))
                 {                  
                                          
                vec3 reflecnormal=tempNormal(reflecpos,reflectdist.y,EPSILON);

                float diffuseR = max(0.0, dot(lightdir2, reflecnormal));
                float specularR =pow(dot(reflecnormal,halfvec2), 4.0);      
                vec3 reflecolor= vec3(retcol(reflectdist.y)*(diffuseR+specularR));
                color= color+0.2*reflecolor;
                 }

      }
        
    }    
    
	return vec4(color, 1.0);
}
else
{
    return vec4(vec3(retcol(dist.y)),1.0);
}
  
}

 

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{         
	vec2 uv = fragCoord.xy / iResolution.xy;   
    vec2 xy = -1.0 + 2.0*fragCoord.xy/iResolution.xy;
 
    vec2 screenPos = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy; 
	screenPos.x *= iResolution.x / iResolution.y; 
     vec2 mo = iMouse.xy/iResolution.xy;
  
    fragColor=render(screenPos);

}