// Shader downloaded from https://www.shadertoy.com/view/MscXDf
// written by shadertoy user dencarl
//
// Name: Sol System
// Description: Our solar system.  Heavily modified from a ball occlusion example by iq.
//    
//    Simple at the moment.  Might add more later.
// Inspired by https://www.shadertoy.com/view/ldX3Ws (inigo quilez - iq/2013)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// TODO: 
//    - Saturn rings
//    - asteroid belt
//    - shading
//    - textures
//    - shadows / eclipses
//    - skybox / milky way

#define eps 0.001
#define NUMSPH 9
vec4 sphere[NUMSPH];

void getPlanet( in int i, out float r, out float d, out vec3 c, out float op, out float rp, out float ga)
{
    // i index
    // r radius (km)
    // d distance (km)
    // c color (rgb)
    // op orbital period (days)
    // rp rotation period (days)
    // ga geometric albedo (fraction)
    
    if( i == 0 )
    {
        // Sol
		r = 695700.0;
		d = 0.0;
		c = vec3( 1.0, 0.5, 0.0 );
        op = 0.0;
        rp = 0.0;
        ga = 1.0;
        return;
    }
    if( i == 1 )
    {
        // Mercury
		r = 2439.7;
		d = (69816.9+46001.2+57909.05)/3.0*1000.0;
		c = vec3( 0.6, 0.6, 0.6 );
        op = 87.9691;
        rp = 58.646;
        ga = 0.142;
        return;
    }
    if( i == 2 )
    {
        // Venus
		r = 6051.8;
		d = (108939.0+107477.0+108208.0)/3.0*1000.0;
		c = vec3(0.8, 0.76, 0.66 );  // 204, 195, 168
        op = 224.701;
        rp = -243.025;
        ga = 0.67;
        return;
    }
    if( i == 3 )
    {
        // Earth
		r = 6378.1;
		d = (152100.0+147095.0+149598.0)/3.0*1000.0;
		c = vec3(0.3, 0.3, 0.5);
        op = 365.256363;
        rp = 0.99726968;
        ga = 0.367;
        return;
    }
    if( i == 4 )
    {
        // Mars
		r = 3389.5;
		d = (249.2+206.7+227.9392)/3.0*1000.0*1000.0;
		c = vec3(0.66, 0.44, 0.28); // 168, 112, 72
        op = 686.971;
        rp = 1.025957;
        ga = 0.170;
        return;
    }
	if( i == 5 )
    {
        // Jupiter
		r = 69911.0;
		d = (816.04+740.55+778.299)/3.0*1000.0*1000.0;
		c = vec3( 0.73, 0.68, 0.62 ); // 187, 173, 157
        op = 4332.59;
        rp = 9.925/24.0;
        ga = 0.52;
        return;
    }
    if( i == 6 )
    {
        // Saturn
		r = 58232.0;
		d = (1509.0+1350.0+1429.39)/3.0*1000.0*1000.0;
		c = vec3( 0.65, 0.58, 0.43 ); // 166, 149, 109
        op = 10759.22;
        rp = 10.55/24.0;
        ga = 0.47;
        return;
    }
    if( i == 7 )
    {
        // Uranus
		r = 25362.0;
		d = (3008.0+2742.0+2875.04)/3.0*1000.0*1000.0;
		c = vec3( 0.75, 0.88, 0.91 ); // 190, 228, 231
        op = 30688.5;
        rp = 0.71833;
        ga = 0.51;
        return;
    }
    if( i == 8 )
    {
        // Moon
		r = 1737.1;
		d = (362600.0+405400.0+384399.0)/3.0;
		c = vec3( 0.39, 0.38, 0.37 ); // 100, 97, 94
        op = 27.321661;
        rp = 27.321661;
        ga = 0.136;
        return;
    }
}

// test if position is inside sphere boundary
vec3 nSphere( in vec3 pos, in vec4 sph )
{
    return (pos-sph.xyz)/sph.w;
}

// ?
float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

// ?
float sSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - sph.w*sph.w;
	
    return step( min( -b, min( c, b*b - c ) ), 0.0 );
}

