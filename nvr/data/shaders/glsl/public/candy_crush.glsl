// Shader downloaded from https://www.shadertoy.com/view/XdtSDH
// written by shadertoy user ciberxtrem
//
// Name: Candy Crush
// Description: * Click to the first candy and then click to the second to replace it !
//    * Make the most points ;)
const float xCells = 10.;
const float yCells = 8.;
const vec2 cellSize = vec2(0.5);
const vec2 gridPos = vec2(6.315, 0.8);

vec4 mCellId    = vec4(0.,    0.,     xCells, yCells);
vec4 mCellPos   = vec4(0.,    yCells, xCells, yCells);
vec2 mState     = vec2(0., 2.*yCells);
vec2 mSelected0 = vec2(1., 2.*yCells);
vec2 mSelected1 = vec2(2., 2.*yCells);
vec2 mMouse     = vec2(3., 2.*yCells);

vec4 gState;
vec2 gUv;
float gT;

//-----------------------------------------------------------------------------------
//  Font reference:
//  Dave_Hoskins - https://www.shadertoy.com/view/XdXGRB
//  original reference claudiocc - http://glslsandbox.com/e#9743.20 
#define font_size 20. 
#define font_spacing .05
#define STROKEWIDTH 0.05
#define PI 3.14159265359

#define A_ vec2(0.,0.)
#define B_ vec2(1.,0.)
#define C_ vec2(2.,0.)


#define E_ vec2(1.,1.)
#define G_ vec2(0.,2.)
#define H_ vec2(1.,2.)
#define I_ vec2(2.,2.)

#define J_ vec2(0.,3.)
#define K_ vec2(1.,3.)
#define L_ vec2(2.,3.)

#define M_ vec2(0.,4.)
#define N_ vec2(1.,4.)
#define O_ vec2(2.,4.)

#define S_ vec2(0.,6.)
#define T_ vec2(1.,6.)
#define U_ vec2(2.0,6.)

#define A(p) t(G_,I_,p) + t(I_,O_,p) + t(O_,M_, p) + t(M_,J_,p) + t(J_,L_,p)
#define B(p) t(A_,M_,p) + t(M_,O_,p) + t(O_,I_, p) + t(I_,G_,p)
#define C(p) t(I_,G_,p) + t(G_,M_,p) + t(M_,O_,p) 
#define D(p) t(C_,O_,p) + t(O_,M_,p) + t(M_,G_,p) + t(G_,I_,p)
#define E(p) t(O_,M_,p) + t(M_,G_,p) + t(G_,I_,p) + t(I_,L_,p) + t(L_,J_,p)
#define F(p) t(C_,B_,p) + t(B_,N_,p) + t(G_,I_,p)
#define G(p) t(O_,M_,p) + t(M_,G_,p) + t(G_,I_,p) + t(I_,U_,p) + t(U_,S_,p)
#define H(p) t(A_,M_,p) + t(G_,I_,p) + t(I_,O_,p) 
#define I(p) t(E_,E_,p) + t(H_,N_,p) 
#define J(p) t(E_,E_,p) + t(H_,T_,p) + t(T_,S_,p)
#define K(p) t(A_,M_,p) + t(M_,I_,p) + t(K_,O_,p)
#define L(p) t(B_,N_,p)
#define M(p) t(M_,G_,p) + t(G_,I_,p) + t(H_,N_,p) + t(I_,O_,p)
#define N(p) t(M_,G_,p) + t(G_,I_,p) + t(I_,O_,p)
#define O(p) t(G_,I_,p) + t(I_,O_,p) + t(O_,M_, p) + t(M_,G_,p)
#define P(p) t(S_,G_,p) + t(G_,I_,p) + t(I_,O_,p) + t(O_,M_, p)
#define Q(p) t(U_,I_,p) + t(I_,G_,p) + t(G_,M_,p) + t(M_,O_, p)
#define R(p) t(M_,G_,p) + t(G_,I_,p)
#define S(p) t(I_,G_,p) + t(G_,J_,p) + t(J_,L_,p) + t(L_,O_,p) + t(O_,M_,p)
#define T(p) t(B_,N_,p) + t(N_,O_,p) + t(G_,I_,p)
#define U(p) t(G_,M_,p) + t(M_,O_,p) + t(O_,I_,p)
#define V(p) t(G_,J_,p) + t(J_,N_,p) + t(N_,L_,p) + t(L_,I_,p)
#define W(p) t(G_,M_,p) + t(M_,O_,p) + t(N_,H_,p) + t(O_,I_,p)
#define X(p) t(G_,O_,p) + t(I_,M_,p)
#define Y(p) t(G_,M_,p) + t(M_,O_,p) + t(I_,U_,p) + t(U_,S_,p)
#define Z(p) t(G_,I_,p) + t(I_,M_,p) + t(M_,O_,p)
#define STOP(p) t(N_,N_,p)

