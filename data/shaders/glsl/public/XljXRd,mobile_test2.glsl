// Shader downloaded from https://www.shadertoy.com/view/XljXRd
// written by shadertoy user umarniz
//
// Name: Mobile Test2
// Description: Mobile Test Shader
//Plasma Globe by nimitz (twitter: @stormoid)

#define time iGlobalTime

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

//iq's ubiquitous 3d noise
float noise(in vec3 p)
{
	vec3 ip = floor(p);
    vec3 f = fract(p);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (ip.xy+vec2(37.0,17.0)*ip.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, - 100.).yx;
	return mix(rg.x, rg.y, f.z);
}

mat3 m3 = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );


//See: https://www.shadertoy.com/view/XdfXRj
float flow(in vec3 p, in float t)
{
	float z=2.;
	float rz = 0.;
	vec3 bp = p;
	for (float i= 1.;i < 2.;i++ )
	{
		p += time*.1;
		rz+= (sin(noise(p+t*0.8)*6.)*0.5+0.5) /z;
		p = mix(bp,p,0.6);
		z *= 2.;
		p *= 2.01;
        p*= m3;
	}
	return rz;	
}

//returns both collision dists of unit sphere
vec2 iSphere2(in vec3 ro, in vec3 rd)
{
    vec3 oc = ro;
    float b = dot(oc, rd);
    float c = dot(oc,oc) - 1.;
    float h = b*b - c;
    if(h <0.0) return vec2(-1.);
    else return vec2((-b - sqrt(h)), (-b + sqrt(h)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    /*vec2 p = fragCoord.xy/iResolution.xy;
    vec4 texCol = texture2D( iChannel0, p);
    
	fragColor = texCol;//vec4(texCol, 1.0);*/
    
    
	vec2 p = fragCoord.xy/iResolution.xy-0.5;
	p.x*=iResolution.x/iResolution.y;
//	vec2 um = iMouse.xy / iResolution.xy-.5;
    
	//camera
	vec3 ro = vec3(0.,0.,5.);
    vec3 rd = normalize(vec3(p*.7,-1.5));
    mat2 mx = mm2(time*.4);
    mat2 my = mm2(time*0.3); 
    ro.xz *= mx;rd.xz *= mx;
    ro.xy *= my;rd.xy *= my;
    
    vec3 bro = ro;
    vec3 brd = rd;
	
    vec3 col = vec3(0.0125,0.,0.025);
    
    ro = bro;
    rd = brd;
    vec2 sph = iSphere2(ro,rd);
    
    if (sph.x > 0.)
    {
        vec3 pos = ro+rd*sph.x;
        vec3 pos2 = ro+rd*sph.y;
        vec3 rf = reflect( rd, pos );
        vec3 rf2 = reflect( rd, pos2 );
        float nz = (-log(abs(flow(rf*1.6,time))));
        float nz2 = (-log(abs(flow(rf2*1.6,-time))));
  //      col += vec3(0.,0.,noise(pos));
//        col += vec3(noise(pos2),0.,0.);
        
        col += vec3(0.,0.,noise(pos));
        //col += (0.1*nz*nz*nz* vec3(0.12,0.12,.5) + 0.05*nz2*nz2*vec3(0.55,0.2,.55))*0.8;
    }	
    
    col = texture2D(iChannel0, p).xyz;
	fragColor = vec4(col*1.3, 1.0);
}