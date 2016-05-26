// Shader downloaded from https://www.shadertoy.com/view/Ms3SR2
// written by shadertoy user bergi
//
// Name: Shadertoy on Dome
// Description: Description of the process used to make this video:
//    [url]https://vimeo.com/defgsus/shadertoy[/url]
//    Drag mouse up/down to blend between flat browser and fulldome view. 
/*	Shadertoy on Dome - https://www.shadertoy.com/view/Ms3SR2
  	(cc) 2016, Stefan Berke / berke@cymatrix.org

  	A little making-of of my https://vimeo.com/defgsus/shadertoy video. 
   
  	This uses the "Voxel Edges" shader from iq as example
  	https://www.shadertoy.com/view/4dfGzs

    The typical Shadertoy mainImage() function is extended to 
	
	void mainImage(out vec4 fragColor, in vec2 fragCoord, 
                   in vec3 sphereDir, in float sphereMix)

	where sphereDir is the normalized ray direction of the spherical
	fulldome view and sphereMix is a mix variable between 0 and 1. 

	In order to view a particular 3d-shader on the dome i overwrite the
	ray direction before the ray-marching. To make the transition between
	the flat screen and the fulldome/fisheye view seamless the sphereMix
	variable is used. 
	
	Also all post-processing wich depends on the uv-screen-coordinate
	(like vignetting) is mixed out, because there is no screen coordinate
	in fulldome view.

	See the _uv_to_sphere(in vec2 uv, in float angle) function below in
	the helper section for the screen-to-fulldome conversion. 
	In my video above, i used a skybox and the 5-camera-rig model to 
	render the fulldome master.

	To get the right fulldome ray direction for the 'shader' in the virtual browser,
	i simply use the direction of the ray which hits the browser plane in the 
	first place. If your 3d environment supports fulldome rendering via 5-camera-rigs
	or other means that should be no problem. Otherwise you can use the approach
	from this shader and simply render everything on the screen-quad using _uv_to_sphere().
	
	
	Thank you Shadertoyers around the world for all your effort and inspiration!
*/


// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

vec4 texcube( sampler2D sam, in vec3 p, in vec3 n )
{
    vec3 m = abs( n );
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return x*m.x + y*m.y + z*m.z;
}

float mapTerrain( vec3 p )
{
	p *= 0.1; 
	p.xz *= 0.6;
	
	float time = 0.5 + 0.15*iGlobalTime;
	float ft = fract( time );
	float it = floor( time );
	ft = smoothstep( 0.7, 1.0, ft );
	time = it + ft;
	float spe = 1.4;
	
	float f;
    f  = 0.5000*noise( p*1.00 + vec3(0.0,1.0,0.0)*spe*time );
    f += 0.2500*noise( p*2.02 + vec3(0.0,2.0,0.0)*spe*time );
    f += 0.1250*noise( p*4.01 );
	return 25.0*f-10.0;
}

vec3 gro = vec3(0.0);

float map(in vec3 c) 
{
	vec3 p = c + 0.5;
	
	float f = mapTerrain( p ) + 0.25*p.y;

    f = mix( f, 1.0, step( length(gro-p), 5.0 ) );

	return step( f, 0.5 );
}

vec3 lig = normalize( vec3(-0.4,0.3,0.7) );

float castRay( in vec3 ro, in vec3 rd, out vec3 oVos, out vec3 oDir )
{
	vec3 pos = floor(ro);
	vec3 ri = 1.0/rd;
	vec3 rs = sign(rd);
	vec3 dis = (pos-ro + 0.5 + rs*0.5) * ri;
	
	float res = -1.0;
	vec3 mm = vec3(0.0);
	for( int i=0; i<128; i++ ) 
	{
		if( map(pos)>0.5 ) { res=1.0; break; }
		mm = step(dis.xyz, dis.yxy) * step(dis.xyz, dis.zzx);
		dis += mm * rs * ri;
        pos += mm * rs;
	}

	vec3 nor = -mm*rs;
	vec3 vos = pos;
	
    // intersect the cube	
	vec3 mini = (pos-ro + 0.5 - 0.5*vec3(rs))*ri;
	float t = max ( mini.x, max ( mini.y, mini.z ) );
	
	oDir = mm;
	oVos = vos;

	return t*res;
}