vec2 caret_origin = vec2(3.0, .7);
vec2 caret;

float minimum_distance(vec2 v, vec2 w, vec2 p)
{	// Return minimum distance between line segment vw and point p
  	float l2 = (v.x - w.x)*(v.x - w.x) + (v.y - w.y)*(v.y - w.y); //length_squared(v, w);  // i.e. |w-v|^2 -  avoid a sqrt
  	if (l2 == 0.0) {
		return distance(p, v);   // v == w case
	}
	
	// Consider the line extending the segment, parameterized as v + t (w - v).
  	// We find projection of point p onto the line.  It falls where t = [(p-v) . (w-v)] / |w-v|^2
  	float t = dot(p - v, w - v) / l2;
  	if(t < 0.0) {
		// Beyond the 'v' end of the segment
		return distance(p, v);
	} else if (t > 1.0) {
		return distance(p, w);  // Beyond the 'w' end of the segment
	}
  	vec2 projection = v + t * (w - v);  // Projection falls on the segment
	return distance(p, projection);
}

float textColor(vec2 from, vec2 to, vec2 p)
{
	p *= font_size;
	float inkNess = 0., nearLine, corner;
	nearLine = minimum_distance(from,to,p); // basic distance from segment, thanks http://glsl.heroku.com/e#6140.0
	inkNess += smoothstep(0., 1., 1.- 14.*(nearLine - STROKEWIDTH)); // ugly still
	inkNess += smoothstep(0., 2.5, 1.- (nearLine  + 5. * STROKEWIDTH)); // glow
	return inkNess;
}

vec2 grid(vec2 letterspace) 
{
	return ( vec2( (letterspace.x / 2.) * .65 , 1.0-((letterspace.y / 2.) * .95) ));
}

float count = 0.0;
float t(vec2 from, vec2 to, vec2 p) 
{
	count++;
	if (count > gT*20.0) return 0.0;
	return textColor(grid(from), grid(to), p);
}

vec2 r(vec2 pos)
{
	pos.y -= caret.y;
	pos.x -= font_spacing*caret.x;
	return pos;
}

void add()
{
	caret.x += 1.0;
}

void space()
{
	caret.x += 1.5;
}
//-----------------------------------------------------------------------------------

float hash(float x) { return fract(sin(x)*15.4); }

vec4 Load(vec2 memPos, sampler2D sampler, vec2 resolution)
{
    return texture2D(sampler, (memPos+0.5)/resolution, -100.);
}

float dsCell(vec2 p)
{
    return length(max(abs(p)-cellSize, 0.)) - 0.075;
}

float dsBox(vec2 p, vec2 b, float r)
{
    return length(max(abs(p)-b, 0.)) - r;
}

vec2 dsSegment(vec2 p, vec2 a, vec2 b)
{
    vec2 ab = b-a;
    vec2 ap = p-a;
    float h = clamp(dot(ap, ab)/dot(ab, ab), 0., 1.);
    return vec2( length(p-ab*h), h );
}

	
// polynomial smooth min (k = 0.1) taken from iq;
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float IsSameCell(vec2 a, vec2 b)
{
    vec2 dir = b-a;
    return dot(dir, dir) < 1e-3 ? 1. : 0.;
}

vec2 Rot(vec2 p, float rad)
{
    float c = cos(rad); float s = sin(rad);
    return vec2(c*p.x-s*p.y, c*p.y+s*p.x);
}

mat3 RotZ(float rad)
{
    float s = sin(rad);
    float c = cos(rad);
    return mat3(
        c,  s, 0.,
        -s, c,  0.,
        0., 0., 1.
    );
}

