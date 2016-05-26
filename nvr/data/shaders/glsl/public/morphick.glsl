// Shader downloaded from https://www.shadertoy.com/view/ltXSWf
// written by shadertoy user vizionary
//
// Name: Morphick
// Description: Inspiration from following iq's articles and shaders for years and most recently, after watching the Revision 2015 Live Coding event videos ... AMAZING coding guys !!           click-n-drag to slide time
//#version 430 core
/*
  Morphick Logo - created by vizionary - Aug 2015
  License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

  Huge thank you and greetz to: iq ,mu6k, XT95, Kali, otaviogood, TekF, reinder, 
                                Dave_Hoskins, gargaj, frankenburgh, Kabuto !!!

  This was inspired by reading iq's articles for years and most recently, by watching 
  the Revision 2015 Live Coding event videos ... AMAZING !!

  This is the first public sample of my gfx tinkering in many, many years
  ...quite shy, i am...hope you enjoy !
  -viz
*/

float time = iGlobalTime + 300.0 + iMouse.x * 0.3;

//#define ANIMATE_LAYER_DEPTH  // thought this would look cool, but aesthetically, ruins the distinct layering effect :/
//#define MOAR_LAYERS          // medium detail
//#define EVEN_MOAR_LAYERS     // high detail (only more layers added for now)
//#define SOFT_SHADOW          // disabled at the moment, need to debug :/

// tweak if you want :)
const float camSpeed = 0.11;
const float camRad = 3.5;
const float sunRad = 20.0;
const float sunSpeed = 0.42;
const float piOver2 = 1.5708;
const vec3  columnSpacing = vec3( 0.5, 0.0, 0.0 );
const float latticeLineWidth = 0.12;
const float latticeLayerSpacing = 0.075;
const float latticeLayersAngle = 9.4248;
const float latticeLayersSpeed = 0.0125;
const float latticeMergeThreshold = 0.5;
const float latticeLayersMergeThreshold = 0.025;

// smooth minimum distance ftw - thanks iq!
float smin_poly( in float a, in float b, in float k)
{
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k * h * (1.0-h);
}

vec3 rotateX( in vec3 v, float rad )
{
  float cs = cos(rad);
  float ss = sin(rad);
  return vec3(v.x, cs * v.y + ss * v.z, -ss * v.y + cs * v.z);
}

vec3 rotateY( in vec3 v, float rad )
{
  float cs = cos(rad);
  float ss = sin(rad);
  return vec3(cs * v.x - ss * v.z, v.y, ss * v.x + cs * v.z);
}