vec3 path( float t, float ya )
{
    vec2 p  = 100.0*sin( 0.02*t*vec2(1.0,1.2) + vec2(0.1,0.9) );
	     p +=  50.0*sin( 0.04*t*vec2(1.3,1.0) + vec2(1.0,4.5) );
	
	return vec3( p.x, 18.0 + ya*4.0*sin(0.05*t), p.y );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, -cw );
}

vec3 render( in vec3 ro, in vec3 rd )
{
    vec3 col = vec3(0.0);
	
    // raymarch	
	vec3 vos, dir;
	float t = castRay( ro, rd, vos, dir );
	if( t>0.0 )
	{
        vec3 nor = -dir*sign(rd);
        vec3 pos = ro + rd*t;
        vec3 uvw = pos - vos;
		
		vec3 v1  = vos + nor + dir.yzx;
	    vec3 v2  = vos + nor - dir.yzx;
	    vec3 v3  = vos + nor + dir.zxy;
	    vec3 v4  = vos + nor - dir.zxy;
		vec3 v5  = vos + nor + dir.yzx + dir.zxy;
        vec3 v6  = vos + nor - dir.yzx + dir.zxy;
	    vec3 v7  = vos + nor - dir.yzx - dir.zxy;
	    vec3 v8  = vos + nor + dir.yzx - dir.zxy;
	    vec3 v9  = vos + dir.yzx;
	    vec3 v10 = vos - dir.yzx;
	    vec3 v11 = vos + dir.zxy;
	    vec3 v12 = vos - dir.zxy;
 	    vec3 v13 = vos + dir.yzx + dir.zxy; 
	    vec3 v14 = vos - dir.yzx + dir.zxy ;
	    vec3 v15 = vos - dir.yzx - dir.zxy;
	    vec3 v16 = vos + dir.yzx - dir.zxy;

		vec4 ed = vec4( map(v1),  map(v2),  map(v3),  map(v4)  );
	    vec4 co = vec4( map(v5),  map(v6),  map(v7),  map(v8)  );
	    vec4 ep = vec4( map(v9),  map(v10), map(v11), map(v12) );
	    vec4 cp = vec4( map(v13), map(v14), map(v15), map(v16) );
		
		vec2 uv = vec2( dot(dir.yzx, uvw), dot(dir.zxy, uvw) );
			
        // wireframe
        vec4 ee = 1.0-ep*(1.0-ed);
        float www = 1.0;
        www *= 1.0 - smoothstep( 0.85, 0.99,     uv.x )*ee.x;
        www *= 1.0 - smoothstep( 0.85, 0.99, 1.0-uv.x )*ee.y;
        www *= 1.0 - smoothstep( 0.85, 0.99,     uv.y )*ee.z;
        www *= 1.0 - smoothstep( 0.85, 0.99, 1.0-uv.y )*ee.w;
        www *= 1.0 - smoothstep( 0.85, 0.99,      uv.y*      uv.x )*(1.0-cp.x*(1.0-co.x))*(1.0-ee.x)*(1.0-ee.z);
        www *= 1.0 - smoothstep( 0.85, 0.99,      uv.y* (1.0-uv.x))*(1.0-cp.y*(1.0-co.y))*(1.0-ee.y)*(1.0-ee.z);
        www *= 1.0 - smoothstep( 0.85, 0.99, (1.0-uv.y)*(1.0-uv.x))*(1.0-cp.z*(1.0-co.z))*(1.0-ee.y)*(1.0-ee.w);
        www *= 1.0 - smoothstep( 0.85, 0.99, (1.0-uv.y)*     uv.x )*(1.0-cp.w*(1.0-co.w))*(1.0-ee.x)*(1.0-ee.w);
		
        vec3 wir = smoothstep( 0.4, 0.5, abs(uvw-0.5) );
        float vvv = (1.0-wir.x*wir.y)*(1.0-wir.x*wir.z)*(1.0-wir.y*wir.z);

        col = 2.0*texture2D( iChannel1,0.01*pos.xz ).zyx; 
        col += 0.8*vec3(0.1,0.3,0.4);
        col *= 0.5 + 0.5*texcube( iChannel2, 0.5*pos, nor ).x;
        col *= 1.0 - 0.75*(1.0-vvv)*www;
		
        // lighting
        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
        float bac = clamp( dot( nor, normalize(lig*vec3(-1.0,0.0,-1.0)) ), 0.0, 1.0 );
        float sky = 0.5 + 0.5*nor.y;
        float amb = clamp(0.75 + pos.y/25.0,0.0,1.0);
        float occ = 1.0;
	
        // ambient occlusion
        occ = 0.0; 
        // (for edges)
        occ += (    uv.x) * ed.x;
        occ += (1.0-uv.x) * ed.y;
        occ += (    uv.y) * ed.z;
        occ += (1.0-uv.y) * ed.w;
        // (for corners)
        occ += (      uv.y *     uv.x ) * co.x*(1.0-ed.x)*(1.0-ed.z);
        occ += (      uv.y *(1.0-uv.x)) * co.y*(1.0-ed.z)*(1.0-ed.y);
        occ += ( (1.0-uv.y)*(1.0-uv.x)) * co.z*(1.0-ed.y)*(1.0-ed.w);
        occ += ( (1.0-uv.y)*     uv.x ) * co.w*(1.0-ed.w)*(1.0-ed.x);
        occ = 1.0 - occ/8.0;
        occ = occ*occ;
        occ = occ*occ;
        occ *= amb;

        // lighting
        vec3 lin = vec3(0.0);
        lin += 2.5*dif*vec3(1.00,0.90,0.70)*(0.5+0.5*occ);
        lin += 0.5*bac*vec3(0.15,0.10,0.10)*occ;
        lin += 2.0*sky*vec3(0.40,0.30,0.15)*occ;

        // line glow	
        float lineglow = 0.0;
        lineglow += smoothstep( 0.4, 1.0,     uv.x )*(1.0-ep.x*(1.0-ed.x));
        lineglow += smoothstep( 0.4, 1.0, 1.0-uv.x )*(1.0-ep.y*(1.0-ed.y));
        lineglow += smoothstep( 0.4, 1.0,     uv.y )*(1.0-ep.z*(1.0-ed.z));
        lineglow += smoothstep( 0.4, 1.0, 1.0-uv.y )*(1.0-ep.w*(1.0-ed.w));
        lineglow += smoothstep( 0.4, 1.0,      uv.y*      uv.x )*(1.0-cp.x*(1.0-co.x));
        lineglow += smoothstep( 0.4, 1.0,      uv.y* (1.0-uv.x))*(1.0-cp.y*(1.0-co.y));
        lineglow += smoothstep( 0.4, 1.0, (1.0-uv.y)*(1.0-uv.x))*(1.0-cp.z*(1.0-co.z));
        lineglow += smoothstep( 0.4, 1.0, (1.0-uv.y)*     uv.x )*(1.0-cp.w*(1.0-co.w));
		
        vec3 linCol = 2.0*vec3(5.0,0.6,0.0);
        linCol *= (0.5+0.5*occ)*0.5;
        lin += 3.0*lineglow*linCol;
		
        col = col*lin;
        col += 8.0*linCol*vec3(1.0,2.0,3.0)*(1.0-www);//*(0.5+1.0*sha);
        col += 0.1*lineglow*linCol;
        col *= min(0.1,exp( -0.07*t ));
	
        // blend to black & white		
        vec3 col2 = vec3(1.3)*(0.5+0.5*nor.y)*occ*www*(0.9+0.1*vvv)*exp( -0.04*t );;
        float mi = sin(-1.57+0.5*iGlobalTime);
        mi = smoothstep( 0.90, 0.95, mi );
        col = mix( col, col2, mi );
	}

	// gamma	
	col = pow( col, vec3(0.45) );

    return col;
}