vec3 DrawCandy0(vec2 p, vec3 bgColor)
{
    float d = length(p)-0.5;
    float d2 = d;
    
    vec3 color = vec3(0.078, 0.2, 0.882);
    color = mix(color*0.9, color*1.1, smoothstep(-0.2, 0.4, p.x));
    vec2 q = p; q.y -= -0.1+ cos(1.+p.x*1.)*0.15;
    d = dsBox(q, vec2(0.45, 0.05), 0.05);
    d2 = min(d2, d);
    color = mix(color*1.5, color, smoothstep(0., 2e-2, d)); 
    
    vec3 cubeTex = textureCube(iChannel2, normalize(vec3(p.xy,1.)) *RotZ(1.8) ).rgb;
    color *= 1.+cubeTex.r;
    color += 1.-smoothstep(0., 1., pow(abs(length((p-vec2(-0.1, 0.2))*vec2(1.2, 2.2))), 0.35) );
    color += 1.-smoothstep(0., 1., pow(abs(length((p-vec2(0.1, -0.2))*vec2(1.2, 2.2))), 0.28) );
    color = mix(color, vec3(0.), smoothstep(0.0, 1., 1.-exp(-2.5*max(d2+0.2, 0.)) ));
    return mix(color, bgColor, smoothstep(0., 0.1, d2));
}

vec3 DrawCandy1(vec2 p, vec3 bgColor)
{
    vec2 pos[7];
    pos[0]=vec2(0., 0.); 
    pos[1]=vec2(-0.23, 0.34); pos[2]=vec2(0.23, 0.34); pos[3]=vec2(0.42, 0.0);
    pos[4]=vec2(0.23, -0.34); pos[5]=vec2(-0.23, -0.34); pos[6]=vec2(-0.42, 0.0);
    
    
    vec3 color = vec3(0.572, 0.047, 0.752);
    float d2 = 1.;
    for(int i=0; i<7;++i)
    {
        vec2 q = p-pos[i];
        float d = length(q)-0.22;
        
        vec3 baseColor = vec3(0.572, 0.047, 0.752);
        vec3 cubeTex = textureCube(iChannel2, normalize(vec3(q.xy,1.)) *RotZ(1.8) ).rgb;
        baseColor *= 1.+cubeTex.r*0.25;
        baseColor += (1.-smoothstep(0., 1., pow(abs(length((q-vec2(-0.05, 0.05))*vec2(1.2, 2.2))), 0.2) ))*1.5;
        color = mix(baseColor, color, smoothstep(0., 1e-2, d));
        d2 = smin(d, d2, 0.2);
    }
    color = mix(color, vec3(0.), smoothstep(0.0, 1., 1.-exp(-4.5*max(d2+0.1, 0.)) ));
    return mix(color, bgColor, smoothstep(0., 2e-2, d2));
}

vec3 DrawCandy2(vec2 p, vec3 bgColor)
{
    vec2 q = p-vec2(0., +0.4);
    vec2 seg = dsSegment(q, vec2(0., 0.0), vec2(0.0, -0.5));
    float d = seg.x - (0.1+2.0*pow(seg.y*0.1, 0.8)) + (length(p)-0.5)*0.5;
    vec3 color = vec3(0.733, 0.752, 0.047)*0.8;
    
    vec3 cubeTex = textureCube(iChannel2, normalize(vec3(p.xy,1.)) *RotZ(1.8) ).rgb;
    color *= 1.+cubeTex.r*0.20;
    color += 1.-smoothstep(0., 1., pow(abs(length((p-vec2(-0.05, 0.11))*vec2(1.8, 1.2))), 0.2) );
    color += 1.-smoothstep(0., 1., pow(abs(length((p-vec2(0.05, -0.1))*vec2(1.7, 1.2))), 0.21) );
    
    vec3 tmpColor = mix(mix(color*0.5, color, smoothstep(-0.5, 0.4, p.y)), color, smoothstep(0., 1., 2.*pow(abs(d+0.15), 0.4)));
    color = mix(tmpColor, color, 1.-exp((-5.0*max(d+0.25, 0.))));
    color = mix(color, color*0.0, 1.-exp((-2.5*max(d+0.1, 0.))));
    
    return mix(color, bgColor, smoothstep(0., 2e-2, d));
}

