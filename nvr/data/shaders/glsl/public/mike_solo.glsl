// Shader downloaded from https://www.shadertoy.com/view/lls3Dr
// written by shadertoy user aiekick
//
// Name: Mike Solo
// Description: Based on the famous iq shader of  Mike [url]https://www.shadertoy.com/view/MsXGWr[/url]
//    Carbonite attempt... can be optimised a little bit :)
//    you can control the camera by mouse
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Based on the famous iq shader of Mike (monster inc. - PIXAR) https://www.shadertoy.com/view/MsXGWr

// Attempt to put Mike in carbonite like Han Solo in Starwars ^^

mat3 getRotXMat(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 getTransMat(float x,float y,float z){return mat3(1.,0.,x,0.,1.,y,0.,0.,z);}

// vars thick
float thickArm = 0.05;
float thickWrist = 0.05;
float thickHand = 0.05;
float thickKnee = 0.1;
float thickLeg = 0.1;
float thickFoot = 0.08;
    
// vars coord // left
vec3 LarmS = vec3(-0.8,2.2,0.);
vec3 LarmE = vec3(-1.,1.5,0.4);
vec3 LwristE = vec3(-1.1,2.2,0.6);
vec3 LFinger11 = vec3(-1.15,2.4,0.55);
vec3 LFinger12 = vec3(-1.17,2.5,0.63);
vec3 LFinger21 = vec3(-1.05,2.4,0.55);
vec3 LFinger22 = vec3(-1.03,2.55,0.62);
vec3 LFinger31 = vec3(-0.95,2.3,0.55);
vec3 LFinger32 = vec3(-0.85,2.4,0.63);
vec3 LkneeS = vec3(-0.5,1.5,0.3);
vec3 LkneeE = vec3(-0.6,0.85,0.65);
vec3 LlegE = vec3(-0.6,0.2,0.4);
vec3 LFootE1 = vec3(-0.75,-0.1,0.6);
vec3 LFootE2 = vec3(-0.6,-0.1,0.6);
vec3 LFootE3 = vec3(-0.45,-0.1,0.6);
    
// vars coord // right
vec3 RarmS = vec3(0.8,2.2,0.);
vec3 RarmE = vec3(1.,1.5,0.4);
vec3 RwristE = vec3(1.,2.,0.6);
vec3 RFinger11 = vec3(1.15,2.2,0.55);
vec3 RFinger12 = vec3(1.17,2.3,0.63);
vec3 RFinger21 = vec3(1.05,2.2,0.55);
vec3 RFinger22 = vec3(1.03,2.35,0.62);
vec3 RFinger31 = vec3(0.95,2.1,0.55);
vec3 RFinger32 = vec3(0.85,2.2,0.63);
vec3 RkneeS = vec3(0.5,1.5,0.3);
vec3 RkneeE = vec3(0.6,0.85,0.5);
vec3 RlegE = vec3(0.6,0.4,0.4);

const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );

float udBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}

vec2 sdSegment( vec3 a, vec3 b, vec3 p )
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec2( length( pa - ba*h ), h );
}

////////BOOLEANS OP////////////////////////
float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);}

