// Shader downloaded from https://www.shadertoy.com/view/MsKXRh
// written by shadertoy user Aspect
//
// Name: Mountain March
// Description: First attempt at raymarched mountains. Tried to find an elementary way of producing some not-terrible looking terrain.  IQ's articles were really helpful. I might revisit this later since it could definitely use some speed/look upgrades.
  float pi=3.14159265358979323846264338;


const mat2 rotate2D = mat2(1.3623, 1.7531, -1.7131, 1.4623);

float terrain(float x,float z)
{
  
    vec2 pos=vec2(x,z);
   pos= rotate2D*pos;
    
    float sum=0.0;
    float hdetail=17.15;
    float pepper=0.;
    for (float i=5.0;i<15.;i+=5.)
    {
     sum+= (i/3.6905)*texture2D(iChannel1,pos/hdetail).x;   
        hdetail*=2.;
    }
    
   float ldetail=512.;
    for (float i=5.0;i<15.;i+=5.)
    {
     ldetail*=2.;
     sum+= (12.*i)*texture2D(iChannel1,pos/ldetail).y;   
        
    }
    
 return 0.0685*sum;  
}





vec3 sky(in vec3 color,in vec3 lightpos,in vec3 rayDir,in vec3 camo)
{
    	float sundot = clamp(dot(rayDir,lightpos),0.5,1.0);
		vec3 col = vec3(0.3,.7,0.8)*(1.0-0.5*rayDir.y)*1.0;
		col += 0.65*vec3(0.2,0.7,0.9)*pow( sundot,32.0 );
		col += 0.52*vec3(0.75,0.7,0.9)*pow( sundot,12.0 );
        col = mix( col, vec3(0.6,0.6,0.85), pow( 1.0-max(rayDir.y,0.2), 0.85 ) );
    
    return col;
}


vec3 rayMarch(vec3 pos,vec3 rayDir,float EPSILON,out float dist,out float sdist)
{
    float mini=999999.0;
     float stepsize= 0.0005;
    const float maxd= 35.0;
    const float maxiter=1200.;
    float wtv=0.0;
    float stepdist=0.;
    for (float i = 0.0; i < maxiter; i+=1.)
    {       
      float height=  terrain(pos.x,pos.z);
      dist=pos.y-height;
      if((dist<EPSILON)||(stepdist>maxd))
      {
          
        wtv=stepdist;  
       	break;
        
        
      }
      else
      {
          stepdist+=stepsize;
        pos+=rayDir*stepsize;  
        stepsize*=1.007;
      }
        
       
    wtv=stepdist;  
    }
    sdist=distance(pos-wtv*rayDir,pos);
    return pos;
}



vec3 calculateNormal(float EPSILON, vec3 pos)
{
	vec3 normal = normalize(vec3(    terrain(pos.x+EPSILON,pos.z) - terrain(pos.x-EPSILON,pos.z),    2.0*EPSILON,
                                 terrain(pos.x,pos.z + EPSILON) - terrain(pos.x,pos.z - EPSILON)));
            
    return normal;
}


void getRay(vec2 screenPos,out vec3 cameraOrigin,out vec3 rayDir,out vec3 lightpos)
{
    cameraOrigin = vec3(0.0, 5.75,2.*mod(iGlobalTime,155.));  
    vec3 cameraTarget = vec3(0.0, 0.0, cameraOrigin.z+30.);
    vec3 upDirection = vec3(0.0, 1.0, 0.0);
    vec3 cameraDir = normalize(cameraTarget - cameraOrigin);
    vec3 cameraRight = normalize(cross(upDirection, cameraOrigin));
	vec3 cameraUp = (cross(cameraDir, cameraRight));
    lightpos.z=cameraOrigin.z+35.0;
    lightpos.y=cameraOrigin.y+20.;
    rayDir = normalize(cameraRight * screenPos.x + cameraUp * screenPos.y + cameraDir);
   

}


vec3 applyFog( in vec3  rgb,       
               in float distance ) 
{
    float b=0.225;
    float fogAmount = 1.0 - exp( -distance*b );
    vec3  fogColor  = vec3(0.55,0.56,0.67*exp( 0.025*distance*b ));
    return mix( rgb, fogColor, fogAmount );
}


vec4 render(vec2 ScreenPos)
{
    vec3 rayDir=vec3(0.0);
    vec3 pos=vec3(0.0);
    vec3 lightpos=vec3(25.0,55.0,0.0);
    getRay(ScreenPos,pos,rayDir,lightpos);
    vec3 camo= pos;
 
    const int MAX_ITER = 100;
    const float MAX_DIST = 30.0; 
    float EPSILON = 0.01;
    float totalDist = 0.0;
    float dist = 0.0;
    float sdist= 0.0;
        vec3 color=vec3(0.0);

    //initial march towards objects
    pos=rayMarch(pos,rayDir,EPSILON,dist,sdist);
                     
   if ((dist) <EPSILON)
	{
     EPSILON=0.007;
     vec3 normal=calculateNormal(EPSILON,pos);
        
    
   
    vec3  lightdir=   normalize(lightpos-pos);  
    vec3 halfvec= normalize(lightdir-rayDir);
    vec3 reflected= normalize(reflect(rayDir,normal));


        float diffuse = max(0.0, dot(lightdir, normal));
         float specular=0.0;
        color = vec3(0.45,0.45,0.45)*mix(diffuse,terrain(pos.x,pos.z),0.05);
        color=applyFog(color,sdist);
        return vec4(color,1.0);
    	
	}
    
    
    return vec4(sky(color,lightpos,rayDir,camo),1.0);

   
    
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