vec3 DrawCandy3(vec2 p, vec3 bgColor)
{
    vec2 q = p-vec2(-0.15, +0.35);
    q = Rot(q, q.y*0.6);
    vec2 seg = dsSegment(q, vec2(0., 0.0), vec2(0.0, -0.65));
    float d = seg.x - 0.25 -seg.y*0.06;
    vec3 color = vec3(0.752, 0.047, 0.047)*0.8;
    
    vec3 cubeTex = textureCube(iChannel2, normalize(vec3(p.xy,1.)) *RotZ(4.8) ).rgb;
    color *= 1.+cubeTex.r*0.30;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(-0.20, 0.35))*vec2(1.8, 1.2))), 0.1) ))*2.9;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(0.20, -0.3))*vec2(1.7, 1.2))), 0.11) ))*2.5;
    
    color = mix(color, color*0.0, 1.-exp((-2.5*max(d+0.2, 0.))));
    
    return mix(color, bgColor, smoothstep(0., 2e-2, d));
}

vec3 DrawCandy4(vec2 p, vec3 bgColor)
{
    vec2 q = p-vec2(-0.0, +0.0);
    q.x *= 1./(1.+abs(q.y)*0.25);
    float d = dsBox(q, vec2(0.20, 0.30), 0.25);
    vec3 color = vec3(0.345, 0.882, 0.254)*0.6;
    color = mix(color*0.4, color, smoothstep(-0.7, 0.3, p.y));
    
    vec3 cubeTex = textureCube(iChannel2, normalize(vec3(p.xy,1.)) *RotZ(4.8) ).rgb;
    color *= 1.+cubeTex.r*0.30;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(-0.15, 0.15))*vec2(0.5, 1.2))), 0.12) ))*2.5;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(0.25, -0.1))*vec2(0.9, 1.2))), 0.11) ))*2.5;
    
    color = mix(color, color*0.0, 1.-exp((-2.5*max(d+0.1, 0.))));
    
    return mix(color, bgColor, smoothstep(0., 2e-2, d));
}

/*vec3 DrawCandy5(vec2 p, vec3 bgColor)
{
    vec2 q = p-vec2(-0.0, +0.0);
    q.x *= 1./(1.+abs(q.y)*0.25);
    float d = length(q*vec2(1., 0.7)*0.60)- 0.25;
    vec3 color = vec3(0.968, 0.698, 0.031);
    color = mix(color, vec3(0.968, 0.698, 0.031)*0.4, texture2D(iChannel1, p.xy*vec2(3.0, 1.)).r );
    
    float d2 = length(q*vec2(1., 0.7)*0.60)- 0.15;
    color = mix(vec3(0.811, 0.650, 0.247), color, smoothstep(0.0, 1.0, pow(18.*abs(d2), 1.0)));
    
    
    color = mix(color*0.4, color, smoothstep(-1.0, 0.3, p.y));
    
    vec3 cubeTex = textureCube(iChannel2, normalize(vec3(p.xy,1.)) *RotZ(4.8) ).rgb;
    color *= 1.+cubeTex.r*0.30;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(-0.24, 0.15))*vec2(1.5, 1.0))), 0.12) ))*2.5;
    color += (1.-smoothstep(0., 1., pow(abs(length((p-vec2(0.15, -0.15))*vec2(0.9, 1.2))), 0.11) ))*2.5;
    
    color = mix(color, color*0.0, 1.-exp((-2.5*max(d+0.1, 0.))));
    
    return mix(color, bgColor, smoothstep(0., 2e-2, d));
}
*/

vec3 DrawCandyExplosion(vec2 p, vec3 candyColor, vec3 bgColor, vec4 candyIdData)
{
    float t = (1.-candyIdData.w);

    if(candyIdData.w > 0.99){return candyColor;}
    for(float i=0.; i<12.;++i)
    {
        float size = max(hash(10.-i)*1.5, 0.1);
        vec2 vel = normalize(vec2(hash(i), hash(5.+6.*i)))*(hash((i+4.)*6.)*2.-1.)*1.5;
        vec2 pos = vel*pow(t, 0.3);
        
        vec2 q = p-pos;
        candyColor += step(1e-3, t)*candyColor*(1.-smoothstep(0., 1., length(q)/size ));
    }
    
    candyColor = mix(bgColor, candyColor, candyIdData.w);
    
    float size = 1.*t;
    float d = length(p)-size;
    candyColor += step(1e-3, t)*sin(PI*pow(t, 0.5))*candyColor* (1.-smoothstep(0.2, 1., abs(d)/0.4));
    return candyColor;
}

