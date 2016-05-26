// Shader downloaded from https://www.shadertoy.com/view/ldSSRm
// written by shadertoy user Dave_Hoskins
//
// Name: Grass close-up
// Description: Another attempt at rendering grass.
// Grass close-up
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Created by David Hoskins.

#define PRECISION 0.05
#define MOD2 vec2(.16632,.17369)
#define MOD3 vec3(.16532,.17369,.15787)
vec3 sunDir = normalize(vec3(.2, 0.6, -1.3));

//--------------------------------------------------------------------------------------------------
vec3 TexCube(in vec3 p, in vec3 n )
{
    p *= vec3(.5, .1, .5);
	vec3 x = texture2D( iChannel0, p.yz, -100.0 ).xyz;
	vec3 y = texture2D( iChannel1, p.zx, -100.0 ).xyz;
	vec3 z = texture2D( iChannel2, p.xy, -100.0 ).xyz;
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

//--------------------------------------------------------------------------------------------------
vec2 Hash2(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}


//--------------------------------------------------------------------------------------------------
vec2 Noise( in vec2 x )
{
    return mix(Hash2(floor(x)), Hash2(floor(x+1.0)), fract(x));
}

//--------------------------------------------------------------------------------------------------
vec4 HashMove2(vec2 p)
{
    return vec4(Noise(p), Noise(p + iGlobalTime*.08));
}

//--------------------------------------------------------------------------------------------------
vec4 Voronoi( vec3 p, out float which)
{
    
    vec2 f = fract(p.xz);
    p.xz = floor(p.xz);
	float d = 1.0e10;
    vec3 id = vec3(0.0);
    
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
            vec2 g = vec2(xo, yo);
            vec4 n = HashMove2(p.xz + g);
			vec2 tp = g + .5 + sin(p.y + 6.2831 * n.zw) - f;
            float d2 = dot(tp, tp);
			if (d2 < d)
            {
                // 'which' is the colour code for each stem...
                d = d2;
                which = n.x*7.0+n.y*7.0;
                id = vec3(tp.x, p.y, tp.y);
            }
		}
	}
    return vec4(id, 1.35-pow(d, .17));
}


//--------------------------------------------------------------------------------------------------
float MapGrass( in vec3 pos)
{
    float which = 0.0;
    vec4 ret = Voronoi(pos, which);
    ret.w /= clamp(pos.y*.2, 0.0, 1.2);
	return  .9-fract(which*382.321)*.15 + pos.y * .2 * smoothstep(6.5, 10.0, pos.y)-ret.w;
}

//--------------------------------------------------------------------------------------------------
vec4 MapGrassID( in vec3 pos, out float which)
{
    vec4 ret = Voronoi(pos, which);
    ret.w /= clamp(pos.y*.2, 0.0, 1.);
	return vec4(ret.xyz, .9-fract(which*2.321)*.15 + pos.y * .2 * smoothstep(6.5, 10.0, pos.y) - ret.w);//+sin(floor(which)*5431.3)*1.2);
}

//--------------------------------------------------------------------------------------------------
float Hash12(vec2 p)
{
	p  = fract(p * vec2(5.3983, 5.4427));
    p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
	return fract(p.x * p.y * 95.4337);
}


//--------------------------------------------------------------------------------------------------
vec4 Raymarch( in vec3 ro, in vec3 rd, in vec2 uv, out float which)
{
    const float grassTop = 7.5;
	float maxd = 400.0;
	
    vec4 h = vec4(1.0);
    float t = Hash12(uv*1.15231)*.2;
    // Cast the ray down to the top of the grass
    // Because we're not interested in anything else...
    if (ro.y > grassTop && rd.y < 0.0)
    {
        float d = (ro.y-grassTop)/ -rd.y;
        t += d;
    }
    vec3 po = vec3(20.0);
    bool hit = false;
    for (int i = 0; i < 65; i++)
    {
        po = ro + rd * t;    
        h = MapGrassID(po, which);	 
        if(h.w < PRECISION || t > maxd) break;
        t += h.w + clamp(t * .001, 0.005, 50.0);
    }

    if (t > maxd || po.y > grassTop)t = -1.0;
    
    return vec4(h.xyz, t);
}

//--------------------------------------------------------------------------------------------------
vec3 Normal( in vec3 pos, in float which)
{
    which *= 20.0;
    vec2 eps = vec2(PRECISION, 0.0);
	vec3 norm = normalize( vec3(
           MapGrass(pos+eps.xyy) - MapGrass(pos-eps.xyy),
           MapGrass(pos+eps.yxy) - MapGrass(pos-eps.yxy),
           MapGrass(pos+eps.yyx) - MapGrass(pos-eps.yyx) ) );
    
    // This squashes the Normal on a random x/z plane.
	// It fakes a flattened grass stem...
	mat2 angle = mat2(cos(which), sin(which), -sin(which), cos(which));
	norm.xz *= angle * vec2(1.0, .01);
	return normalize(norm);
}