// return negative if nothing hit
float intersect( in vec3 ro, in vec3 rd, out vec3 nor, out float rad, out float id )
{
	float res = 1e20;
	float fou = -1.0;
	
	nor = vec3(0.0);

	for( int i=0; i<NUMSPH; i++ )
	{
		vec4 sph = sphere[i];
	    float t = iSphere( ro, rd, sph ); 
		if( t>eps && t<res ) 
		{
			res = t;
			nor = nSphere( ro + t*rd, sph );
			fou = 1.0;
			rad = sphere[i].w;
            id = float(i);
		}
	}
						  
    return fou * res;					  
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;
	
    //-----------------------------------------------------
    // animate planets
    //-----------------------------------------------------
	float time = iGlobalTime + 0.7/0.3*0.5;
	float an = 0.3*time - .7*m.x;

    // other planets
    for( int i=0; i<NUMSPH; i++ )
	{
        // get planet info
        float r, d, op, rp, ga;
        vec3 c;
        getPlanet( i, r, d, c, op, rp, ga );
        
        // rescale for illustrative purposes
        d = max(0.0, pow(d+1.0,1.0/2.125) ) / 2.5;
        r = pow(r+1.0,1.0/1.9) / 1.0;
        
        // find rotation from time elapsed and orbital period
        //float a = -an / pow(op+1.0, 1.0/2.0 ) * 50.0;
        float a = -an / op * 600.0;

        // set animated position of planets
        sphere[i] = vec4( d*cos(a), 0.0, d*sin(a), r );
    }
    // the sun
	//sphere[0].w = sphere[5].w;
    //sphere[0].w = log(sphere[0].w);
    sphere[0].xyz = vec3(0.0);
    // moon
    float r = sphere[8].w;
    //sphere[8] /= 10.0;
	sphere[8] += sphere[3];
    sphere[8].w = r;
    
			
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	//vec3(3.5*sin(an),1.5*cos(0.5*an)+22.2,2.5*cos(an));
    //vec3 ro = vec3(200.0, 200.0,100.0);
    //vec3 ta = vec3(0.0,0.0,-1000.0);

    //vec3 ro1 = normalize( vec3(0.1,1.0,0.75)) * sphere[0].w * 7.0;
    //vec3 ta1 = vec3(0.0,-1.0,-1.0) * length(sphere[7].xyz);
    //vec3 ro2 = normalize( vec3(1.0,0.0,0.01)) * sphere[0].w * 1.01;
    //vec3 ta2 = vec3(2.50,0.0,-5.0) * length(sphere[7].xyz);

    vec3 ro1 = normalize( vec3(0.0,1.0,0.0) - normalize( sphere[7].xyz )) * length(sphere[7].xyz) * 1.0;
    vec3 ta1 = vec3(0.0,0.0,0.0) * length(sphere[7].xyz);

    vec3 ro2 = normalize( cross(sphere[7].xyz, vec3(0.0,1.0,0.0) )) * sphere[0].w * 1.0095;
    vec3 ta2 = sphere[7].xyz; // vec3(2.50,0.0,-5.0) * length(sphere[7].xyz);

    // set ray origin and target
    vec3 ro = mix( ro1, ro2, 1.0-smoothstep(-1.0,1.0,cos(an*0.3)) );
    vec3 ta = mix( ta1, ta2, 1.0-smoothstep(-1.0,1.0,cos(an*0.3)) );

    // calculate camera orientation
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------
    
    // background colour
    vec3 col = vec3(0.0, 0.0, 0.15);
    
    // vertical gradient
    // col *= (0.98+0.1*rd.y);
	col.z += (0.1+0.1*rd.y);
    
	// cast ray to find planets
	vec3 nor;
	float rad = 0.5;
    float id;
	float t = intersect(ro,rd,nor, rad, id);
	if( t>0.0 )
	{
        // planet stats do-hickey
		float r, d, op, rp, ga;
        getPlanet( int(id), r, d, col, op, rp, ga );        
    }
    // vigneting
    //col *= 1.0 - 0.45*dot((q-0.5),(q-0.5));

    fragColor = vec4( col, 1.0 );
    return;

}