vec3 DrawCandy(vec2 p, vec3 bgColor, vec4 candyIdData)
{
    p *= 1.2;
    vec3 candyColor;
    if(candyIdData.z < 0.5) { candyColor = DrawCandy0(p, bgColor);}
    else if(candyIdData.z < 1.5) { candyColor = DrawCandy1(p, bgColor);}
    else if(candyIdData.z < 2.5) { candyColor = DrawCandy2(p, bgColor);}
    else if(candyIdData.z < 3.5) { candyColor = DrawCandy3(p, bgColor);}
    else /*if(candyIdData.z < 4.5)*/ { candyColor = DrawCandy4(p, bgColor);}
    //else { candyColor  = DrawCandy5(p, bgColor); }
    
    candyColor = DrawCandyExplosion(p, candyColor, bgColor, candyIdData);
    
    return candyColor;
}

vec2 GetCellPos(vec2 cellId)
{
    return gridPos + cellId*1.2;
}

float LerpEaseOutBounce(float t, float b, float c, float d)
{
//  Reference: https://github.com/gdsmith/jquery.easing/blob/master/jquery.easing.js
    if ((t/=d) < (1./2.75)) {
        return c*(7.5625*t*t) + b;
    } else if (t < (2./2.75)) {
        return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
    } else if (t < (2.5/2.75)) {
        return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
    } else {
        return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
    }
}

vec3 DrawCellBg(vec2 p, vec2 cellId, vec3 bgColor)
{
    vec4 selected0 = Load(mSelected0, iChannel0, iChannelResolution[0].xy);
    vec4 selected1 = Load(mSelected1, iChannel0, iChannelResolution[0].xy);
    
    vec3 color = vec3(0.160, 0.333, 0.498);
    color = mix(color, vec3(0.172, 0.729, 0.188), step(0.5, IsSameCell(selected0.xy, cellId.xy)));
    color = mix(color, vec3(0.729, 0.325, 0.172), step(0.5, IsSameCell(selected1.xy, cellId.xy)));
    
    vec2 q = p-GetCellPos(cellId.xy);
    float d = dsCell(q);
    color = mix(color, bgColor, min(0.5+step(0., d), 1.));
   
    return color;
}

vec3 DrawCell(vec2 p, vec2 cellId, vec3 bgColor)
{
    vec4 cellIdData = Load(mCellId.xy+cellId, iChannel0, iChannelResolution[0].xy);
    vec4 cellIdPosData = Load(mCellPos.xy+cellId, iChannel0, iChannelResolution[0].xy);
    
    vec2 q = p-cellIdData.xy;
    return DrawCandy(q, bgColor, cellIdData);
}

vec3 DrawClouds(vec2 p, vec3 color)
{
    // Clouds
    p = Rot(p, 3.14159);
    vec2 q = p;
    vec2 q2 = q;
    q2.x *= 0.2; q2 *= 2.;
    q2.y -= 1.2*pow(abs( sin(q2.x*6.)), 0.5)*1.*step(0., q2.y);
    q2.y += cos(q2.x*4.)*0.2;
    float d = length(max(abs(q2)-vec2(1., 1.0), 0.))-0.1;
    d = max(d, -q.y+0.5);
    
    q -= vec2(0., 1.0);
    q2 = q;
    q2.x *= 0.2; q2 *= 2.;
    q2.y += 1.3*pow(abs( cos(q2.x*5.5)), 0.5)*1.*step(q2.y, 0.);
    q2.y -= cos(q2.x*4.)*0.2;
    float d2 = length(max(abs(q2)-vec2(1., 1.0), 0.))-0.1;
    d2 = max(d2, q.y+0.5);
    d = min(d, d2);
    
    q2 = q-vec2(1.60, -0.4);
    d = max(d, min(q2.x,(length(q2)-1.0))  );
    q2 = q-vec2(-1.60, -0.4);
    d = max(d, min(-q2.x,(length(q2)-1.0))  );
    
    vec3 texColor = texture2D(iChannel1, vec2(q2.xy)*vec2(0.2, 0.1)).rgb;
    vec3 cloudColor = mix(vec3(0.866, 0.866, 0.811), vec3(0.607, 0.607, 0.372), smoothstep(0.3, 1.,texColor.r));
    color = mix(cloudColor, color, smoothstep(0., 0.05, d));
    
    // String Hole
    q2 = q-vec2(0., -1.35);
    q2.y *= 0.9;
    d = length(q2)-0.3;
    d2 = length(q2)-0.15;
    d = max(d, -d2);
    color = mix(cloudColor, color, smoothstep(0., 0.05, d));
    
    // Hole
    q2 -= vec2(0., -3.6);
    vec3 stringColor = mix(vec3(0.505, 0.376, 0.031), vec3(0.807, 0.596, 0.035), abs(q2.x)*20.);
    d = length(max(abs(q2)-vec2(0.01, 3.5), 0.))-0.03;
    color = mix(stringColor, color, smoothstep(0., 0.05, d));
    
    return color;
}

