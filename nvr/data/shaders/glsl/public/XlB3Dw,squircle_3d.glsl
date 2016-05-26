// Shader downloaded from https://www.shadertoy.com/view/XlB3Dw
// written by shadertoy user dys129
//
// Name: Squircle 3D
// Description: Take it to another dimension squircle in 3D - because we can! Credits go to all shadertoy community!
//
// #TeamSquircle
//


float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	vec2 uv = p.xy + f.xy*f.xy*(3.0-2.0*f.xy);
	return texture2D( iChannel0, (uv+118.4)/256.0, -100.0 ).x;
}


vec3 rotateX(vec3 v, float a)
{
    return vec3(v.x ,
                v.y * cos(a) + v.z * sin(a),
                -v.y * sin(a) + v.z * cos(a));
}

vec3 rotateY(vec3 v, float a)
{
    return vec3(v.x * cos(a) + v.z * sin(a),
                v.y,
                -v.x * sin(a) + v.z * cos(a));
}

vec3 rotateZ(vec3 v, float a)
{
 	return vec3(v.x * cos(a) + v.y * sin(a),
                v.x * -sin(a) + v.y * cos(a),
                v.z);
}

float plane( vec3 p )
{
	return p.y;
}

float box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sphere(vec3 ro, float r)
{
 return length(ro) - r;   
}

float cylinder( vec3 p, vec2 h )
{
  return max( length(p.xz)-h.x, abs(p.y)-h.y );
}


vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

float opU( float d1, float d2 )
{
	return (d1<d2) ? d1 : d2;
}


bool IntersectBox(vec3 ro, vec3 rd, vec3 bmin, vec3 bmax, out float t0, out float t1)
{
    vec3 invR = 1.0 / rd;
    vec3 tbot = invR * (bmin-ro);
    vec3 ttop = invR * (bmax-ro);
    vec3 tmin = min(ttop, tbot);
    vec3 tmax = max(ttop, tbot);
    vec2 t = max(tmin.xx, tmin.yz);
    t0 = max(t.x, t.y);
    t = min(tmax.xx, tmax.yz);
    t1 = min(t.x, t.y);
    return t0 <= t1;
}

float sphercile(vec3 ro, float r, float power)
{
	return pow( abs(ro.x), power) + pow( abs(ro.y), power) + pow( abs(ro.z), power) - r;
}

float selipse(vec3 ro, float e, float n)
{
 	float r = 2.0 / e;
    float t = 2.0 / n;
    
    float inside =  pow(pow(abs(ro.x), r) + pow(abs(ro.y), r), t/r) + pow(abs(ro.z),t);
    return inside - 1.0;
}

vec3 selipse_nrm(vec3 ro, float e, float n)
{
    float r = 2.0 / e;
    float t = 2.0 / n;
    
    float xr = pow(abs(ro.x), r);
    float yr = pow(abs(ro.y), r);
    float zt = pow(abs(ro.z), t);
 	return vec3(t*xr * pow((xr + yr), t/r-1.0)/ro.x,
                t*yr * pow((xr + yr), t/r-1.0)/ro.y,
                t*zt/abs(ro.z));
}

vec4 map( vec3 p )
{

    vec3 cc = vec3(2.3);
	vec3 q = mod(p, cc) - 0.5 * cc;
    p = q;
    float d = box(p,vec3(1.0));
    vec4 res = vec4( d, 1.0, 0.0, 0.0 );

 	float s = 1.0;
    for( int m=0; m<4; m++ )
    {
	   
        vec3 a = mod( p*s, 2.0 )-1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0*abs(a));
        float da = max(r.x,r.y);
        float db = max(r.y,r.z);
        float dc = max(r.z,r.x);
        float c = (min(da,min(db,dc))-1.0)/s;

        if( c>d )
        {
          d = c;
          res = vec4( d, min(res.y,0.2*da*db*dc), (1.0+float(m))/4.0, 0.0 );
        }
    }

    return res;
}


