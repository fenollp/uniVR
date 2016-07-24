// Shader downloaded from https://www.shadertoy.com/view/MdfGWn
// written by shadertoy user iq
//
// Name: Ellipse - Distance Estimation
// Description: If a circle is deformed into an ellipse distances are nor preserved, and hence its thickness is not constant (left). A (first order) distance estimation can be done by diving the implicit by the modulo of its gradient, producing constant thickness (right)
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// An example on how to compute a distance estimation for an ellipse (which provides
// constant thickness to its boundary). This is achieved by dividing the implicit 
// description by the modulo of its gradient. The same process can be applied to any
// shape defined by an implicity formula (ellipses, metaballs, fractals, mandelbulbs).
//
// top    left : f(x,y)
// top    right: f(x,y) divided by analytical gradient
// bottom left : f(x,y) divided by numerical GPU gradient
// bottom right: f(x,y) divided by numerical gradient
//
// More info here:
//
// http://www.iquilezles.org/www/articles/distance/distance.htm

float a = 1.0;
float b = 3.0;
float r = 0.9 + 0.1*sin(3.1415927*iGlobalTime);

float e = 2.0/iResolution.y;

// f(x,y) (top left)
float ellipse1(vec2 p)
{
    float f = abs(length( p*vec2(a,b) )-r);
    return f;
}

// f(x,y) divided by analytical gradient (top right)
float ellipse2(vec2 p)
{
    float f = length( p*vec2(a,b) );
    return abs(f-r)*f/(length(p*vec2(a*a,b*b)));
}

// f(x,y) divided by numerical GPU gradient (bottom left)
float ellipse3(vec2 p)
{
    float f = ellipse1(p);
    float g = length( vec2(dFdx(f),dFdy(f))/e );
	return f/g;
}

// f(x,y) divided by numerical gradient (bottom right)
float ellipse4(vec2 p)
{
    float f = ellipse1(p);
    float g = length( vec2(ellipse1(p+vec2(e,0.0))-ellipse1(p-vec2(e,0.0)),
                           ellipse1(p+vec2(0.0,e))-ellipse1(p-vec2(0.0,e))) )/(2.0*e);
    return f/ g;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
    
	float f1 = ellipse1(uv);
	float f2 = ellipse2(uv);
	float f3 = ellipse3(uv);
	float f4 = ellipse4(uv);
	
	vec3 col = vec3(0.3);

    // ellipse     
    float f = mix( mix(f1,f2,step(0.0,uv.x)), 
                   mix(f3,f4,step(0.0,uv.x)), 
                   step(uv.y,0.0) );
    
	col = mix( col, vec3(1.0,0.6,0.2), 1.0-smoothstep( 0.1, 0.11, f ) );
    
    // lines    
	col *= smoothstep( e, 2.0*e, abs(uv.x) );
	col *= smoothstep( e, 2.0*e, abs(uv.y) );
	
	fragColor = vec4( col, 1.0 );
}