vec3 DrawBg(vec2 p)
{
    vec3 color = mix(vec3(0.850, 0.882, 0.905), vec3(0.050, 0.439, 0.772), pow(abs(p.y-3.)*0.15, 1.8));
    
    // Rainbow
    vec2 q = p + vec2(0., -10.)*(1.-smoothstep(0., 1., gT-0.8));
    q -= vec2(2., 5.);
    q = Rot(q, 0.5);
    q.x *= 0.8;
    
    float d = abs(length(q+vec2(sin(atan(q.y,q.x)*7.)*0.03))-3.1)-1.30;
    color = mix(vec3(0.803, 0.807, 0.631), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-4.)-0.15;
    color = mix(vec3(0.854, 0.603, 0.525), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-3.65)-0.15;
    color = mix(vec3(0.854, 0.847, 0.525), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-3.30)-0.15;
    color = mix(vec3(0.678, 0.854, 0.525), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-2.95)-0.15;
    color = mix(vec3(0.525, 0.854, 0.819), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-2.55)-0.15;
    color = mix(vec3(0.764, 0.525, 0.854), color, smoothstep(0., 0.1, d));
    d = abs(length(q)-2.16)-0.15;
    color = mix(vec3(0.443, 0.415, 0.941), color, smoothstep(0., 0.1, d));
    
    // Mountains
    q = p + vec2(0., 10.)*(1.-smoothstep(0., 1.5, gT));
    vec3 mountainCol = mix(vec3(0.678, 0.768, 0.270), vec3(0.4, 0.592, 0.266), smoothstep(4., 16., q.x));
    color = mix(mountainCol, color, smoothstep(0., 0.1, (q.y-3.5)+sin(-3.25+q.x*0.5)*3.6*sin(.0+q.x*0.08)*1.+sin(q.x*1.5)*0.15));
    mountainCol = mix(vec3(0.286, 0.470, 0.231), vec3(0.529, 0.662, 0.376), smoothstep(0., 6., p.x));
    color = mix(mountainCol, color, smoothstep(0., 0.1, (q.y-1.5)+sin(-1.+q.x*0.17)*3.6+sin(q.x*1.5)*0.1));
    
    color = DrawClouds(p-vec2(9.5, 5.5+cos(gT*0.25)*1.) + vec2(0., -10.)*(1.-smoothstep(0., 1.5, gT-1.4)), color);
    color = DrawClouds(p-vec2(3.0, 6.0+sin(-1.4+gT*0.25)) + vec2(0., -10.)*(1.-smoothstep(0., 1.5, gT-1.9)), color);
    
    return color;
}

float SampleDigit(const in float n, const in vec2 vUV)
{
    if( abs(vUV.x-0.5)>0.5 || abs(vUV.y-0.5)>0.5 ) return 0.0;

    // reference P_Malin - https://www.shadertoy.com/view/4sf3RN
    float data = 0.0;
         if(n < 0.5) data = 7.0 + 5.0*16.0 + 5.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 1.5) data = 2.0 + 2.0*16.0 + 2.0*256.0 + 2.0*4096.0 + 2.0*65536.0;
    else if(n < 2.5) data = 7.0 + 1.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 3.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 4.5) data = 4.0 + 7.0*16.0 + 5.0*256.0 + 1.0*4096.0 + 1.0*65536.0;
    else if(n < 5.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 6.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 1.0*4096.0 + 7.0*65536.0;
    else if(n < 7.5) data = 4.0 + 4.0*16.0 + 4.0*256.0 + 4.0*4096.0 + 7.0*65536.0;
    else if(n < 8.5) data = 7.0 + 5.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    else if(n < 9.5) data = 7.0 + 4.0*16.0 + 7.0*256.0 + 5.0*4096.0 + 7.0*65536.0;
    
    vec2 vPixel = floor(vUV * vec2(4.0, 5.0));
    float fIndex = vPixel.x + (vPixel.y * 4.0);
    
    return mod(floor(data / pow(2.0, fIndex)), 2.0);
}