//--------------------------------------------------------------------------
float FractalNoise(in vec2 xy)
{
	float w = 1.5;
	float f = 0.0;
    xy *= .01;

	for (int i = 0; i < 4; i++)
	{
		f += texture2D(iChannel2, xy / w, -99.0).x * w;
		w *= 0.5;
	}
	return f;
}

//--------------------------------------------------------------------------
vec3 GetSky(in vec3 rd)
{
	vec3 col = vec3(.65, .85, 1.0);
	col 		= mix(col, vec3(.5), pow(abs(rd.y), .5));
    return col;
}
//--------------------------------------------------------------------------
vec3 GetClouds(in vec3 sky, in vec3 cameraPos, in vec3 rd)
{
	//if (rd.y < 0.0) return sky;
	// Uses the ray's y component for horizon fade of fixed colour clouds...
	float v = (370.0-cameraPos.y)/rd.y;
	rd.xz = (rd.xz * v + cameraPos.xz+vec2(0.0,0.0)) * 0.004;
	float f = (FractalNoise(rd.xz) -.5);
	vec3 cloud = mix(sky, vec3(1.0), max(f, 0.0));
	return cloud;
}

//--------------------------------------------------------------------------------------------------
vec3 Path( float time )
{
	return vec3(1.0+ 28.6*cos(0.2-0.5*.33*time*.75), 4.7, 5.7 - 27.0*sin(0.5*0.11*time*.75) );
}

//--------------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 q = fragCoord.xy / iResolution.xy;
	vec2 p = (-1.0 + 2.0*q)*vec2(iResolution.x / iResolution.y, 1.0);
	
    // Camera...
	float off = iMouse.x*1.0*iMouse.x/iResolution.x;
	float time = 113.5+iGlobalTime + off;
	vec3 ro = Path( time+0.0 );
    ro.y += 21.0-cos(time*.25+.54)*19.0;
	vec3 ta = Path( time+37.0 );
	ta.y *= 1.0+sin(3.0+0.12*time) * .5;
	float roll = 0.3*sin(0.07*time);
	
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(roll), cos(roll), 0.0);
	vec3 cu = normalize(cross(cw,cp));
	vec3 cv = cross(cu,cw);
	
	float r2 = p.x*p.x*0.32 + p.y*p.y;
    p *= (7.0-sqrt(37.5-11.5*r2))/(r2+1.0);

	vec3 rd = normalize( p.x*cu + p.y*cv + 2.1*cw );
	vec3 col;

    vec3 background = GetSky(rd);
    col 		= mix(vec3(.65, .85, 1.0), GetClouds(vec3(.5), ro, rd),	pow(abs(rd.y), .5));

	float sun = clamp( dot(rd, sunDir), 0.0, 1.0 );
	float which;
	vec4 ret = Raymarch(ro, rd, q, which);
    
    if(ret.w > 0.0)
	{
		vec3 pos = ro + ret.w * rd;
		vec3 nor = Normal(pos, which);
		vec3 ref = reflect(rd, nor);
		
		float sun = clamp( dot( nor, sunDir ), 0.0, 1.0 );
        float bac = clamp( dot( nor, -sunDir ), 0.0, 1.0 );
	    float sha = clamp((pos.y*.85)-4.0, 0.0, 1.0);
        
		vec3 lin = sun*vec3(.6) * sha;
		lin += vec3(bac*1.1, bac*.1, bac*3.7);
        lin += vec3(clamp(pos.y - 5.0, 0.2, 1.0)) * .4;

		col = TexCube(ret.xyz, nor);
        vec3 grassCol =  vec3(.1+sin(which*2.2392)*.1, .7+abs(sin(which*2.2392)*.3), .0);
        grassCol= mix(grassCol, vec3(.3, .3, .0), min(FractalNoise(pos.xz)*.7, 1.0)); 
        
        
		col = lin * col * grassCol * .9;
        col += vec3(.7, 1.0, .5)*pow(clamp( dot( ref, sunDir ), 0.0, 1.0 ), .25) * .15 * sha;
		
		col = mix(background, col, exp(-0.00002*max(ret.w*ret.w-1240.0, 0.0)) );
	}

    col += vec3(.4, .4, .2)*pow( sun, 15.0 )*2.0*clamp( (rd.y+0.4) / .2,0.0,1.0);

	col = clamp(sqrt(col), 0.0, 1.0);
    col *= 0.5 + 0.5*pow( 60.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.3 );

	fragColor = vec4( col, 1.0 );
}