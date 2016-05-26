// Shader downloaded from https://www.shadertoy.com/view/XlfGzB
// written by shadertoy user GrosPoulet
//
// Name: Attack of the Smarties
// Description: Shadertoy rocks :-)
// Variation on Ford's Circles stuff: http://nrich.maths.org/6594
// Inspired by Sarconix: https://www.shadertoy.com/view/4dsXWs

////////////////////////////// defines
// Diameter of biggest circle
#define DIAMETER 100.0
// Nb of iterations = nb of circles of decreasing size to build
#define ITERATIONS 50
// Time in second(s) to zoom in or out
#define ZOOM_TIME 10.0
// Heightmap coef [0.0 100.0]
#define HEIGHT_COEF 4.0
// Light direction
#define LIGHT_DIR vec3(1.0, 1.0, 1.0) 
// Ambiant lighting
#define LIGHT_AMBIANT vec3(0.1, 0.1, 0.1)
// Mix between original texture/procedural circles [0.0 1.0]
#define MIX_FACTOR 0.5
// Point of view
#define EYE vec3(0.57735, 0.57735, 0.57735)
// Strength of specular reflection [0.0 1.0]
#define SPEC_FACTOR 0.45

#define pi 3.1415926535897932384626433832795
#define hfpi 1.5707963267948966192313216916398
#define PI pi
#define HFPI hfpi

////////////////////////////// methods
// Most important method: Ford

float AnimateDiameter()
{
    float i = floor(iGlobalTime / ZOOM_TIME);
    float r = (iGlobalTime - ZOOM_TIME * i) / ZOOM_TIME;
    float sinr = pow(sin(HFPI * r), 2.0);
    float k = ( mod(i, 2.0) == 0.0 ? sinr : 1.0 - sinr );
 	return max(k*DIAMETER, 1.0);
}

// Compute normal at position pos, as if we were on an half-sphere with center (0,0)
vec3 ComputeNormal(vec2 pos, float radius)
{
    // Determine the distance to the center of the circle.
	float d = length(pos);
	float h = sqrt(radius*radius - d*d);
	return (normalize(vec3(pos.x,pos.y,HEIGHT_COEF*h)));
}