void mainImageST(out vec4 fragColor, in vec2 fragCoord, 
                 in vec3 sphereDir, in float sphereMix)
{
    // inputs	
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x/ iResolution.y;
	
    vec2 mo = iMouse.xy / iResolution.xy;
    if( iMouse.w<=0.00001 ) mo=vec2(0.0);
	
	float time = 2.0*iGlobalTime + 50.0*mo.x;
    // camera
	float cr = 0.2*cos(0.1*iGlobalTime);
	vec3 ro = path( time+0.0, 1.0 );
	vec3 ta = path( time+5.0, 1.0 ) - vec3(0.0,6.0,0.0);
	gro = ro;

    mat3 cam = setCamera( ro, ta, cr );
	
	// build ray
    float r2 = p.x*p.x*0.32 + p.y*p.y;
    p *= (7.0-sqrt(37.5-11.5*r2))/(r2+1.0);
    vec3 rd = normalize( cam * vec3(p.xy,-2.5) );
    
    // XXX Here the ray-direction is mixed
    rd = mix(rd, cam * sphereDir, sphereMix); 

    vec3 col = render( ro, rd );
    
	// vignetting
    vec3 ppcol = col * (0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 ) );
	
    // XXX Here we mix the color with the post-processed color
    // which depends on the screen uv
    col = mix(col, ppcol, 1.-sphereMix);
    
	fragColor = vec4( col, 1.0 );
}





