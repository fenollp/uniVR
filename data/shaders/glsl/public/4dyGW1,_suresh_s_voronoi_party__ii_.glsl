// Shader downloaded from https://www.shadertoy.com/view/4dyGW1
// written by shadertoy user imallett
//
// Name:  Suresh's Voronoi Party (II)
// Description: An improved version of this shader:
//    https://www.shadertoy.com/view/ldKGDz
//    Which in turn was based on a discussion with the author. Supports higher-level envelopes, antialiasing, and more.
//Algorithm parameters
#define NUM_POINTS 16
#define MS_PER_STEP 1000.0
#define ENVELOPE_DEPTH 2 //Must be at least 1 (2 if you want boundaries)
#define NORM 2 //1==L_1 norm, 2==L_2 norm, etc.  Use -1 for infinity norm.
#if   NORM ==  1
	#define NORM_FUNC L_1
#elif NORM ==  2
	#define NORM_FUNC L_2
#elif NORM == -1
	#define NORM_FUNC L_inf
#else
	#error Unsupported norm!
#endif

//Extra features
//#define WEIGHT_FIRST_CONE
#ifdef WEIGHT_FIRST_CONE
	#define FIRST_CONE_WEIGHT -0.5
#endif

//Render parameters
#define DRAW_BOUNDARIES //Must have ENVELOPE_DEPTH >= 2 and NORM == 2
#ifdef DRAW_BOUNDARIES
	#define BOUNDARY_RADIUS 0.005
#endif
#define POINT_RADIUS 0.02
//	Can set to higher to see deeper levels.  Must be strictly less than ENVELOPE_DEPTH.  Not
//		supported with DRAW_BOUNDARIES defined.
#define ENVELOPE_LEVEL 0


//The envelope we build implicitly
struct Record {
	float u;
	float dist;
	vec2 generating_pt;
};
Record envelope[ENVELOPE_DEPTH];


//Norms
float L_1(vec2 p0, vec2 p1) {
	vec2 tmp = abs(p0 - p1);
	return tmp.x + tmp.y;
}
float L_2(vec2 p0, vec2 p1) {
	return distance(p0, p1);
}
float L_inf(vec2 p0, vec2 p1) {
	vec2 tmp = abs(p0 - p1);
	return max(tmp.x, tmp.y);
}

//Inserts the given record into "envelope" of current size "size".  Returns whether it was appended or
//	replaced another record successfully.
bool insert(Record record, int size) {
	//Similar algorithms don't work because WebGL doesn't like dynamically indexed loops (or while loops).
	//	This one perturbs it into working.
	if (record.dist<envelope[ENVELOPE_DEPTH-1].dist) {
		//Kick out last element
		envelope[ENVELOPE_DEPTH-1] = record;
		//Bubble sort
		for (int i=ENVELOPE_DEPTH-1;i>=1;--i) {
			if (envelope[i-1].dist > envelope[i].dist) {
				Record temp = envelope[i-1];
				envelope[i-1] = envelope[i];
				envelope[i] = temp;
			} else break;
		}
		return true;
	} else {
		return false;
	}
}

vec4 get_sample(vec2 frag_coord) {
	//Setup
	vec2 aspect = vec2(iResolution.x/iResolution.y, 1.0);

	vec2 uv = frag_coord.xy/iResolution.xy;
	vec2 frag_pos = aspect*(2.0*uv - vec2(1.0));

	for (int i=0;i<ENVELOPE_DEPTH;++i) {
		envelope[i].dist = 9999999999999.0;
	}

	//Add each point to the per-sample envelope.
	vec4 color;
	for (int i=0;i<NUM_POINTS;++i) {
		float u = float(i)*(1.0/float(NUM_POINTS));
		vec4 sample = texture2D(
			iChannel0,
			vec2( u, iGlobalTime*(1.0/MS_PER_STEP) )
		);
		vec2 generating_pt = aspect*(2.0*sample.xy-vec2(1.0));

		float dist = NORM_FUNC(frag_pos,generating_pt);

		if (dist<POINT_RADIUS) { return vec4(1.0); } //Draw generating points

		#ifdef WEIGHT_FIRST_CONE
			if (i==0) dist+=FIRST_CONE_WEIGHT;
		#endif

		//Note: because GPUs compute 2x2 quads, this code must be in the loop, instead of
		//	outside of it.  Terrible, I know.
		if (insert(Record(u,dist,generating_pt),i<ENVELOPE_DEPTH?i:ENVELOPE_DEPTH)) {
			color = texture2D(iChannel0, vec2(envelope[ENVELOPE_LEVEL].u, 0.0));

			#if defined DRAW_BOUNDARIES && ENVELOPE_DEPTH > 1 && NORM == 2 && ENVELOPE_LEVEL == 0
			vec2 normal = normalize(envelope[ENVELOPE_LEVEL].generating_pt - envelope[ENVELOPE_LEVEL+1].generating_pt);
			vec2 displ = frag_pos - 0.5*(envelope[ENVELOPE_LEVEL].generating_pt + envelope[ENVELOPE_LEVEL+1].generating_pt);
			float d = dot(normal,displ);
			if (abs(d)<BOUNDARY_RADIUS) {
				color = vec4(0.0);
			}
			#endif
		}
	}
	return color;
}

void mainImage(out vec4 frag_color, in vec2 frag_coord) {
	//Run algorithm (16x supersampling)
	frag_color = vec4(0,0,0,0);
	for (int j=0;j<4;++j) {
		for (int i=0;i<4;++i) {
			frag_color += get_sample(frag_coord-vec2(0.475,0.475)+vec2(0.25,0.25)*vec2(i,j));
		}
	}
	frag_color *= 1.0/16.0;
}