// head + eye + mouth + teeth
vec2 mapHead( vec3 p )
{
    p.x = abs(p.x);
    
    vec3 q = p;
	q.y -= 0.3*pow(1.0-length(p.xz),1.0)*smoothstep(0.0, 0.2, p.y);
	q.y *= 1.05;
	q.z *= 1.0 + 0.1*smoothstep( 0.0, 0.5, q.z )*smoothstep( -0.5, 0.5, p.y );
    float dd = length( (p - vec3(0.0,0.65,0.8))*vec3(1.0,0.75,1.0) );
	float am = clamp( 4.0*abs(p.y-0.45), 0.0, 1.0 );
	float fo = -0.03*(1.0-smoothstep( 0.0, 0.04*am, abs(dd-0.42) ))*am;
    float dd2 = length( (p - vec3(0.0,0.65,0.8))*vec3(1.0,0.25,1.0) );
	float am2 = clamp( 1.5*(p.y-0.45), 0.0, 1.0 );
	float fo2 = -0.085*(1.0-smoothstep( 0.0, 0.08*am2, abs(dd2-0.42) ))*am2;
    q.y += -0.05+0.05*length(q.x);
	
    float sco = 0.45;// scale du pourtour de l'oeil
	float d1 = length( q ) - 0.9 + fo*sco + fo2*sco;// le body
    vec2 res = vec2( d1, 1.);

    // eyes - oeil
	float d3 = length( (p - vec3(0.0,0.25,0.35))*vec3(1.0,0.8,1.0) ) - 0.5;
    res.x = smin(res.x, d3, 0.01); // smooth entre l'oeil et le pourtour
    
	// mouth - bouche (four)
	float mo = length( (q-vec3(0.0,-0.35,1.))*vec3(1.0,1.2,0.25)/1.2 ) -0.3/1.2;
	float of = 0.1*pow(smoothstep( 0.0, 0.2, abs(p.x-0.3) ),0.5);
	mo = max( mo, -q.y-0.35-of );

	float li = smoothstep( 0.0, 0.05, mo+0.02 ) - smoothstep( 0.05, 0.10, mo+0.02 );
	res.x -= 0.03*li*clamp( (-q.y-0.4)*10.0, 0.0, 1.0 );
	
    if( -mo > res.x ) res = vec2( -mo, 0.5 );

    res.x += 0.01*(smoothstep( 0.0, 0.05, mo+0.062 ) - smoothstep( 0.05, 0.10, mo+0.062 ));

    // teeth - dents
	if( p.x<0.3 )
	{
        p.x = mod( p.x, 0.16 )-0.08;	
        float d5 = length( (p-vec3(0.0,-0.37,0.65))*vec3(1.0,2.0,1.0))-0.08;
        res.x = smin(res.x, d5, 0.02); // smooth entre l'oeil et le pourtour
    }
	
    // fond de mouth
    float d2 = length( q ) - 0.8;
    res.x = smin(res.x, d2, 0.16);
    
	return res.xy;
}

