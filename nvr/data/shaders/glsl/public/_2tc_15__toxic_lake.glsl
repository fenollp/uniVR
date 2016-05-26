// Shader downloaded from https://www.shadertoy.com/view/Xls3WM
// written by shadertoy user reinder
//
// Name: [2TC 15] Toxic lake
// Description: I am just one day at home between two holidays, so I don't have the time to really participate in this contest :(. This shader is based on  https://www.shadertoy.com/view/4ls3D4 by Dave_Hoskins. I have added fbm and color. 
// Created by Reinder Nijhoff 2015
// @reindernijhoff
//
// Based on https://www.shadertoy.com/view/4ls3D4 by Dave_Hoskins

#define n b = .5*(b + texture2D(iChannel0, (c.xy + vec2(37, 17) * floor(c.z)) / 256.).x); c *= .4;

void mainImage( out vec4 f, in vec2 w ) {
    vec3 p = vec3(w.xy / iResolution.xy - .5, .2), 
	d = p, a = p, b = p-p, c;

    for(int i = 0; i<99; i++) {
        c = p; c.z += iGlobalTime * 5.;
        n
        n
        n
        a += (1. - a) * b.x * abs(p.y) / 4e2;
        p += d;
    }
    f = vec4(1. - a*a,1);
}