float PrintInt( in vec2 uv, in float value )
{
    float res = 0.0;
    float maxDigits = 1.0+ceil(.01+log2(value)/log2(10.0));
    float digitID = floor(uv.x);
    if( digitID>0.0 && digitID<maxDigits )
    {
        float digitVa = mod( floor( value/pow(10.0,maxDigits-1.0-digitID) ), 10.0 );
        res = SampleDigit( digitVa, vec2(fract(uv.x), uv.y) );
    }

    return res;
}

vec3 DrawUIBox(vec2 q, vec3 color)
{
    vec3 scoreCol = vec3(0.890, 0.588, 0.839);
    scoreCol = mix(scoreCol, scoreCol*1.5, smoothstep(-2., 2., q.x));
    float d = dsBox(q, vec2(1.0, 0.35), 0.2);
    color = mix(mix(scoreCol, color, 0.4), color, smoothstep(0., 0.01, d));
    vec3 frameColor = mix(vec3(0.917, 0.062, 0.768), vec3(0.917, 0.062, 0.768)*0.8, step(0.5, fract(Rot(q*2., -0.7).x)));
    frameColor += vec3(1.)*pow(max((1.-abs(q.x)), 0.), 2.5)*0.4;
    frameColor *= exp(-2.8*max(d+0.1, 0.));
    return mix(frameColor, color, smoothstep(0., 0.01, abs(d)-0.06 ));
}

vec3 DrawScore(vec2 p, vec3 color)
{
    vec2 q = p - vec2(1.8, 1.5) + vec2(10., 0.)*(1.-smoothstep(0., 1., gT-3.45));
    color = DrawUIBox(q*vec2(0.8, 1.), color);
    
    float d = PrintInt(q*3.0-vec2(-4.5, -1.0), gState.z*25.);
    vec3 lettersColor = vec3(0.188, 0.164, 0.133)*0.2;
    lettersColor = mix(lettersColor, vec3(0.396, 0.376, 0.345), smoothstep(-0.3, 0.4, q.y));
    color = mix(lettersColor, color, 1.-smoothstep(-0.0, 0.001, d));
    
    q -= vec2(-1.2, 0.35); q*=0.25;
    caret.x = count = 0.;
    d = S(r(q)); add(); d += C(r(q)); add(); d += O(r(q));  add(); d += R(r(q));  add(); d += E(r(q)); 
    color = mix(color, lettersColor*0.1, smoothstep(0.4, 1.0, d));
    color *= smoothstep(0., 0.005, length(q-vec2(0.27, 0.))-0.008);
    color *= smoothstep(0., 0.005, length(q-vec2(0.27, -0.035))-0.008);
    
    return color;
}

vec3 DrawMovements(vec2 p, vec3 color)
{
    vec2 q = p - vec2(1.5, 3.0) + vec2(10., 0.)*(1.-smoothstep(0., 1., gT-3.3));
    color = DrawUIBox(q, color);
    
    float d = PrintInt(q*3.0-vec2(-4.0, -1.0), gState.y);
    vec3 lettersColor = vec3(0.188, 0.164, 0.133)*0.2;
    lettersColor = mix(lettersColor, vec3(0.396, 0.376, 0.345), smoothstep(-0.3, 0.4, q.y));
    color = mix(lettersColor, color, 1.-smoothstep(-0.0, 0.001, d));
    
    q -= vec2(-1.0, 0.35); q*=0.25;
    caret.x = count = 0.;
    d = M(r(q)); add(); d += O(r(q));  add(); d += V(r(q));  add(); d += E(r(q));  add(); d += S(r(q)); 
    color = mix(color, lettersColor*0.1, smoothstep(0.4, 1.0, d));
    color *= smoothstep(0., 0.005, length(q-vec2(0.27, 0.))-0.008);
    color *= smoothstep(0., 0.005, length(q-vec2(0.27, -0.035))-0.008);
    
    return color;
}