// -------------- helper -----------------------------------

/* Insert cartesian [-1,1], receive sphere surface [-1,1].
   @p angle is in degree */
vec3 _uv_to_sphere(in vec2 uv, in float angle)
{
    // distance from center
    float dist = length(uv);

    if (dist > 1.0)
        return vec3(0.);

    float   // cartesian screen-space to spherical
            theta = dist * 3.14159265 * angle / 360.0,
            phi = atan(uv.y, uv.x);

    // spherical-to-cartesian
    return vec3(sin(theta) * cos(phi),
                sin(theta) * sin(phi),
                -cos(theta));
}

/** Returns intersection position along the ray ro -> rd
    for a plane with normal plane.xyz and position plane.xyz * plane.w.
    Result is either negative for no hit
    or the distance between ro and the intersection point. */
float _intersect_plane(in vec3 ro, in vec3 rd, in vec4 plane)
{
    float dir = dot(plane.xyz, rd);
    if (abs(dir) < 0.0001) return -1.;
    return dot(plane.xyz, plane.xyz * plane.w - ro) / dir;
}

float _hash1(in vec2 x) { return fract(sin(x.x*11.+x.y*17.)*(17162.31+111.*x.y)); }
vec2 _hash2(in vec2 x) { return vec2(_hash1(x),_hash1(x*1.1-3.13)); }


// ----- chars ---------------------------------------------

// uv = [-1,1]
float _random_char(in vec2 uv, in vec2 seed)
{
    float l = length(uv);
    float d = 100.;
#define SEG(prob, di) d = min(d, floor(1./(prob)*_hash1(seed+=.1*seed-.1)) + di);
    SEG(.3 , abs(uv.x - uv.y*.8)-.2)
    SEG(.3 , abs(uv.x + uv.y*.8)-.2)
    SEG(.3 , abs(uv.x)-.15)
    SEG(.1 , abs(uv.y)-.15)
    SEG(.1 , abs(uv.y-.7)-.15)
    SEG(.1 , abs(uv.x-.7)-.2)
    SEG(.1 , abs(uv.x+.7)-.2)
    SEG(.07, max(l-.8, -l+.5))
    SEG(.1 , max(max(l-.8, -l+.5), -uv.x))
    SEG(.1 , max(max(l-.8, -l+.5),  uv.x))
#undef SEG
    d = max(d, -uv.x-.8);    
    d = max(d,  uv.x-.8);    
    d = max(d, -uv.y-.8);    
    d = max(d,  uv.y-.8);    
        
	//d = max(d, -d); // edge
        
    return smoothstep(.1, .0, d);
}

