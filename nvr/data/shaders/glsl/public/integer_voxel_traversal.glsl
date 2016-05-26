// Shader downloaded from https://www.shadertoy.com/view/XdBGDG
// written by shadertoy user Dave_Hoskins
//
// Name: Integer voxel traversal
// Description: I've always liked this old-school voxel stuff, but is it useful? There are no multiplies.
//    2D integer voxel traversal culled from Graphics Gems IV:-
//    http://read.pudn.com/downloads56/sourcecode/graph/texture_mapping/194552/gemsiv/vox_traverse.c__.htm
//    
// Integer voxel traversal

// From Graphics Gems IV 
// http://read.pudn.com/downloads56/sourcecode/graph/texture_mapping/194552/gemsiv/vox_traverse.c__.htm

//===================================================================================
float PlotPos(vec2 uv, vec2 pos)
{
	vec2 pix = floor(uv / (1.0/vec2(64.0)));
	if (pix == pos)
	{
		return 1.0;
	}else
	{
		return 0.0;
	}
}

// No multiplies!...
//===================================================================================
float Line2D(vec2 uv, ivec2 pos, ivec2 dir)  
{  
	float c = 0.0;
	ivec2 s, a, b;
	
	if (dir.x > 0)
		{s.x =  1; a.x =  dir.x;}
	else
		{s.x = -1; a.x = -dir.x;}
	if (dir.y > 0)
		{s.y =  1; a.y =  dir.y;}
	else
		{s.y = -1; a.y = -dir.y;}
			
	b = a + a;
	int e   = a.y - a.x;
    int len = a.x + a.y;
	// This is the traversal...
    for (int i = 0; i < 30; i++)
	{
		if (i > len) continue;
		
		c += PlotPos(uv, vec2(pos.xy));
		if (e < 0)
		{  
			pos.x += s.x;  
			e += b.y;
		}  
		else
		{  
			pos.y += s.y;  
			e -= b.x;
		}  
    } 
	return c;
} 

//===================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragCoord.xy+=.01;
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 gr = fragCoord.xy;
	float aspect = iResolution.y / iResolution.x;
	vec2 pixel = vec2(1.0);
	uv.y    *= aspect;
	pixel.y *= aspect;
	gr.y    *= aspect;

	vec2 gridXY  = step(pixel,  mod(gr, iResolution.xy/64.0)) * .75;
	vec3 backCol = vec3(gridXY.x*gridXY.y) * vec3(.5)+.15;

	float ang = iGlobalTime;
	
	ivec2 beg = ivec2(31, 18);
	ivec2 dxy = ivec2(floor(vec2(sin(ang)*16.5, cos(ang)*16.5)));
	
	float col = Line2D(uv, beg, dxy);
	
	fragColor = vec4(min(backCol+backCol*col*2.0, 1.0), 1.0);
}

//===================================================================================


// This is the 3D version, not tidy...
//float Line3D(vec2 uv, ivec3 pos, ivec3 d)  
//{  
//    int n;  
//	ivec3 a, b, s, e;
//	float c = 0.0;
//	vec3 dir = vec3(d);  // eeek! Didn't have integer maths routines so converted it to float type.
//  
//	s = ivec3(sign(dir));
//	a = ivec3(abs(dir));
//	b = 2*a;
//    //exy = a.y-a.x;   exz = a.z-a.x;   ezy = a.y-a.z;  
//	e = ivec3(a.y-a.x,  a.z-a.x, a.y-a.z);
//	
//    n = a.x + a.y + a.z;  
//    for (int i = 0; i < 100; i++)
//	{
//		if (i > n ) continue;
//		
//		c += PlotPos(uv, vec2(pos.xy));  
//		if ( e.x < 0 )
//		{  
//			if ( e.y < 0 )
//			{  
//				pos.x += s.x;  
//				e.x += b.y;
//				e.y += b.z;  
//			}  
//			else
//			{  
//				pos.z += s.z;  
//				e.y -= b.x;
//				e.z += b.y;  
//			}  
//		}  
//		else
//		{  
//			if ( e.z < 0 )
//			{  
//				pos.z += s.z;  
//				e.y -= b.x;
//				e.z += b.y;  
//			}  
//			else
//			{  
//				pos.y += s.y;  
//				e.x -= b.x;
//				e.z -= b.z;  
//			}  
//		}  
//    } 
//	return c;
//} 
