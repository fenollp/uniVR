// Shader downloaded from https://www.shadertoy.com/view/ltX3zf
// written by shadertoy user TekF
//
// Name: Retro City Parallax
// Description: Using my infinite city distance field for something a bit more abstract.
// Ben Quantock 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 Rand( vec2 pos )
{
	return texture2D( iChannel0, (pos+.5)/256.0, -100.0 ).xz;
}

vec3 VoronoiPoint(vec2 pos, vec2 delta )
{
	const float randScale = .8; // reduce this to remove axis-aligned hard edged errors
	
	vec2 p = floor(pos)+delta;
	vec2 r = (Rand(p)-.5)*randScale;
	vec2 c = p+.5+r;
	
	// various length calculations for different patterns
	//float l = length(c-pos);
	//float l = length(vec3(c-pos,.1));
	float l = abs(c.x-pos.x)+abs(c.y-pos.y); // more interesting shapes
	
	return vec3(c,l);
}

// For building height I want to know which voronoi point I used
// For side-walls I want difference between distance of closest 2 points
vec3 Voronoi( vec2 pos )
{
	// find closest & second closest points
	vec3 delta = vec3(-1,0,1);

	// sample surrounding points on the distorted grid
	// could get 2 samples for the price of one using a rotated (17,37) grid...
	vec3 point[9];
	point[0] = VoronoiPoint( pos, delta.xx );
	point[1] = VoronoiPoint( pos, delta.yx );
	point[2] = VoronoiPoint( pos, delta.zx );
	point[3] = VoronoiPoint( pos, delta.xy );
	point[4] = VoronoiPoint( pos, delta.yy );
	point[5] = VoronoiPoint( pos, delta.zy );
	point[6] = VoronoiPoint( pos, delta.xz );
	point[7] = VoronoiPoint( pos, delta.yz );
	point[8] = VoronoiPoint( pos, delta.zz );

	vec3 closest;
	closest.z =
		min(
			min(
				min(
					min( point[0].z, point[1].z ),
					min( point[2].z, point[3].z )
				), min(
					min( point[4].z, point[5].z ),
					min( point[6].z, point[7].z )
				)
			), point[8].z
		);
	
	// find second closest
	// maybe there's a better way to do this
	closest.xy = point[8].xy;
	for ( int i=0; i < 8; i++ )
	{
		if ( closest.z == point[i].z )
		{
			closest = point[i];
			point[i] = point[8];
		}
	}
		
	float t;
	t = min(
			min(
				min( point[0].z, point[1].z ),
				min( point[2].z, point[3].z )
			), min(
				min( point[4].z, point[5].z ),
				min( point[6].z, point[7].z )
			)
		);
	
	return vec3( closest.xy, t-closest.z );
}


float DistanceField( vec3 pos )
{
	vec3 v = Voronoi(pos.xz);
	vec2 r = Rand(v.xy*4.0); // per-building seed
	
	float f = (.2+.3*r.y-v.z)*.5; //.7071; // correct for max gradient of voronoi x+z distance calc
	
	// random height
	float h = r.x; // v.xy is position of cell centre, use it as random seed
	h = mix(.2,2.0,pow(h,2.0));
	h = pos.y-h;

	// we get precision problems caused by the discontinuity in height
	// so clamp it near to the surface and then apply a plane at max height	
	h = max( min( h, .08 ), pos.y-2.0 );

//	f = max( f, h );
	if ( f > 0.0 && h > 0.0 )
		f = sqrt(f*f+h*h); // better distance computation, to reduce errors
	else
		f = max(f,h);
	
	f = min( f, pos.y ); // ground plane
	
	return f;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 iHalfRes = iResolution.xy*.5;
	vec2 uv = fragCoord.xy;
//    uv = floor(uv/6.0)*6.0; // pixellate! (would look better if I aligned each layer to the pixels)
	uv = (uv - iHalfRes)/iHalfRes.y;
    
    vec3 pos = vec3(1.2,0,0)*iGlobalTime+vec3(0,.4+2.0*smoothstep(.0,1.,cos(iGlobalTime*.1)),0);
    float water = step(uv.y/1.4,-pos.y)*-2.0+1.0;
    
    fragColor.rgb = sin(vec3(11,7,3)*uv.y*water)*.5+.5;

    float s = 2.;
    for ( int i=0; i < 20; i++ )
    {
        if ( DistanceField( (vec3(uv*.4,1)*s + pos)*vec3(1,water,1) ) < .0 )
        {
            fragColor.rgb = sin(vec3(11,7,3)*.2*s+6.)*.5+.5;
            break;
        }
        s *= 1.05+s*.02;
    }
    
    if ( water < .0 )
    {
        fragColor.rgb = fragColor.rgb*mix(vec3(1), vec3(.1,.0,.2), smoothstep(-.5,-1.4,uv.y/1.4-pos.y) );
    }
    
	fragColor.a = 1.0;
}