vec3 Ford(vec2 posSample)
{   
    float diameter = AnimateDiameter();
    float radius = diameter / 2.0;
    
    vec2 screenPos = posSample*iResolution.xy - (iResolution.xy / 2.0);
    
    //position of sample relative to circle: (0,0) = center
	vec2 pos = vec2(0.0);
    
    bool inside = false; //true iff sample is in a circle
	float rSmall = 0.0;
    
    // Build biggest circles of radius: r0
	float r0 = radius;
	pos = mod(screenPos, vec2(diameter, diameter)) - vec2(r0, r0);
	if (length(pos) < r0)
	{
		inside = true;
		rSmall = r0;
	}
    
    // Build smaller circles surrounded by 4 big circles
    float r1 = 0.0;
	vec2 mod1 = vec2(0.0);
	if (!inside)
	{
        mod1 = mod(screenPos + vec2(r0, r0), vec2(diameter, diameter)) - vec2(r0, r0);
		r1 = (sqrt(2.0) - 1.0)*r0;
		pos = mod1;
		if (length(pos) < r1)
		{
			inside = true;
			rSmall = r1;
		}
	}
    
    // Iterations - begin
	// We build circles smaller at each iteration
	// radius r[n] of nth circle is given by:
	//
	//            (r[0] - r[1] - 2*r[2] - ... - 2*r[n-1])^2      
	// r[n] = ----------------------------------------------------
	//         2 * (r[0] + r[0] - r[1] - 2*r[2] - ... - 2*r[n-1])
	//
	// 
	
	if (!inside)
	{
		float rBig = 0.0;
		float distLeft = r0 - r1; //distance to 2 big circles point-of-contact
		float r = r1; //radius of current circle
		
		for (int n=0; n<ITERATIONS; n++)
		{		
			if (!inside)
			{
				rSmall = (distLeft - 2.0*rBig)*(distLeft - 2.0*rBig)/(2.0*(r0 + distLeft - 2.0*rBig));	
			
				//West
				pos = mod1 + vec2(rBig + rSmall + r, 0.0);
				if (length(pos) < rSmall)
				{
					inside = true;
				}
				if (!inside)
				{
					//East
					pos = mod1 - vec2(rBig + rSmall + r, 0.0);
					if (length(pos) < rSmall)
					{
						inside = true;
					}	
					if (!inside)
					{
						//North
						pos = mod1 - vec2(0.0, rBig + rSmall + r);
						if (length(pos) < rSmall)
						{
							inside = true;
						}
						if (!inside)
						{
							//South
							pos = mod1 + vec2(0.0, rBig + rSmall + r);
							if (length(pos) < rSmall)
							{
								inside = true;
							}
						}
					}
				}
				
				//updates for next iteration
				r = r + rBig + rSmall;
				distLeft = distLeft - 2.0*rBig;
				rBig = rSmall;				
			}
		}
	}
	// Iterations - end
    
	// Now we're done with building circles, we give them some 3d look & feel	
        
    ///////////////////////// post-production
    
    //heightmap
    vec3 normal = vec3(0.57735);
    vec2 centerC = vec2(0.0);
    float distance2center = radius;
    if (inside)
	{
		centerC = posSample - pos/iResolution.xy;
		distance2center = length(pos) + r0;
		normal = ComputeNormal(pos, rSmall);
	}
    
    //sample texture using coordinates of circle's center
    // NOTE: Use a large negative bias to effectively disable mipmapping, which would otherwise lead
    // to sampling artifacts where the UVs change abruptly at the pixelated block boundaries.
    centerC.y = 1.0 - centerC.y; //upside-down correction
	vec3 colTex = texture2D(iChannel0, centerC, -32.0).rgb;        
	
	vec3 light = normalize(LIGHT_DIR);
	
	// Point light
    vec3 colProc = vec3(0.8, 0.8, 0.8) * clamp(dot(normal, light), 0.0, 1.0);

	// Ambiant ligth
    colProc += LIGHT_AMBIANT;
			
	vec3 colFinal = mix(colTex, colProc, MIX_FACTOR);	
	
	// Reflection
	vec3 eye = normalize(EYE);
    vec3 ref = reflect(eye, normal);
        
    // Specular
    float spec = pow(clamp(dot(light, ref), 0.0, 1.0), 16.0);
    colFinal += SPEC_FACTOR * spec;	
	
		
    // Set the final fragment color.
	return colFinal;
} 

// Sample a procedural texture (anti-aliasing)
// Stolen from IQ: https://www.shadertoy.com/view/MdjGR1
vec3 FordAA( vec2 uv )
{
	#define SAMPLING_STRENGTH 1000000000.0
	#define NB_SAMPLES 3 //0: no anti-aliasing
	
	if (NB_SAMPLES == 0)
	{
		return Ford( uv );
	}
	else
	{
		// calc texture sampling footprint		
		vec2 ddx = dFdx( uv ); 
		vec2 ddy = dFdy( uv ); 
	
		int sx = 1 + int( clamp( SAMPLING_STRENGTH*length(ddx), 0.0, float(NB_SAMPLES-1) ) );
		int sy = 1 + int( clamp( SAMPLING_STRENGTH*length(ddy), 0.0, float(NB_SAMPLES-1) ) );

		vec3 no = vec3(0.0);

		for( int j=0; j<NB_SAMPLES; j++ )
		for( int i=0; i<NB_SAMPLES; i++ )
		{
			if( j<sy && i<sx )
			{
				vec2 st = vec2( float(i), float(j) ) / vec2( float(sx),float(sy) );
				no += Ford( uv + st.x*ddx + st.y*ddy );
			}
		}

		return no / float(sx*sy);
	}
}

////////////////////////////// main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;   
   
    //pan
  	uv -= iMouse.xy / iResolution.xy;
		
	vec3 col = FordAA( uv );
	
    // Set the final fragment color.
	fragColor = vec4(col,1.0);
}