float boxShape( in vec3 pos, float b)
{
  vec3 d = abs(pos) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

vec2 morphickLogoColumn( in vec3 pos, in float materialOffset)
{
   // inspired by otaviogood's Disc model in Gimbal Mechanics
   // let's start with a unit box 
   // also using the vec2 return technique to return material id's from within distance calc  - thanks iq!
  vec2  d  = vec2(boxShape( pos, 1.0), 503.0);
  
  vec3 trans = vec3(0.5, -1.7, 1.0);
  float angle = 0.959931;
  
  // cut off the top
  vec2  dm = vec2( -boxShape( rotateX( rotateY( pos+trans, 0.7853 ), angle ), 2.0 ), 501.0 );
  if( dm.x > d.x ) d = dm;

  // and the bottom
  trans = vec3(-1.0, 1.5, -1.0);
  dm =       vec2( -boxShape( rotateX( rotateY( pos+trans, 0.7853 ), angle ), 1.0), 501.0 );
  if (dm.x > d.x ) d = dm;

  // trim the back and front
  trans = vec3(0.5, 0.0, 0.0);
  dm =       vec2( -boxShape( pos+trans, 1.1 ), 501.0 );
  if( dm.x > d.x ) d = dm;

  trans = vec3(0.0, 0.0, 0.5);
  dm =       vec2( -boxShape( pos+trans, 1.1 ), 501.0 + materialOffset );  // tweak material for front of left column in logo
  if( dm.x > d.x ) d = dm;

  return d;
}

vec2 morphickLogoShape( in vec3 pos )
{
  // composite the colums together - and specify a unique material id for the left most column
  vec2 d  = morphickLogoColumn( pos, 0.0 );
  vec2 d1 = morphickLogoColumn( pos+columnSpacing+vec3( 0.0, 0.25, 0.0 ), 0.0 );
  if( d1.x<d.x ) d = d1;
  d1 = morphickLogoColumn( pos+columnSpacing*2.0, 2.0 );
  if( d1.x<d.x ) d = d1;
  return d;
}

float latticeLineX( in vec3 pos )
{
  float d = abs( pos.x ) - latticeLineWidth; 
  return d; 
}


vec2 morphickLatticeShape( in vec3 pos, in float angle )
{
  // ahh, this was the most fun part of all :)
  // using translation and rotation on .xz plain, along with smin to blend each layer of lattice work
  angle += 0.2; // reduce linear alignments in the patterns a bit
  float dx = cos(time*0.03);  dx += sin(dx*angle*0.078);
  float dy = sin(time*0.025); dy += cos(dy*angle*0.167);
  float d =         latticeLineX( rotateY( pos+vec3(  2.0*dx, 0.0,  5.0*dy ),  angle ) );
  d = smin_poly( d, latticeLineX( rotateY( pos+vec3(  20.0*dx, 0.0, -4.0*dy ), -angle * 1.0000 ) ), latticeMergeThreshold );

  d = smin_poly( d, latticeLineX( rotateY( pos+vec3( -3.0*dx, 0.0,  4.0*dy ),  angle * 0.8400 ) ), latticeMergeThreshold );

  d = smin_poly( d, latticeLineX( rotateY( pos+vec3( -4.0*dx, 0.0,  10.0*dy ), -angle * 0.3300 ) ), latticeMergeThreshold );
  d = smin_poly( d, latticeLineX( rotateY( pos+vec3(  5.0*dx, 0.0,  3.0*dy ),  angle * 0.5000 ) ), latticeMergeThreshold );

  d = -smin_poly( -d, -( abs(pos.y)-latticeLayersMergeThreshold*latticeMergeThreshold ), latticeLayersMergeThreshold );
  return vec2(d, 10.0);
}

vec3 planeMaterial( in vec3 pos, in vec3 nor )
{
  // this was going to be something more complex
  // but simple won :)
  return vec3( 0.02 );
}

vec3 latticeMaterial( in vec3 pos, in vec3 nor )
{ 
  // more of the same - black shiny works good for this
  vec3 col = vec3(0.021, .020, .023) * 4.0;
  return col;
}

vec3 morphickLogoMaterial( in vec3 pos, in vec3 nor, in float id )
{
  float ao = sin( pos.y );  //super fakey ao :)
  vec3 col = vec3( 0.3, 0.7, 0.9 );
  if (id > 502.0)
  {
    col = vec3( 0.7, 0.2, 0.2 ); 
  }
  return col * ao;
}

float plane( in vec3 pos, in float height)
{
  return pos.y + height;
}

vec2 df( in vec3 pos )
{
  // render the back plane
  vec2 d = vec2(plane( rotateY( rotateX( -pos+vec3( 0.0, 0.0, 0.4 ), piOver2 ), piOver2 ), 0.4 ), 1.0);

  // render the logo
  vec2 d1 = morphickLogoShape( pos+vec3( 0.25, -1.1, 1.0 ) );
  if (d1.x<d.x) d = d1;

  float t = time*latticeLayersSpeed;
  float t1 = t *  1.0;  // is any of this pre-calc saving cycles in the end??  :P
  float sst1 = sin(t1) * latticeLayersAngle;
  float t2 = t *  0.75;
  float t3 = t *  0.50;
  float t4 = t *  0.25;
  float t5 = t *  0.125;

  // render the lattice layers
  // each layer is rendered with a different translation and angle offset 
  // which gives rise to nice oscillations in the lattice over time
  // change latticeLayersSpeed to adjust the overall speed of the animation
  pos = rotateX( pos, piOver2 );
  float dz = 1.0;
#ifdef ANIMATE_LAYER_DEPTH
  dz = sin(time*0.06);  dz += cos(dz*0.232);    
#endif
  d1 = morphickLatticeShape( pos+vec3( -3.0, -latticeLayerSpacing*2.0*dz, -4.0), sst1 + latticeLayersAngle * sin(t2) );
  if (d1.x<d.x) d = d1;

  d1 = morphickLatticeShape( pos+vec3(  3.0, -latticeLayerSpacing*8.0*dz, -2.0), sst1 - latticeLayersAngle * cos(t3) );
  if (d1.x<d.x) d = d1;

  d1 = morphickLatticeShape( pos+vec3( -6.0, -latticeLayerSpacing*3.0*dz,  1.0), sst1 + latticeLayersAngle * sin(t4) );
  if (d1.x<d.x) d = d1;

  d1 = morphickLatticeShape( pos+vec3(  6.0, -latticeLayerSpacing*6.0*dz,  3.0), sst1 - latticeLayersAngle * cos(t5) );
  if (d1.x<d.x) d = d1;

  d1 = morphickLatticeShape( pos+vec3( -1.0, -latticeLayerSpacing*5.0*dz,  1.0), sst1 + latticeLayersAngle * sin(t5) );
  if (d1.x<d.x) d = d1;

#ifdef MOAR_LAYERS
  d1 = morphickLatticeShape( pos+vec3(  9.0, -latticeLayerSpacing*4.0*dz, -4.0), sst1 - latticeLayersAngle * cos(t2) );
  if (d1.x<d.x) d = d1;

  d1 = morphickLatticeShape( pos+vec3(-15.0, -latticeLayerSpacing*9.9*dz,  4.0), sst1 + latticeLayersAngle * sin(t4) );
  if (d1.x<d.x) d = d1;
#endif     
#ifdef EVEN_MOAR_LAYERS
 // if you have the horsepower, toss a few more layers in for good measure :)    
  d1 = morphickLatticeShape( pos+vec3( 15.0, -latticeLayerSpacing*7.0, -4.0), sst1 + latticeLayersAngle * cos(t1) );
  if (d1.x<d.x) d = d1;
    
  d1 = morphickLatticeShape( pos+vec3(  7.5, -latticeLayerSpacing*9.0,  7.5), sst1 - latticeLayersAngle * sin(t3) );
  if (d1.x<d.x) d = d1;
#endif
  return d;
}

vec3 nf( in vec3 pos )
{
  vec2 e = vec2( 0.0, 0.001 );
  return normalize(
    vec3(
      df( pos+e.yxx ).x - df( pos-e.yxx ).x,
      df( pos+e.xyx ).x - df( pos-e.xyx ).x,
      df( pos+e.xxy ).x - df( pos-e.xxy ).x
    )
  );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
  // thanks iq - love your video tutorials - please make more :)
  float t = 0.0;
  for( float steps=0.0; steps<8.0; steps+=1.0/8.0 )
  {
    vec2 d = df( ro + rd * t );
    if ( d.x < 0.001 ) return vec3(t, d.y, steps);
    t += d.x;
  }
  return vec3( 0.0, 0.0, 0.0 );
}

// thanks iq - (apple tut - yay!)
float shadow( in vec3 ro, in vec3 rd )
{
  float res = 1.0;
  float t = 0.002;
    
  // was going for soft shadow, but when set k down to say 16 or 32,
  // then artifacts that look like shadow hits from the negative boxes
  // used to carve up the logo
  #ifdef SOFT_SHADOW
  float k = 16.0;
  for( float steps=0.0; steps<10.0; steps+=1.0/10.0 )   
  #else
  float k = 64.0;      
  for( float steps=0.0; steps<4.0; steps+=1.0/4.0 )
  #endif
  {
    float h = df( ro+t*rd ).x;
    if( h<0.001) return 0.0;
    res = min( res, k*h/t);
    t += h;
  }
  return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
  uv -= 0.5;
  uv /= vec2(iResolution.y / iResolution.x, 1);

  // following iq's model here in terms of the rt/maths
  // just using a simple auto orbiting cam tweaked to give some nice perspectives
  vec3 ro = vec3(0.0, 0.0, -8.0 );
  ro += vec3(sin(time*camSpeed)*camRad, 0.0+sin(time*camSpeed*0.5)*1.5, -cos(time*camSpeed)*camRad);
  vec3 target = vec3(0.0, 1.5, 0.0);
  vec3 ww = normalize( target - ro );
  vec3 up = normalize( vec3( 0.0, 1.0, 0.0) );
  vec3 uu = normalize( cross( up, ww ) );
  vec3 vv = normalize( cross( ww, uu ) );
  vec3 rd = normalize( uv.x*uu + uv.y*vv + 1.0*ww );  

  // still not quite happy with the lighting...but this will do for now
  vec3 sunPos = vec3(0.0, 0.0, -100) + vec3(-sunRad+sin(time*sunSpeed)*sunRad, sunRad+sin(time*sunSpeed*0.5)*sunRad*0.5, -sunRad+cos(time*sunSpeed)*sunRad);
  vec3 sunlight  = -normalize( target - sunPos );

  vec3 col = vec3( .0 );
  vec3 t = intersect( ro, rd);

  // only process materials if we have an intersection    
  if (t.x > 0.0)
  {
    vec3 pos = ro + rd * t.x;
    vec3 nor = nf( pos );
	vec3 ref = reflect( rd, nor );

    // lighting coeffs
    float dif = max( 0.0, dot( nor, sunlight ) );
    float spe = pow( clamp( dot( sunlight, ref ), 0.0, 1.0 ), 2.0 );
    float sha = clamp( shadow( pos, sunlight ), 0.0, 1.0 );
    float rim = pow( clamp( 1.0+dot( nor, rd ), 0.0, 1.0 ), 2.0 );

    float con = 0.5;
    float amb = 0.5;

    col  = con * vec3(0.1, 0.1, 0.1);
    col += amb * vec3(0.1, 0.1, 0.1);

    col = col*0.3 + 0.7*sqrt(col);
    col *= 0.5;

    col += dif * vec3( 1.00, 0.98, 0.86 ) * sha;

    // using t.y for material "id"
    if (t.y > 0.0 && t.y < 2.0) 
    {
      col *= planeMaterial( pos, nor );
    }

    if (t.y > 9.0 && t.y < 11.0)
    {
      col *= latticeMaterial( pos, nor );
    }

    if (t.y > 500.0)
    {
      col *= morphickLogoMaterial( pos, nor, t.y );
    }

    col += 0.25*rim*amb;
    col += 0.55*spe*amb*sha;
    col = pow(col, vec3(1.35));
}

  fragColor = vec4(col, 1.0);
}