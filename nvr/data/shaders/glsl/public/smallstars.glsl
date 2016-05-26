// Shader downloaded from https://www.shadertoy.com/view/Ml2XDt
// written by shadertoy user P_Malin
//
// Name: SmallStars
// Description: My attempt to play at starfield code golf.
//    Along the lines of https://www.shadertoy.com/view/MdlXWr
//    
// SmallStars - @P_Malin
// My attempt to play at starfield code golf.
// Along the lines of https://www.shadertoy.com/view/MdlXWr

// Fully initialize f by using iDate.wwww - 138 characters
//*
void mainImage( out vec4 f, vec2 p )
{
    p=p/2e3-.2;

    float b = ceil(atan(p.x, p.y) * 6e2), h = cos(b), z = h / dot(p,p);
    f = exp(fract(z + h * b + iDate.wwww) * -1e2) / z;
}
/**/

// Ignore resolution - 136 characters
/*
void mainImage( out vec4 f, vec2 p )
{
    p=p/2e3-.2;

    float b = ceil(atan(p.x, p.y) * 6e2), h = cos(b), z = h / dot(p,p);
    f = exp(fract(z + h * b + iDate.wwww) * -1e2) / z;
}
/**/


// remove h = abs - 147 characters
/*
void mainImage( out vec4 f, vec2 p )
{
    p = p / iResolution.xy - .5;

    float b = ceil(atan(p.x, p.y) * 4e2), h = cos(b), z = h / dot(p,p);
    
    f += exp(fract(z + h * b + iDate.w) * -1e2) / z;
}
/**/


// Utter hacks 1 - 152 characters
/*
void mainImage( out vec4 f, vec2 p )
{
    p = p / iResolution.xy - .5;

    float b = ceil(atan(p.x, p.y) * 4e2), h = abs(cos(b)), z = h / dot(p,p);
    
    f += exp(fract(z + h * b + iDate.w) * -1e2) / z;
}
/**/

// No angular falloff - 
// hash -> abs(cos()) 
// no aspect ratio correctino - 180 cahrs
/*
void mainImage( out vec4 f, vec2 p )
{
    p = p / iResolution.xy - .5;

    float t = atan(p.x, p.y) * 2e2
    ,b = ceil(t)
    ,r = length(p)
    ,h = abs(cos(b))
    ,o = h * b + iDate.w;
    o -= ceil(h/r + o) - .5;
    
    r+=h/o;
	f += (1. - 1e5 * r*r) / o / o - f;
}
/**/

// Simplified star shape (no longer round) - 213 cahrs
/*void mainImage( out vec4 f, vec2 p )
{
    f.xyz = iResolution;
    p -= .5 * f.xy;

    float t = atan(p.x, p.y) * 99.
    ,b = ceil(t)
    ,r = length(p) / f.x
    ,h = fract(cos(b)*b)
    ,o = h * b + iDate.w;
    o -= ceil(h/r + o) - .5;
    
    t += .5-b;
    r+=h/o;
	f += (.25-t * t) * (1. - 1e5 * r*r) /o/o - f;
}
/**/

// Changed hash function, star random depth and star shape calc= 216 chars
/* void mainImage( out vec4 f, vec2 p )
{
    f.xyz = iResolution;
    p -= .5 * f.xy;

    float t = atan(p.x, p.y) * 48.
    ,b = ceil(t)
    ,r = length(p) / f.x
    ,h = fract(cos(b)*b)
    ,o = h * b + iDate.w;
    o -= ceil(h/r + o) - .5;
    
    t=(b-t-.5)*h*r;
    r+=h/o;
    
	f += (1. - 1e5 * (t*t+r*r)) / o/o - f;
} 
/**/


// Even more changes from Fabrice & iq = 219 chars
/*void mainImage( out vec4 f, vec2 p )
{
    f.xyz = iResolution;
    p -= .5 * f.xy;

    float t = atan(p.x, p.y) * 48.
    ,b = ceil(t)
    ,r = length(p) / f.x
    ,h = fract(sin(b)*9.)
    ,o = h * 9. + iDate.w;
    o -= ceil(h/r + o) - .5;
    
	f += (1. - 4e2 * length(vec2( h/o+r, (b-t-.5)*h*r ))) / o/o - f;
}
*/


// With changes from Fabrice & iq = 222 chars
/*
void mainImage( out vec4 f, vec2 p )
{
    f.xyz = iResolution;
    p -= .5 * f.xy;

    float t = atan(p.x, p.y) * 48.
    ,r = length(p) / f.x
    ,h = fract(sin(ceil(t)) * 9.)
    ,o = h * 9. + iDate.w
    ,c = ceil(h/r + o) - .5 - o;
    
	f = vec4(1. - 4e2 * length(vec2( h/c-r, (fract(t)-.5)*h*r ))) / c/c;
}
/**/

// With changes from Fabrice = 225 chars
/*
void mainImage( out vec4 f, vec2 p )
{
    f.xyz = iResolution;
    p = (p - .5 * f.xy ) / f.x;

    float t = atan(p.x, p.y) * 48.
    ,r = length(p)
    ,h = fract(sin(ceil(t)) * 9.)
    ,o = h * 9. + iDate.w
    ,c = ceil(h/r + o) - .5 - o;
    
	f = vec4(1. - 4e2 * length(vec2( h/c-r, (fract(t)-.5)*h*r ))) / c/c;
}
*/

// Original version = 255 chars - @P_Malin
/*
void mainImage( out vec4 f, in vec2 p )
{
    f.xyz = iResolution;
    p = p / (f.xy) - .5;
    p.y *= f.y / f.x; // aspect ratio correction

    float t = atan(p.x, p.y) * 48.
    ,r = length(p)
    ,h = fract(sin(floor(t) * 8.) * 9.)
    ,o = h * 9. + iDate.w
    ,c = floor(h/r + o) + .5 - o;
    
    p.x = ((h / c) - r);
    p.y = (fract(t) - .5) * h * r;
    
	f = vec4((1. - length( p ) * 400. ) / (c*c));
}
/**/


/*
// Pre-golf hacking
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / (iResolution.xy) - 0.5;
    p.y *= iResolution.y / iResolution.x;
    
    float theta = atan(p.x, p.y) * radians(1400.);
    float segmentPos = fract(theta);
    float segmentIndex = floor(theta);
    float random = fract(sin(segmentIndex * 123.45) * 67.89);
    float screenRadius = length(p);
    float worldRadius = random + 0.01;
    float worldIntersectZ = worldRadius / screenRadius;
      
    float offset = random + iGlobalTime;
    float fClosestStarZ = floor(worldIntersectZ + offset) + 0.5 - offset;

   	float fClosestStarScreenRadius = worldRadius / fClosestStarZ;
    
    float screenDR = (fClosestStarScreenRadius - screenRadius);
    float screenDA = (segmentPos - 0.5) / screenRadius;
    
    float c = 0.0;
    c = 1.0 - length( vec2( screenDR * 200.0, screenDA * 2.0 ) );
    c = c * 2.0 / max( 0.001, fClosestStarZ);
	fragColor = vec4(c);
}
/**/
