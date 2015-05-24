// Shader downloaded from https://www.shadertoy.com/view/lssGRX
// written by shadertoy user TekF
//
// Name: TekF Clouds
// Description: Based on Inigo Quilez's Hell. https://www.shadertoy.com/view/MdfGRX
// Created by Ben Weston - 2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 glFragCoord;

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	// there's an artefact because the y channel almost, but not exactly, matches the r channel shifted (37,17)
	// this artefact doesn't seem to show up in chrome, so I suspect firefox uses different texture compression.
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

vec4 map( vec3 p )
{
	float den = -1.0 - (abs(p.y-0.5)+0.5)/2.0;

    // clouds
	float f;
	vec3 q = p*.5                          - vec3(0.0,0.0,1.5)*iGlobalTime + vec3(sin(0.7*iGlobalTime),0,0);
    f  = 0.50000*noise( q ); q = q*2.02 - vec3(0.0,0.0,0.0)*iGlobalTime;
    f += 0.25000*noise( q ); q = q*2.03 - vec3(0.0,0.0,0.0)*iGlobalTime;
    f += 0.12500*noise( q ); q = q*2.01 - vec3(0.0,0.0,0.0)*iGlobalTime;
    f += 0.06250*noise( q ); q = q*2.02 - vec3(0.0,0.0,0.0)*iGlobalTime;
    f += 0.03125*noise( q );

	den = clamp( den + 4.0*f, 0.0, 1.0 );
	
	vec3 col = mix( vec3(1.0, 1.0, 1.0), vec3(0.6,0.5,0.4), den*.5 );// + 0.05*sin(p);
	
	return vec4( col, den*.7 );
}

const vec3 sunDir = vec3(-1,.2,-1);

float testshadow( vec3 p, float dither )
{
	float shadow = 1.0;
	float s = 0.0; // this causes a problem in chrome: .05*dither;
	for ( int j=0; j < 5; j++ )
	{
		vec3 shadpos = p + s*sunDir;
		shadow = shadow - map(shadpos).a*shadow;
		
		s += .05;
	}
	return shadow;
}

vec3 raymarch( in vec3 ro, in vec3 rd )
{
	vec4 sum = vec4( 0 );
	
	float t = 0.0;

    // dithering	
	float dither = texture2D( iChannel0, glFragCoord.xy/iChannelResolution[0].x ).x;
	t += 0.1*dither;
	
	for( int i=0; i<65; i++ )
	{
		if( sum.a > 0.99 ) continue;
		
		vec3 pos = ro + (t+.2*t*t)*rd;
		vec4 col = map( pos );

		float shadow = testshadow(pos, dither);
		col.xyz *= mix( vec3(0.4,0.47,0.6), vec3(1.0,1.0,1.0), shadow );
		
		col.rgb *= col.a;

		sum = sum + col*(1.0 - sum.a);	

		t += 0.1;
	}

	vec4 bg = mix( vec4(.3,.4,.5,0), vec4(.5,.7,1,0), smoothstep(-.4,.0,rd.y) ); // sky/ocean

	/*// floor
	if ( rd.y < -.2 )
	{
		vec3 pos = ro + rd*(ro.y+1.0)/(-rd.y);
		
		float shadow = testshadow(pos+sunDir/sunDir.y, dither);
		bg.xyz = mix( vec3(0), vec3(.5), shadow*.8+.2 );
	}*/

	sum += bg*(1.0 - sum.a);
	
	return clamp( sum.xyz, 0.0, 1.0 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    glFragCoord = fragCoord;
    
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x/ iResolution.y;
	
    vec2 mo = iMouse.xy / iResolution.xy;
    if( iMouse.w<=0.00001 ) mo=vec2(0.5);
	
    // camera
    vec3 ro = 6.0*normalize(vec3(cos(3.0*mo.x+.0), 1.0 - 1.0*(mo.y+.0), sin(3.0*mo.x+.0)));
	vec3 ta = vec3(0.0, 1.0, 0.0);
	float cr = 0.15*cos(0.7*iGlobalTime);
	
    // shake		
	ro += 0.02*(-1.0+2.0*texture2D( iChannel0, iGlobalTime*vec2(0.010,0.014) ).xyz);
	ta += 0.02*(-1.0+2.0*texture2D( iChannel0, iGlobalTime*vec2(0.013,0.008) ).xyz);
	
	// build ray
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize(cross( vec3(sin(cr),cos(cr),0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );
	
    // raymarch	
	vec3 col = raymarch( ro, rd );
	
	// contrast and vignetting	
	col = col*0.5 + 0.5*col*col*(3.0-2.0*col);
	col *= 0.25 + 0.75*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );
	
    fragColor = vec4( col, 1.0 );
}
