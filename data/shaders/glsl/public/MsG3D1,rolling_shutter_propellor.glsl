// Shader downloaded from https://www.shadertoy.com/view/MsG3D1
// written by shadertoy user JamesGriffin
//
// Name: Rolling shutter propellor
// Description: A propellor is defined using the implicit equation r &lt; cos^2K(n/2*theta) + H (set the delayCoeff to 0.0 to see it).
//    This is rotated (rotationRate) and a time-shift is applied with the delay set by delayCoeff * y-coord (the rolling shutter effect).
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Constants
    float delayCoeff = 0.9;
    float rotationRate = 2.0;
    float hubSize = 0.1;
    float bladeThinness = 5.0; // Higher is thinner
    int numBlades = 4; // Can only be 2, 3, 4, 5, 6 (otherwise defaults to 6)
    // Transform coordinate system
    vec2 xy = 4.0*(fragCoord.xy-0.5*iResolution.xy) / max(iResolution.x,iResolution.y);
	
    // Work out the angle
    float theta = rotationRate * (iGlobalTime - delayCoeff * xy.y);
    // Rotation matrix
    mat2 M = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    xy = M * xy;
    float r = length(xy);
    float a = 0.0;
    float x = xy.x / r;
    float y = xy.y / r;
    if (r > hubSize + 1.0) { // Don't bother with calculations if out of bounds
        a = -1.0;
    } else {
        float p = 0.0;
        float q = 0.0;

        if(numBlades == 2) {
            // 2 bladed version
            // p = cos(3t) and q = sin(3t)
            p = (x*x - y*y);
            // q = (2.0*x*y); (not used)
        } else if(numBlades == 3) {
            // 3 bladed version
            // p = cos(3t) and q = sin(3t)
            p = (x*x*x - 3.0*x*y*y);
            // q = (3.0*x*x*y - y*y*y); (not used)
        } else if (numBlades == 4) {    
            // 4 bladed version
            // p = cos(4t) and q = sin(4t)
            p = (x*x*x*x - 6.0*x*x*y*y + y*y*y*y);
            // q = (4.0*x*x*x*y - 4.0*x*y*y*y); (not used)
        } else if (numBlades == 5) {    
            // 5 bladed version
            // This is p = cos(5t) and q = sin(5t)
            p = (x*x*x*x*x - 10.0*x*x*x*y*y + 5.0*x*y*y*y*y);
            // q = (5.0*x*x*x*x*y - 10.0*x*x*y*y*y + y*y*y*y*y); (not used)
        } else {
            // 6 bladed version
            // This is p = cos(6t) and q = sin(6t)
            p = (x*x*x*x*x*x - 15.0*x*x*x*x*y*y + 15.0*x*x*y*y*y*y - y*y*y*y*y*y);
            // q = (6.0*x*x*x*x*x*y - 20.0*x*x*x*y*y*y + 6*x*y*y*y*y*y); (not used)
        }

        // RHS of the implicit equation
        a = pow(0.5*(1.0 - p), bladeThinness) + hubSize;

        // Rather than plot LHS < RHS, use this to smooth edges (AA for free)
        a = min(a/r - 1.0, 0.1) / 0.1;
    }
    
    
    if(a < 0.0) {
        // White background
        fragColor = vec4(1.0,1.0,1.0,1.0);
    } else {
        // Compute a colour for the propellor
    	vec3 colour = vec3(0.5, 0.5, 0.5) + x*vec3(0.5,-0.5,0.0)/sqrt(2.0) + y*vec3(0.5,0.5,-1.0)/sqrt(6.0);
    	colour = colour / max(max(colour.r, colour.g), colour.b);
		fragColor = vec4(a*colour + (1.0 - a), 1.0);
    }
}