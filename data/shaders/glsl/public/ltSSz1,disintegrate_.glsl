// Shader downloaded from https://www.shadertoy.com/view/ltSSz1
// written by shadertoy user coding_99
//
// Name: disintegrate?
// Description: Trying to make a disintegrator (i.e. preserve texture fragments, but disperse them in a neat way).  First attempt.  Any suggestions / pointers to better examples would be appreciated.  Thanks!

float time = iGlobalTime/20.0;

float d = 15.0;


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // normalized coordinates (-1 to 1 vertically)
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;

    // current polar co-ordinates
    float a = atan(p.y,p.x);
    float r = length(p);
    

    // where p used to be earlier in time;
    float old_r = r-time;
    

    // co-ordinates where p maps to backwards in time, assuming radial spread
    vec2 old_xy = vec2(old_r*cos(a), old_r*sin(a));
        
    vec3 col = vec3(0.0,0.0,0.0);
    
        if (old_r >= 0.0)
    	{

            // calculate nearest subcircle centre of back-projected r
	   		vec2 sc_xy =  floor((old_xy * d) + 0.5)/d;
    
            float sc_r = length(sc_xy);
            float sc_a = atan(sc_xy.y, sc_xy.x);
            
    
    		// determine if old_xy is inside a subcircle
      		float sc_dist = distance(old_xy, sc_xy);


            if (sc_dist < (1.0/d)/2.0)
   			{
            
                // we are in a sub-circle


                // determine if p is within the subcircle that moved 
                // (contents of subcircle all move with the same angle, instead of radial dispersion)

                float new_sc_r = sc_r + time;
                vec2 new_sc_xy = vec2(new_sc_r * cos(sc_a), new_sc_r * sin(sc_a));

                float new_sc_rad = distance(p, new_sc_xy);
                if (new_sc_rad < (1.0/d)/2.0)
                {

                    // p is in a subsircle that moved

                    // determine the mapped pixel that corresponds to p
                    vec2 new_uv = sc_xy + (p-new_sc_xy);

                    col =  texture2D(iChannel0, new_uv).xyz;


                }
                

	    	}


        }
    

    
    
    fragColor = vec4( col, 1.0 );
    
}


