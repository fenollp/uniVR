// Shader downloaded from https://www.shadertoy.com/view/MtSGWt
// written by shadertoy user nshelton
//
// Name: MandelBox audio
// Description: mandelbox folded with audio

			#define MAX_ITER  20
			#define MAX_ORBIT 10


			void sphereFold(inout vec3 z, inout float dz) {

				float fixedRadius2 = 2.0;
				float minRadius2  = 0.5 ;

				float r2 = dot(z,z);
				if (r2 < minRadius2) { 
					// linear inner scaling
					float temp = (fixedRadius2/minRadius2);
					z *= temp;
					dz*= temp;
				} else if (r2 < fixedRadius2) { 
					// this is the actual sphere inversion
					float temp =(fixedRadius2/r2);
					z *= temp;
					dz*= temp;
				}
			}
			 
			void boxFold(inout vec3 z, inout float dz) {
                float wav = pow(texture2D(iChannel1, vec2(length(z.xy), 0.) ).x, 0.5) ;
				float foldingLimit = wav/50. + 2.0;
				z = clamp(z, -foldingLimit, foldingLimit) * 2.0 - z;
			}

			vec2 DE(vec3 z)
			{
				vec3 offset = z;
				float dr = 1.0;

				//float Scale = sin(iGlobalTime/20.)/20. + 2.;
                float Scale = 2.0;
				float iter = 0.0;

				for (int n = 0; n < MAX_ORBIT; n++) {
					boxFold(z,dr);       // Reflect
					sphereFold(z,dr);    // Sphere Inversion
			 		
	                z=Scale*z + offset;  // Scale & Translate
	                dr = dr*abs(Scale)+1.0;
	                iter++;
				}
                
				float r = length(z);

				return vec2(iter, r/abs(dr));
			}


			vec3 gradient(vec3 p, float t) {
				vec2 e = vec2(0., t);

				return normalize( 
					vec3(
						DE(p+e.yxx).y - DE(p-e.yxx).y,
						DE(p+e.xyx).y - DE(p-e.xyx).y,
						DE(p+e.xxy).y - DE(p-e.xxy).y
					)
				);
			}					


			#define PI 3.1415
			void mainImage( out vec4 fragColor, in vec2 fragCoord )
			{
				vec2 uv = fragCoord.xy / iResolution.xy;
    			vec2 coord = (uv - 0.5);
                vec4 wav = texture2D(iChannel1, vec2(uv.x, .0) );

			    //raymarcher!
				float t = iGlobalTime/1000.;
			    vec3 camera = vec3(
                    2.6 * cos(t),
                   	2.8 * sin(t),
                    - 0.1 * sin(t)
                );
				camera = vec3(0.,0.,-6.);
			    vec3 point;

			    vec4 n = texture2D(iChannel0, fract(uv + iGlobalTime*100.));
			    vec2 jitter = (n.xy - 0.5) / iResolution.xy ;

	   		 	vec3 ray = normalize( vec3(coord + jitter/2., -1.0) );

	   		 	float thresh = 0.0005 ;
	   		 	float orbit = 0.;
	   		 	// raycasting parameter
	   		 	t  = 0.;
	   		 	float iter = 0.;
	   		 	
	   		 	//  ray stepping 
			    for(int i = 0; i < MAX_ITER; i++) {
			        point = camera + ray * t;
			        vec2 dist = DE(point);
			        orbit = dist.x ;

			        if (abs(dist.y) < thresh) // *  exp(.1 * float(i)))
						break;
			        
			    	t += dist.y;
			        iter ++;

			    }
			    
			    float shade = pow(dot(gradient(point, thresh * 0.5), ray), 0.10);
                
				vec3 c = vec3(0.8, 0.6, 1.0) * shade *( 1.5 - iter / float(MAX_ITER) ) ;
    			//c += (n.xxx - wav.x) / 10.;
                //c *= 2. * pow(sin(uv.y * iResolution.y), 2.);
                
				fragColor = vec4(c, 1.0) ;
    

			}