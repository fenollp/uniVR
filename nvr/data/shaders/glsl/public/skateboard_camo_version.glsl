// Shader downloaded from https://www.shadertoy.com/view/MtSGWG
// written by shadertoy user yasuo
//
// Name: Skateboard camo version
// Description: it's just my drawing staff that I really like to draw, and experiment.
		#define NEAR 0.1
		#define FAR 100.
		#define ITER 128
		#define HALF_PI 1.5707963267948966
		const float PI = 3.14159265359;
		const float DEG_TO_RAD = PI / 180.0;
		float gt;
		float gtime;

		mat4 matRotateX(float rad)
		{
			return mat4(1,       0,        0,0,
						0,cos(rad),-sin(rad),0,
						0,sin(rad), cos(rad),0,
						0,       0,        0,1);
		}

		mat4 matRotateY(float rad)
		{
			return mat4( cos(rad),0,-sin(rad),0,
						 0,       1,        0,0,
						 sin(rad),0, cos(rad),0,
						 0,       0,        0,1);
		}

		mat4 matRotateZ(float rad)
		{
			return mat4(cos(rad),-sin(rad),0,0,
						sin(rad), cos(rad),0,0,
						       0,        0,1,0,
							   0,        0,0,1);
		}

		vec4 combine(vec4 val1, vec4 val2 )
		{
			if ( val1.w < val2.w ) return val1;
			return val2;
		}
		
		vec2 rot(vec2 p, float a) {
			return vec2(
				cos(a) * p.x - sin(a) * p.y,
				sin(a) * p.x + cos(a) * p.y);
		}

		// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
		float sdCappedCylinder( vec3 p, vec2 h )
		{
		  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
		  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
		}

		// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
		float sdCone( vec3 p, float r, float h )
		{
			vec2 c = normalize( vec2( h, r ) );
		    float q = length(p.xy);
		    return max( dot(c,vec2(q,p.z)), -(p.z + h) );
		}

		// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
		float udRoundBox( vec3 p, vec3 b, float r )
		{
		  return length(max(abs(p)-b,sin(r*0.1)))-r;
		}

		float rand( vec2 p )
		{
			return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 43758.5453);
		}

		float noise(vec2 _v, vec2 _freq)
		{
			float fl1 = rand(floor(_v * _freq));
			float fl2 = rand(floor(_v * _freq) + vec2(1.0, 0.0));
			float fl3 = rand(floor(_v * _freq) + vec2(0.0, 1.0));
			float fl4 = rand(floor(_v * _freq) + vec2(1.0, 1.0));
			vec2 fr = fract(_v * _freq);

			float r1 = mix(fl1, fl2, fr.x);
			float r2 = mix(fl3, fl4, fr.x);
			return mix(r1, r2, fr.y);
		}

		float perlin_noise(vec2 _pos, float _freq_start, float _amp_start, float _amp_ratio)
		{
			float freq = _freq_start;
			float amp = _amp_start;
			float pn = noise(_pos, vec2(freq, freq)) * amp;
			for(int i=0; i<4; i++)
			{
				freq *= 2.0;
				amp *= _amp_ratio;
				pn += (noise(_pos, vec2(freq, freq)) * 2.0 - 1.0) * amp;
			}
			return pn;
		}

		vec3 texmain(vec2 position) {
			float noise = perlin_noise( position + vec2(10, 10), 3., .3, .3 );
			
			float t = iGlobalTime*2.0;
			for(int i=1;i<3;i++)
			{
				vec2 newp=position;
				newp.x+=3.3/float(i)*cos(float(i)*position.y+t*0.3+0.3*float(i))+noise;
				newp.y+=2.3/float(i)*sin(float(i)*position.x+t*0.5+0.3*float(i))-noise;
				position=newp;
			}
			vec3 col=vec3(0.35*sin(1.1*position.x),0.5*sin(2.0*position.y),0.1*sin(position.x));
	
			return col;
		}

		vec4 map( vec3 pos, mat4 m)
		{
			pos = vec3((pos.x),(pos.y),(pos.z));
			vec4 q = vec4(pos+vec3(0,0,-70.0),1.0)*m;

			vec3 bcl = texmain(q.xz);
			//vec3 bcl = vec3(1.0,1.0,0);
			vec4 newQ = vec4(q.xyz+ vec3( 0, -4.0, -18.0 ),1.0)*matRotateX(12.0 * DEG_TO_RAD);
			vec4 val = vec4(bcl,udRoundBox(newQ.xyz,vec3(7.0,0.1,3.0),0.5));

			vec4 newQ0 = vec4(q.xyz+ vec3( 0, -3.5, 2 ),1.0);
			vec4 val0 = vec4(bcl,udRoundBox(newQ0.xyz,vec3(7.0,0.1,18.0),0.5));

			vec4 newQ1 = vec4(q.xyz+ vec3( 6, 0, 15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val1 = vec4(1.0,0,0,sdCappedCylinder(newQ1.xyz,vec2(2.0,2.0)));

			vec4 newQ2 = vec4(q.xyz+ vec3( -6, 0, 15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val2 = vec4(1.0,0,0,sdCappedCylinder(newQ2.xyz,vec2(2.0,2.0)));

			vec4 newQ3 = vec4(q.xyz+ vec3( 0, 0, 15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val3 = vec4(0.7,0.7,0.7,sdCappedCylinder(newQ3.xyz,vec2(1.0,5.0)));

			vec4 newQ4 = vec4(q.xyz+ vec3( -0, 0, 15 ),1.0)*matRotateX(-90.0 * DEG_TO_RAD);
			vec4 val4 = vec4(0.3,0.3,0.3,sdCone(newQ4.xyz,2.0,4.0));


			vec4 newQ5 = vec4(q.xyz+ vec3( 6, 0, -15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val5 = vec4(1.0,0,0,sdCappedCylinder(newQ5.xyz,vec2(2.0,2.0)));

			vec4 newQ6 = vec4(q.xyz+ vec3( -6, 0, -15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val6 = vec4(1.0,0,0,sdCappedCylinder(newQ6.xyz,vec2(2.0,2.0)));

			vec4 newQ7 = vec4(q.xyz+ vec3( 0, 0, -15 ),1.0)*matRotateZ(-90.0 * DEG_TO_RAD);
			vec4 val7 = vec4(0.7,0.7,0.7,sdCappedCylinder(newQ7.xyz,vec2(1.0,5.0)));

			vec4 newQ8 = vec4(q.xyz+ vec3( 0, 0, -15 ),1.0)*matRotateX(-90.0 * DEG_TO_RAD);
			vec4 val8 = vec4(0.3,0.3,0.3,sdCone(newQ8.xyz,2.0,4.0));

			vec4 val9 = combine ( val, val0 );
			vec4 val10 = combine ( val1, val2 );
			vec4 val11 = combine ( val3, val4 );
			vec4 val12 = combine ( val5, val6 );
			vec4 val13 = combine ( val7, val8 );
			vec4 val14 = combine ( val9, val10 );
			vec4 val15 = combine ( val11, val12 );
			vec4 val16 = combine ( val13, val14 );
			return combine ( val15, val16 );
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord ){
			gt = iGlobalTime*0.5;

			vec2 position = ( fragCoord.xy / iResolution.xy );
			position -= .5;
			vec3 dir = vec3( position, 1.0 );
			
         	float aspect = iResolution.x / iResolution.y;
         	dir = normalize(vec3(position * vec2(aspect, 1.0), 1.0));
		 	dir.yz = rot(dir.yz, -0.1);

		 	vec3 pos = vec3(0.0, 3.0, 15.0);
	
			float t = floor(gt);
		    float f = fract(gt);
		    t += sin(-13.0 * (f + 1.0) * HALF_PI) * pow(2.0, -10.0 * f) + 1.0;
		    gtime = t;

			mat4 m = matRotateY(iGlobalTime)*matRotateX(gtime)*matRotateZ(gtime);

			vec4 result;
			for (int i =0; i < ITER; i++)
			{
				result = map(pos, m);
				if (result.w < NEAR || result.w > FAR) break;
				pos += result.w * dir;
			}

			vec3 col = map(pos, m).xyz;
			if ( pos.z> 100. )
			{
				float temp = length(vec2(position.xy))+0.9;
				col = vec3(.5,.5,.5)/vec3(temp);
			}
			else
			{
				vec3 lightPos = vec3(20.0, 20.0, 20.0 );
				vec3 light2Pos = normalize( lightPos - pos);
				vec3 eps = vec3( .1, .01, .0 );
				vec3 n = vec3( result.w - map( pos - eps.xyy, m ).w,
					       result.w - map( pos - eps.yxy, m ).w,
					       result.w - map( pos - eps.yyx, m ).w );
				n = normalize(n);
						
				float lambert = max(.0, dot( n, light2Pos));
				col *= vec3(lambert);
				
				// specular : 
				vec3 h = normalize( -dir + light2Pos);
				float spec = max( 0., dot( n, h ) );
				col += vec3(pow( spec, 16.)) ;
			}

			fragColor = vec4( col, 1.0);
		}