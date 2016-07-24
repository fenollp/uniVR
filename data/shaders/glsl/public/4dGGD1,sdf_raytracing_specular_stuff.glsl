// Shader downloaded from https://www.shadertoy.com/view/4dGGD1
// written by shadertoy user CaptCM74
//
// Name: SDF raytracing specular stuff
// Description: Now with more nothign!
//     BTW First raytracing or raymarching stuff!
//    
//    All(most) every code by cabbibo, Thanks!
//    https://www.shadertoy.com/view/Xl2XWt
#define softness 5.0
/*
  
WAIT!, This amazing raytracing code was written by cabbibo!
Check his tut!
https://www.shadertoy.com/view/Xl2XWt
    
    */
mat3 EYE( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

vec2 Ball(vec3 raypos)
{
    
    vec3 pos = vec3(0.,0.,0.);
    
    float size = 1.;
        
        float dist = length(raypos - pos);
        
        float surfacedist = dist - size;
        
        float id = 1.0;
        
        vec2 ball = vec2( surfacedist , id );
        
        return ball;
    
}

vec2 nearestmdl(vec2 mdl1 , vec2 mdl2)
{
    
 
    vec2 nearest;
        
    if (mdl1.x <= mdl2.x) // BALL vec2(x is dis , y is id)
    {
        nearest = mdl1;
    }
    else if (mdl1.x > mdl2.x) 
    {
        nearest = mdl2;
    }
    
    return nearest;
    
}

vec2 MapWorld(vec3 raypos)
{
    
    
    vec2 ret;
    
    vec2 ball = Ball(raypos);
        
     return ball;
    
    
    
}

const float threshold = 0.001;
    const float maxdist = 10.;
const int maxsteps = 100;

vec2 checkcollision(in vec3 campos ,in vec3 raydir)
{
    
    float dsurface = threshold * 2.0;
    
    float totaldist = 0.;
    
    float finaldisttravel = -1.;
    
    float hitid = -1.;
    
    for (int i = 0; i < maxsteps ; i++)
    {
     
        if (dsurface < threshold) break;
        
        if (totaldist > maxdist) break;
        
        vec3 raypos = campos + raydir * totaldist;
            
            vec2 mdl = MapWorld(raypos);
            
            float dist_mdl = mdl.x;
            float id_mdl = mdl.y;
            
            dsurface = dist_mdl;
            
            hitid = id_mdl;
        
        totaldist += dist_mdl;
        
        
    } 
    
    if (totaldist < maxdist) {
        finaldisttravel = totaldist;
    }
    
     if (totaldist >= maxdist) {
        finaldisttravel = maxdist;
         hitid = -1.;
    }
    
    return vec2(finaldisttravel,hitid);
    
}

vec3 getnormal(in vec3 hitpos)
{
    
    vec3 xTiny = vec3(0.001, 0. , 0.);
     vec3 yTiny = vec3(0., 0.001 , 0.);
    vec3 zTiny = vec3(0., 0. , 0.001);
        
        float upTinyX = MapWorld(hitpos + xTiny).x;
    float downTinyX = MapWorld(hitpos - xTiny).x;
    
    float changeX = upTinyX - downTinyX;
    
    float upTinyY = MapWorld(hitpos + yTiny).x;
    float downTinyY = MapWorld(hitpos - yTiny).x;
    
    float changeY = upTinyY - downTinyY;
    
    float upTinyZ = MapWorld(hitpos + zTiny).x;
    float downTinyZ = MapWorld(hitpos - zTiny).x;
    
    float changeZ = upTinyZ - downTinyZ;
    
    vec3 normal = vec3(
                     changeX,
                     changeY,
                     changeZ
                       );
    
        return normalize(normal);
}

vec3 BGcol(){
    vec3 up = vec3(0.1,0.05,0.3);
        vec3 down = vec3(1.);
 return mix(up,down,max(sin(iGlobalTime),0.05));   
}

vec3 BallColor(vec3 hitpos , vec3 norm, vec3 campos)
{
    
    vec3 lightPos = vec3 (sin(iGlobalTime*3.)*10.,10.,cos(iGlobalTime*3.)*10.);
   
        
        vec3 lightdir = lightPos - hitpos;
    vec3 view = campos - hitpos;
       //R = 2*(V dot N)*N - V
    
    
        lightdir = normalize(lightdir);
    
    vec3 camdir = campos - hitpos;
    
    camdir = normalize(camdir);
    
    float faceval = dot(lightdir , norm);
    
    vec3 refdir = 2. * faceval * norm - lightdir;
    
    
        
    
    float spec = faceval*pow(dot(view , refdir),0.8);
    
    if (spec < 2.4)
    {
     spec = 0.   ;
    }
    else if (spec < 2.6)
    {
     spec = 0.5   ;
    }
   
    
    spec = max(spec,0.);
    
    float hlval = dot(camdir,norm);
    
        hlval = max(0.0,hlval);
    
    float sval = faceval;
        faceval = max(0.0,faceval);
    
    
    
    if (hlval > 0.98 && faceval > 0.5)
    {
     hlval = 10.;   
    }
    else
    {
     hlval = 0.;    
    }
    
    if (faceval > 0.4)
   {
   faceval = 0.8;    
   }
   else if (faceval > 0.1)
   {
   faceval = 0.5;    
   }
   else
   {
     faceval = 0.3;    
   }
    
    
   
    
    vec3 ballcol = vec3(0.8,0.5,0.3);
    
    vec3 col = ballcol * faceval;
    
    col += spec;
    
   // col += hlval;
    
    
   if (sval < -0.6)
    {
    col -= vec3( .1 , .03, .2);
   }
    
    return col;
}

vec3 ColorWorld(vec2 hitinfo, vec3 campos, vec3 raydir){
    //Col(x Red,y Grn,z Blu)
    vec3 color;
    
    if (hitinfo.y < 0.0)
    {
     color = BGcol();   
    }
    else
    {
        vec3 hitpos = campos + hitinfo.x * raydir;
            
            vec3 normal = getnormal(hitpos);
        
        
        if (hitinfo.y == 1.0)
        {
         color = BallColor(hitpos,normal,campos);   
            
            
        }
        
        
        
    }
    
    return color;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 p = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;
	vec2 uv = p;
    
    vec3 campos = vec3( 0., 0., 5.);
    
    vec3 camlookat = vec3(0.0,0.0,0.0);
        
        mat3 camrot = EYE(campos,camlookat,sin(iGlobalTime));
        
        vec3 raydir = normalize(camrot * vec3(p.xy , 2.));
    
    vec2 hitinfo = checkcollision(campos,raydir);
    
    vec3 col = ColorWorld(hitinfo,campos,raydir);
    
	fragColor = vec4(col,1.0);
}