vec3 DrawGoal(vec2 p, vec3 color)
{
    vec2 q = p - vec2(1.8, 9.0) + vec2(10., 0.)*(1.-smoothstep(0., 1., gT-3.0));
    color = DrawUIBox(q*vec2(0.8, 0.8), color);
    
    float d = PrintInt(q*3.0-vec2(-4.0, -1.5), gState.w*25.);
    vec3 lettersColor = vec3(0.188, 0.164, 0.133)*0.2;
    lettersColor = mix(lettersColor, vec3(0.396, 0.376, 0.345), smoothstep(-0.3, 0.4, q.y));
    color = mix(lettersColor, color, 1.-smoothstep(-0.0, 0.001, d));
    
    q -= vec2(-1.0, 0.35); q*=vec2(0.2, 0.25);
    caret.x = count = 0.;
    d = G(r(q)); add(); d += O(r(q));  add(); d += A(r(q));  add(); d += L(r(q));
    color = mix(color, lettersColor*0.1, smoothstep(0.5, 1.0, d));
    color *= smoothstep(0., 0.005, length(q-vec2(0.20, 0.))-0.008);
    color *= smoothstep(0., 0.005, length(q-vec2(0.20, -0.035))-0.008);
    
    return color;
}

vec3 DrawWinLose(vec2 p, vec3 color)
{
    if(gState.x < 6.5) { return color; }
    color *= 0.65;
    
    vec2 hGridSize = vec2(xCells, yCells)*1.2;
    vec2 q = p - gridPos-hGridSize*0.5+0.6;
    color = DrawUIBox(q*vec2(0.05, 0.7), color);
    
    vec3 lettersColor = mix(vec3(0.203, 0.372, 0.917)*0.8, vec3(0.203, 0.372, 0.917), smoothstep(-0.6, 0.4, q.y));
    lettersColor = mix(lettersColor, mix(vec3(0.788, 0.133, 0.278)*0.8, vec3(0.788, 0.133, 0.278), smoothstep(-0.6, 0.4, q.y)), step(gState.z+0.5, gState.w));
    
    caret.x = count = 0.;
    q *= 1.+sin(gT*4.)*0.1;
    q -= vec2(-3., 0.);
    q*= 0.1;
    
    caret.x = count = 0.;
    float d = M(r(q)); add(); d += A(r(q));  add(); d += R(r(q));  add(); d += V(r(q));  add(); d += E(r(q));  add(); d += L(r(q));  add(); d += O(r(q));  add(); d += U(r(q));  add(); d += S(r(q));
    float dWin = d;
    caret.x = count = 0.;
    d = T(r(q)); add(); d += R(r(q));  add(); d += Y(r(q));  space(); d += A(r(q));  add(); d += G(r(q));  add(); d += A(r(q));  add(); d += I(r(q));  add(); d += N(r(q)); // add(); d += S(r(q));
    float dLose = d;
    d = mix(dWin, dLose, step(gState.z+0.5, gState.w));
    color = mix(color, lettersColor, smoothstep(0.5, 1.0, d));
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    gT = iGlobalTime;
    vec2 uv = 10.*(fragCoord.xy / iResolution.y);
    gUv = uv;
    
    gState = Load(mState, iChannel0, iChannelResolution[0].xy);
    
    vec3 color = DrawBg(uv);
    vec2 cell = floor((uv-gridPos+0.6)/1.2);
    if(cell.x >= 0.)
    {
        vec3 bgColor = DrawCellBg(uv, cell, color);
        color = mix(color, bgColor, smoothstep(0., 0.5, gT-4.5));
        color = DrawCell(uv, cell+vec2(-1., 0.), color);
        for(float y=0.; y<yCells-0.5;++y)
        {
            vec2 currCell = vec2(cell.x, y);
            color = DrawCell(uv, currCell, color);
        }
        color = DrawCell(uv, cell+vec2(+1., 0.), color);
    }
    
    color = DrawScore(uv, color);
    color = DrawMovements(uv, color);
    color = DrawGoal(uv, color);
    color = DrawWinLose(uv, color);
    
	fragColor = vec4(pow(color, vec3(1.)),1.0)*smoothstep(0., 1., pow(gT, 0.8));
}