vec2 mapCarbonite( vec3 p )
{
    // displacement steal
    float prec = 0.035; // displacement scale
    float disp = 1. - smoothstep(0., 1., dot(texture2D(iChannel1, p.xy/1.8).rgb, vec3(prec)));
    p.z += disp;
    
    // head position and orientation
    vec3 q = p - vec3(-.1,0.1,0.45);
    q *= getRotYMat(0.3) * getRotXMat(0.15);
    q.y -= 2.;
    vec2 res = mapHead(q);

    // left arm // bras
    //vec2 Larm = sdSegment(LarmS, LarmE, p);
    //res.x = smin(res.x, Larm.x-thickArm, 0.05);
    
    // left wrist // poignet
    vec2 Lwrist = sdSegment(LarmE, LwristE, p);
    res.x = smin(res.x, Lwrist.x-thickWrist, 0.05);
    
    // left hand // main
    vec2 Lhand11 = sdSegment(LwristE, LFinger11, p);
    res.x = smin(res.x, Lhand11.x-thickHand, 0.03);
    vec2 Lhand21 = sdSegment(LwristE, LFinger21, p);
    res.x = smin(res.x, Lhand21.x-thickHand, 0.03);
    vec2 Lhand31 = sdSegment(LwristE, LFinger31, p);
    res.x = smin(res.x, Lhand31.x-thickHand, 0.03);
    vec2 Lhand12 = sdSegment(LFinger11, LFinger12, p);
    res.x = smin(res.x, Lhand12.x-thickHand, 0.03);
    vec2 Lhand22 = sdSegment(LFinger21, LFinger22, p);
    res.x = smin(res.x, Lhand22.x-thickHand, 0.03);
    vec2 Lhand32 = sdSegment(LFinger31, LFinger32, p);
    res.x = smin(res.x, Lhand32.x-thickHand, 0.03);
    
    // left knee // genou
    vec2 Lknee = sdSegment(LkneeS, LkneeE, p);
    res.x = smin(res.x, Lknee.x-thickKnee, 0.08);
    
    // left leg // molet
    vec2 Lleg = sdSegment(LkneeE, LlegE, p);
    res.x = smin(res.x, Lleg.x-thickLeg, 0.05);
    
    // left foot // pied
    vec2 LFoot1 = sdSegment(LlegE, LFootE1, p);
    res.x = smin(res.x, LFoot1.x-thickFoot, 0.05);
    vec2 LFoot2 = sdSegment(LlegE, LFootE2, p);
    res.x = smin(res.x, LFoot2.x-thickFoot, 0.05);
    vec2 LFoot3 = sdSegment(LlegE, LFootE3, p);
    res.x = smin(res.x, LFoot3.x-thickFoot, 0.05);
    
    // right arm // bras
    //vec2 Rarm = sdSegment(RarmS, RarmE, p);
    //res.x = smin(res.x, Rarm.x-thickArm, 0.05);
    
    // right hand // main
    vec2 Rhand11 = sdSegment(RwristE, RFinger11, p);
    res.x = smin(res.x, Rhand11.x-thickHand, 0.03);
    vec2 Rhand21 = sdSegment(RwristE, RFinger21, p);
    res.x = smin(res.x, Rhand21.x-thickHand, 0.03);
    vec2 Rhand31 = sdSegment(RwristE, RFinger31, p);
    res.x = smin(res.x, Rhand31.x-thickHand, 0.03);
    vec2 Rhand12 = sdSegment(RFinger11, RFinger12, p);
    res.x = smin(res.x, Rhand12.x-thickHand, 0.03);
    vec2 Rhand22 = sdSegment(RFinger21, RFinger22, p);
    res.x = smin(res.x, Rhand22.x-thickHand, 0.03);
    vec2 Rhand32 = sdSegment(RFinger31, RFinger32, p);
    res.x = smin(res.x, Rhand32.x-thickHand, 0.03);
        
    // right wrist // poignet
    vec2 Rwrist = sdSegment(RarmE, RwristE, p);
    res.x = smin(res.x, Rwrist.x-thickWrist, 0.05);
    
    // right knee // genou
    vec2 Rknee = sdSegment(RkneeS, RkneeE, p);
    res.x = smin(res.x, Rknee.x-thickKnee, 0.05);
    
    // right leg // molet
    vec2 Rleg = sdSegment(RkneeE, RlegE, p);
    res.x = smin(res.x, Rleg.x-thickLeg, 0.05);
    
    // right foot // pied
    
    // carbonite box
    float box = udBox(p-vec3(0.,0.,-0.13), vec3(1.5,4.,0.65));
   	res.x = smin(res.x, box, 0.05);
    
    return res;
}

vec2 map( vec3 p )
{
    vec2 res = mapCarbonite( p-vec3(0.,1.,2.) );
    
	return vec2(res.x*0.8,res.y);
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.002,0.0,0.0);
	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
    float m = -1.0;
	float mint = 20.0;

    // plane	
	float tf = (0.0-ro.y)/rd.y;
	if( tf>0.0 ) { mint = tf; m = 0.0; }
	
	// mike
	float maxd = min(20.0,mint);
	float precis = 0.001;
    float h = precis*2.0;
    float t = 0.0;
	float d = 0.0;
    for( int i=0; i<80; i++ )
    {
        if( h<precis||t>maxd ) break;
        t += h;
	    vec2 res = map( ro+rd*t );
        h = res.x;
		d = res.y;
    }

    if( t<maxd && t<mint )
	{
		mint = t;
		m = d;
	}

    return vec3( mint, m, m );
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float k )
{
    float res = 1.0;
    float t = mint;
	float h = 1.0;
    for( int i=0; i<10; i++ )
    {
        h = map(ro + rd*t).x;
        res = min( res, smoothstep(0.0,1.0,k*h/t) );
		t += clamp( h, 0.02, 2.0 );
		if( res<0.01 || t>10.0 ) break;
    }
    return clamp(res,0.0,1.0);
}

