// Shader downloaded from https://www.shadertoy.com/view/XtXGRl
// written by shadertoy user Doublefresh
//
// Name: triangle altitudes
// Description: the altitudes (and orthocenter) of a triangle, using cross product in homogenous coordinates.
float plane2(vec3 l, vec2 p)
{
    l /= length(l.xy); // normalize line
    return smoothstep(0.010, 0.0, abs(dot(l, vec3(p, 1.0))));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0);
    
    vec2 p = 2.0 * uv - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    // triangle verts
    vec3 p0 = vec3(-0.1, 0.02, 1.0);
    vec3 p1 = vec3(0.6, 0.0, 1.0);
    vec3 p2 = vec3(0.25 + 0.1*sin(iGlobalTime), 0.1*cos(iGlobalTime) + 0.5, 1.0);
    
    // draw triangle planes
    col = mix(col, vec3(1.0), plane2(cross(p0, p1), p));
    col = mix(col, vec3(1.0), plane2(cross(p1, p2), p));
    col = mix(col, vec3(1.0), plane2(cross(p2, p0), p));
    
    // (p0 x p1) x p2 and it's cyclic permutations are the altitude lines
    vec3 c012 = cross(cross(p0, p1), p2);
    vec3 c201 = cross(cross(p2, p0), p1);
    vec3 c120 = cross(cross(p1, p2), p0);
    
    col = mix(col, vec3(1.0, 0.5, 0.3), plane2(c012, p)  );
    col = mix(col, vec3(0.3, 1.0, 0.5), plane2(c201, p)  );
    col = mix(col, vec3(0.5, 0.3, 1.0), plane2(c120, p)  );
	fragColor = vec4(col, 1.0);
}