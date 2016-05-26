// Shader downloaded from https://www.shadertoy.com/view/4l2XWw
// written by shadertoy user shaderology
//
// Name: phyllotaxis 2D
// Description: infinite zoom into 2d pattern of romanesco broccoli. 
#define PI 3.14159265359
#define PI2 6.28318530718
#define SPIRALS 7.
#define LEV 5
//#define CELLROTATION

vec2 rotate2D(vec2 p, float t)
{
    mat2 m = mat2( cos(t), sin(t), -sin(t), cos(t) );
    return m * p;
}

vec4 phyllotaxis( vec2 uv, float offset )
{

    // initiate
    float i_s = 1.;
    float r_s = 1.;
    float t_s = 0.;
    float occ = 1.;
    float dsp = 0.5;
    vec3 n = vec3(0., 0., 1.);

    for( int i=1; i<LEV; i++ )
    {
      float zoom = i == 1 ? offset : 0.;
        
      // Log-Polar coordinates from UVs generated in previous iteration
      float r = length(uv);
      float lr = log(r);
      float theta = atan( uv.x, uv.y);
        
      // Logarithmic spiral coordinates
      vec2 spiral = vec2( theta - lr, theta + lr - zoom)/PI;
      
      // Phyllotaxis florets - main pattern
      // Log-polar fractions back to cartesian cells
      uv = fract( spiral * SPIRALS ) -  0.5;

      // Align new theta's using parent theta. Not very accurate as there is some distortion.
      // Also had to offset with a mysterious constant of 0.36 (golden fraction?)
      #ifdef CELLROTATION
        // Experimental part. Flatten the spiral coordinates to cells
        // and use uniform value of an entire cell to offset theta
        float cellr = floor(spiral.x * SPIRALS) - floor(spiral.y * SPIRALS);
        float cellt = floor(spiral.x * SPIRALS ) + floor(spiral.y * SPIRALS );
        vec2 uvcell = vec2( cellr, cellt / (SPIRALS / 1.55) );
        //uv = rotate2D( uv, -(theta+0.72)  ); // + 2x golden fraction?
        uv = rotate2D( uv,  -(uvcell.y) );
        t_s = theta;
      #else
        // cheap offset with golden(?) constant.
        // thetas are aligned but slightly distorted
        t_s = theta + t_s + 0.36;
      #endif
      
      // smooth cone tips
      float taper = smoothstep(0.0, 0.2, r) * (1. - smoothstep(0.5, 0.8, r));
        
      // build and layer the normals and multiply with floret radius
      n += mix( vec3(0., 0., 1.0), vec3( sin(t_s), cos(t_s), 0. ),  pow(taper, 0.5)) * r_s;        
  
      // comp occlusion.
      occ *= 1.-pow(r, 2.);
        
      // displacement is not used in this demo
      // dsp += (1.-r) * i_s * r_s;
      
      // store iteration multiplier for displacements
      i_s = 1. / float(i);
        
      // combine and store floret radius. next iteration we use it to
      // multiply displacements and normals
      r_s *= sqrt(r);
    }    
    
   return vec4( normalize(n), occ ); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y *= iResolution.y / iResolution.x;

	vec2 m = iMouse.xy / iResolution.xy -.5;
	m.x*= iResolution.x/ iResolution.y;
	m *= 20.0;
	
    // VARIABLES
    float t = fract(iGlobalTime * .05) * PI;
    vec3 sp = vec3(uv - 0.4, 0.);
    vec3 lp = iMouse.z < .5 ? vec3(sin(t*5.)*10.,cos(t*8.)*10., -1.5) : vec3(m, -2.);
    vec3 ld = normalize(lp - sp);
    vec3 ro = vec3(0, 0, -0.5);
    vec3 rd = normalize(ro-sp);

    // THE PATTERN
    vec4 brocc = phyllotaxis(sp.xy, t);
    vec3 n = vec3( brocc.xy, -brocc.z);
    float occ = brocc.w;
    
    // COLORS
    vec3 base = vec3(0.38, 0.52, 0.26);
    vec3 diff = vec3(0.6, 0.6, 0.5);
    vec3 spec = diff;
    vec3 back = vec3(0.1, 0.01, 1.5);
    vec3 ambi = vec3(0.25, 0.44, 0.23);
    
    // SHADE
	diff *= max(dot(n, ld), 0.);
    back *= max(dot(n, vec3(0.4, -0.4, 0.2)), 0.);
    spec *= pow(max(dot( reflect(-ld, n), rd), 0.), 7.); 
    ambi *= occ;

    // COMP
    vec3 col = base * ambi;
    col += base * diff;
    col += spec * 0.2;
    col += base * back;

    // POST
    col *= pow(20.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y),0.5) +  0.1;
    col = sqrt(col);
    
	fragColor = vec4( col, 1.);
}