// light
vec3 lig = normalize(vec3(0.,4.,8.));

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1. + 2. * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
    
	if( iMouse.z>0.0 ) 
        m = vec2(
        	iMouse.x/iResolution.x,
        	1.-iMouse.y/iResolution.y);

	#ifdef STEREO
	float eyeID = mod(fragCoord.x + mod(fragCoord.y,2.0),2.0);
    #endif

    //-----------------------------------------------------
    // animate
    //-----------------------------------------------------
	
	float ctime = iGlobalTime;

	float proxiCam = 6.5;
    
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	
	float an = sin(0.314519*ctime)*0.8 - 6.2831*(m.x-0.5);

	vec3 ro = vec3(proxiCam*sin(an),6.*m.y,proxiCam*cos(an));
    vec3 ta = vec3(0.0,2.5,0.0);

    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

	#ifdef STEREO
        vec3 fo = ro + rd*7.0; // put focus plane behind Mike
        ro -= 0.1*uu*eyeID;    // eye separation
        rd = normalize(fo-ro);
    #endif

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = vec3(1.0);

	// raymarch
    vec3 tmat = intersect(ro,rd);
    if( tmat.z>-0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
		vec3 ref = reflect( rd, nor );

        // materials
		vec4 mate = vec4(vec3(0.),1.0);
		vec2 mate2 = vec2(1.0);
		if( tmat.z<0.5 ) // sol
		{
			nor = vec3(0.0,1.0,0.0);
		    ref = reflect( rd, nor );
			mate.xyz = vec3(1.0);
            mate2.y = 1.0 - 0.9*(2.0/(2.0+dot(pos.xz,pos.xz)));
		}
		
        mate2.x = 0.4;

        col = textureCube(iChannel0, reflect(rd, nor)).rgb * .45;
        
		// lighting
		float occ = (0.5 + 0.5*nor.y)*mate2.y;
        float amb = 0.0;
		float bou = clamp(-nor.y,0.0,1.0);
		float dif = max(dot(nor,lig),0.0);
        float bac = max(0.3 + 0.7*dot(nor,-lig),0.0);
		float sha = 0.0; if( dif>0.01 ) sha=softshadow( pos+0.01*nor, lig, 0.0005, 32.0 );
        float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 2.0 );
        float spe = max( 0.0, pow( clamp( dot(lig,reflect(rd,nor)), 0.0, 1.0), mate2.x*3. ) );
		
		// lights
		vec3 lin = vec3(0.0);
        lin += 2.0*dif*vec3(1.00,1.00,1.00)*pow(vec3(sha),vec3(1.0,1.2,1.5));
		lin += 1.0*amb*vec3(0.30,0.30,0.30)*occ;
		lin += 2.0*bou*vec3(0.40,0.40,0.40)*mate2.y;
		lin += 4.0*bac*vec3(0.40,0.30,0.25)*occ;
        lin += 1.0*fre*vec3(1.00,1.00,1.00)*2.0*mate.w*(0.5+0.5*dif*sha)*occ;
		lin += 1.0*spe*vec3(1.0)*occ*mate.w*dif*sha;

		// surface-light interacion
		col = mix(col, mate.xyz* lin + vec3(2.5)*mate.w*pow(spe,8.0)*sha, 0.8);
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );

	// vigneting
    col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 );

    #ifdef STEREO	
    col *= vec3( eyeID, 1.0-eyeID, 1.0-eyeID );	
	#endif

    fragColor = vec4( col, 1.0 );
}
