// Shader downloaded from https://www.shadertoy.com/view/lt2SR1
// written by shadertoy user XT95
//
// Name: Fake sky
// Description: Just try to make a &quot;good&quot; fake sky
//    If you have any suggestion to get it better ..!
// Created by anatole duprat - XT95/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


//Just try to make a sky similar to http://www.scratchapixel.com/old/assets/Uploads/Atmospheric%20Scattering/as-aerial2.png in few lines
//Real sky here : http://www.scratchapixel.com/old/lessons/3d-advanced-lessons/simulating-the-colors-of-the-sky/atmospheric-scattering/



vec3 skyColor( in vec3 rd )
{
    vec3 sundir = normalize( vec3(.0, .1, 1.) );
    
    float yd = min(rd.y, 0.);
    rd.y = max(rd.y, 0.);
    
    vec3 col = vec3(0.);
    
    col += vec3(.4, .4 - exp( -rd.y*20. )*.3, .0) * exp(-rd.y*9.); // Red / Green 
    col += vec3(.3, .5, .6) * (1. - exp(-rd.y*8.) ) * exp(-rd.y*.9) ; // Blue
    
    col = mix(col*1.2, vec3(.3),  1.-exp(yd*100.)); // Fog
    
    col += vec3(1.0, .8, .55) * pow( max(dot(rd,sundir),0.), 15. ) * .6; // Sun
    col += pow(max(dot(rd, sundir),0.), 150.0) *.15;
    
    return col;
}


float checker( vec2 p )
{
    p = mod(floor(p),2.0);
    return mod(p.x + p.y, 2.0) < 1.0 ? .25 : 0.1;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //screen coords
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 v = -1.0+2.0*q;
	v.x *= iResolution.x/iResolution.y;
	
	//camera ray
	vec3 dir = normalize( vec3(v.x, v.y+.5, 1.5) );
	
    //Scene
    vec3 col = vec3( checker(dir.xz/dir.y*.5+vec2(0.,-iGlobalTime*2.)) ) + skyColor(reflect(dir,vec3(0.,1.,0.)))*.3;
    col = mix(col, skyColor(dir), exp(-max(-v.y*9.-4.8,0.)) );

    //Vignetting
	col *= .7 + .3*pow(q.x*q.y*(1.-q.x)*(1.-q.y)*16., .1);
        
	fragColor = vec4( col, 1.);
}