/** creates left-bounded text, one char per uv-unit */
float _random_text(in vec2 uv, in vec2 seed, in float max_len)
{
    vec2 cell = floor(uv); 
    if (uv.x >= max_len || _hash1(vec2(cell.y)) < cell.x / max_len) 
        return 0.;
    
    return _random_char(fract(uv)*2. - 1., cell + seed);
	     
}
// --------------------------------------------------


// --------------- fake browser ---------------------

float _rect(in vec2 uv, in vec2 si)
{
    return uv.x >= 0. && uv.y >= 0. && uv.x <= si.x && uv.y <= si.y ? 1. : 0.; 
}

vec4 _codeWindow(in vec2 uv, in vec2 si)
{
    vec4 col = vec4(1,1,1, _rect(uv,si));
    col.xyz *= 1.-_random_text(uv*40., vec2(1.), 40.);
	return col;
}

vec4 _browserWindow(in vec2 uv, in float aspect, 
                    in float sphereMix, in vec3 sphereDir)
{
    vec2 si = vec2(aspect, 1.);
    vec4 col = vec4(.8,.8,.8, _rect(uv, si));
	
    // header
    float head = _rect(uv-vec2(0.,.92), si * vec2(1.,.08));
    col.xyz += head * (vec3(.4) - col.xyz);
	col.xyz += head * _random_text(uv*12.-vec2(0,10), vec2(5), 10.);
    vec2 headuv = (uv-vec2(si.x/1.7,0.11)) * 24.;
    if (headuv.x > 0. && int(headuv.y) == 20)
	col.xyz += head * _random_text(headuv, vec2(.1), 50.);
    
    // code window
    vec4 cCode = _codeWindow(uv-si/vec2(2.1,5.), si*vec2(.5,.63));
    col += cCode.w * (cCode - col);
    col.xyz *= 1.-.3*_rect(uv-si/vec2(2.1,1.2), vec2(.06, .05));
    col.xyz += _rect(uv-si/vec2(1.95,1.2), vec2(.09, .05)) * (vec3(1.,.7,0) - col.xyz);
    
    // texture inputs
    for (float i=0.; i<4.; ++i)
    	col.xyz *= 1. - _rect(uv - vec2(si.x/2.1 + si.x*i/8.,.02), si/8.5);
    
    // messages
    if (uv.x > 0.02 && uv.y < .3)
    	col.xyz *= 1. - _random_text((uv-vec2(0.02,0))*40., vec2(.1), 30.);
    
    // shader window
    vec2 suv = (uv - vec2(.03, .38)) * vec2(2.3/si.x, 2.);
    if (suv.x >= 0. && suv.y >= 0. && suv.x < 1. && suv.y < 1.)
        mainImageST(col, suv * iResolution.xy, sphereDir, sphereMix);
    
    return col;
}

// --------------------------------------------------



void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float onDome = .5+.6*sin(iGlobalTime/4.+.3);
    if (iMouse.z > .5)
        onDome = iMouse.y / iResolution.y * 1.1;
    onDome = clamp(onDome, 0., 1.);
    
    
	vec2 uv = (fragCoord.xy - .5*iResolution.xy) / iResolution.y * 2.;
    if (length(uv) > 1.)
        fragColor = vec4(0,0,0,1);
    else
    {
        // fulldome/fisheye ray direction 
        vec3 sphereDir = _uv_to_sphere(uv, 180.);

        // render dome image
       	mainImageST(fragColor, fragCoord, sphereDir, 1.);
        fragColor.xyz *= onDome * onDome;
		
        // render browser window
        if (onDome < 1.)
        {
            vec3 planeNorm = normalize(vec3(0,1,2.-onDome));
            float t = _intersect_plane(vec3(0.), sphereDir, vec4(planeNorm,-(1.-onDome)));
            if (t > 0.)
            {
                vec2 puv = (sphereDir * t).xy+1.-.4*onDome;
                vec4 c = _browserWindow(puv, 1.9, onDome, sphereDir);
                fragColor.xyz += c.w * (c.xyz - fragColor.xyz);
            }
        }
        
    }
}