vec3 fog_clr = vec3(0.3,0.1,0.2);
vec3 applyFog(vec3 clr, vec3 rd)
{
    
    float fog = 1.0 - exp(-length(rd) * 0.05);
    clr.rgb = mix(clr.rgb, fog_clr, fog);
    return clr;
}

vec2 scene(vec3 ro)
{

    float time = iGlobalTime;
    float tt = 1.0 + abs(sin(time * 1.5))*3.0;
 	vec3 ppp = ro + vec3(0,-1,0);
    ppp = rotateY(ppp, iGlobalTime * 2.0);
    vec2 sp0 = vec2(sphercile(ppp, 1.0, 1.0), 0.0);
    vec2 pl0 = vec2(plane(ro), 1.0);
    vec2 sa0 = vec2(selipse(ppp, 2.0, 2.0), 0.0);
    float rad = 3.5;
    vec3 ccc = vec3(0.0, 0.0, 2.0*rad + 0.5);
    vec3 qqq = mod(ro - vec3(0.0,0.0,rad), ccc) - 0.5 * ccc;
    float sph = sphere(qqq, rad);
    float cb = map(ro).x;
    float r = max(cb, -sph);
    return vec2(r, 1.0);
}



vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    scene(pos+eps.xyy).x - scene(pos-eps.xyy).x,
	    scene(pos+eps.yxy).x - scene(pos-eps.yxy).x,
	    scene(pos+eps.yyx).x - scene(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

float shadow( vec3 ro, vec3 rd)
{
	float t = 0.02;
    float res = 1.0;
    for(int i=0;i<16;i++)
    {
    	float h = scene( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001) break;    
    }
    return clamp(res, 0.0, 1.0);
}

float freqs[4];

vec3 lighting(vec3 pos, vec3 rd, vec3 nrm, float mid)
{
    vec3 lpos = vec3(0.6, 0.7, 0.80);
    vec3  lig = normalize( lpos );
    float ndl = clamp( dot( nrm, lig ), 0.0, 1.0 );
	
	float bac = clamp( dot( nrm, normalize(lig*vec3(-1.0,0.0,-1.0)) ), 0.0, 1.0 );
    
    
    vec3 clr = vec3(0.0);
    clr += ndl*vec3(0.70,0.12,0.30);
    clr += bac*vec3(0.40,0.18,0.20);
    clr += 0.5 * clamp( dot(nrm,normalize(-pos)), 0.0, 1.0) * vec3(0.3,0.4,0.3);
    float off = texture2D( iChannel1, vec2( atan(pos.z, pos.x) * 0.15 * 0.5 + 0.5, 0.25 ) ).x * 1.0 - 0.5;
    float ns = noise(pos.xz + iGlobalTime * 1.2);
    float p0 = clamp(1.0 - abs(pos.y*20.0 + /*mod(iGlobalTime * 50.0, 150.0) - 75.0*/ + ns * 35.0 + (freqs[3] + freqs[2] * 40.0)), 0.0,1.0);
    float p1 = clamp(1.0 - abs(pos.y*20.0 + /*mod(iGlobalTime * 50.0, 150.0) - 75.0*/ + off * 55.0), 0.0,1.0);
    float bit1 = mix(0.4, 5.0, clamp( (freqs[0] - 0.95) * 20.0, 0.0, 1.0));
    float bit2 = freqs[3] + freqs[2];//mix(0.2, 10.0, clamp( (freqs[2] - 0.5) * 1.0 / 0.5, 0.0, 1.0));
   // clr.rgb += vec3(p0) * 2.0 * mix(vec3(0.6,0.6,0.2), vec3(0.6,0.2,0.9), bit1);
    clr.rgb += vec3(p1) * 2.0 * mix(vec3(1.0,0.0,0.0), vec3(0.2, 0.9,0.1), bit2 );
    clr.rgb *= calcAO(pos + 0.01 * nrm, nrm);
    return clr;
}

#define NUM_STEPS 64

vec4 rayMarchSpheroid(vec3 ro, vec3 rd, out float tk)
{
   float t0, t1;
	bool box_hit = IntersectBox(ro, rd, vec3(-1,-1,-1), vec3(1,1,1), t0, t1); 
    
    if(!box_hit)
        return vec4(0.0);
    
    
	float E = sin(iGlobalTime * 0.8) * 1.5 + 1.6;
    float N = 1.6 + sin(iGlobalTime * 0.7) * 1.5;
    float t = t0;
    vec4 clr = vec4(0.0);
    float dt = (t1 - t0) / float(NUM_STEPS);
    
    for(int i =0; i<NUM_STEPS; i++)
    {
        float hit = selipse(ro+t*rd, E, N);
        float eps = 0.001;
        
        if(hit < eps)
        {
            float resT = t - 0.5 * dt;
        	vec3 pos = ro + resT*rd;        	
            vec3 nrm = normalize(selipse_nrm(pos, E, N));
            vec3 rfl = reflect( rd, nrm );
            vec3  lig = normalize( vec3(0.6, 0.7, 0.5) );
            
            vec3 ppp = pos;
            clr.rgb = vec3(0.0);
            float rt = 1.0;
            vec3 rfl_clr = vec3(0.0);
            for(int j = 0; j < 10; j++)
            {
                
            	vec2 rhit = scene(pos + rt * rfl); 
                if(rhit.x < 0.001)
                {
                 vec3 rpos = pos + rt * rfl;
                 vec3 rnrm = calcNormal(rpos);   
                 rfl_clr = lighting(rpos, rfl, rnrm, 0.0);   
                   break;
                }
                
                rt += max(rhit.x, 0.001);
            }
            clr.rgb += rfl_clr * 0.6;
            clr.rgb += max(dot(lig, nrm), 0.0) * vec3(0.4,0.5,0.6)* 0.3;
            clr.rgb = applyFog(clr.rgb, t*rd);
            clr.w = 1.0;
            break;
        }                
        t += dt;
    }
    tk = t;
    return clr;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    freqs[0] = texture2D( iChannel1, vec2( 0.01, 0.25 ) ).x;
	freqs[1] = texture2D( iChannel1, vec2( 0.07, 0.25 ) ).x;
	freqs[2] = texture2D( iChannel1, vec2( 0.50, 0.25 ) ).x;
	freqs[3] = texture2D( iChannel1, vec2( 0.80, 0.25 ) ).x;
    
    vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    vec2 mo = -1.0 + 2.0 * iMouse.xy/iResolution.xy;
    
    float k = 3.0;
 	vec3 ro = vec3(sin(iGlobalTime * 0.4) * 4.3, 0.1 + 0.0 * sin(iGlobalTime*0.4), cos(iGlobalTime * 0.4) * 3.1);
	vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );
    
    float t = 0.0;
    vec4 clr = vec4(0.0, 0.0, 0.0, 1.0);
    clr.rgb = fog_clr;
    for(int i =0; i<64; i++)
    {
        vec2 hit = scene(ro+t*rd);
        float eps = 0.001;
        float dt = 0.01;
        if(hit.x < eps)
        {
        	vec3 pos = ro + t*rd;
        	vec3 nrm = calcNormal( pos );
        	vec3 rfl = reflect( rd, nrm );
            clr.rgb = lighting(pos, rd, nrm, 0.0); 
            
            clr.rgb = applyFog(clr.rgb, t*rd);
    
            break;
        }
        
        t += max(hit.x, 0.001);
    }
    float kt = 1000.0;
    vec4 sph = rayMarchSpheroid(ro, rd, kt);
    clr.rgb = mix(clr.rgb, sph.rgb, sph.a * float(k < t));

	fragColor = clr;
}