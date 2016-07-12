// Shader downloaded from https://www.shadertoy.com/view/XlBXzd
// written by shadertoy user fantomas
//
// Name: black hole 2
// Description: test
float distfunc (vec3 p)
{
    return min( length(p-vec3(-4.,1,-3.))-2.0, 50.-length(p));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.x;
    float vr=0.5;
    float cr=15.;
    
    vec3 camo = vec3(sin(iGlobalTime*vr)*cr,1.,cos(iGlobalTime*vr)*cr);
    vec3 camd = vec3(0,0,0);
    vec3 up = vec3(0.,1.,0.);
    
    vec3 dir = normalize(camd-camo);
    
    dir = normalize(up*(uv.y-iResolution.y/iResolution.x/2.)+cross(dir,up)*(uv.x-0.5)+(dir));
    
    
    vec3 pos = camo;
    float dmas;
    float dmar;
    float dbh;
    
    for (int i=0; i<48; i++)
    {
        dbh = length(pos);
        dmar = min(distfunc(pos),dbh/2.);
        dir-=pos/dbh/dbh/dbh/8.;
        dir=normalize(dir);
        pos += dir*dmar;

    }
 
    float do1 = length(pos-vec3(-5.,1,-5.))-2.0;
    float do2 =  50.-length(pos);
    
    vec4 col=vec4(0.,0.,0.,0.);
    if (do1 < do2)
    {
        float dam= (float(mod(pos.x,1.)>.5)-0.5)*(float(mod(pos.z,1.)>.5)-0.5)*(float(mod(pos.y,1.)>.5)-0.5);
        dam = float(dam>0.);
   		col=vec4(dam,1.-dam,0.,1.);
    }
    else
    {
        float dam= (float(mod(pos.x,16.)>8.)-0.5)*(float(mod(pos.z,16.)>8.)-0.5)*(float(mod(pos.y,16.)>8.)-0.5);
        dam = float(dam>0.);
        col=vec4(dam,dam,1.-dam,1.);
    	
    }

    float hit = .1/(distfunc(pos)+.1);
    
    fragColor = (col)*hit;
}