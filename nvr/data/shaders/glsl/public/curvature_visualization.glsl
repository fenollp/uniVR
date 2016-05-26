// Shader downloaded from https://www.shadertoy.com/view/4stSRf
// written by shadertoy user sibaku
//
// Name: Curvature visualization
// Description: This shader computes the curvature of a given distance function with auto diff and eigenvalue decomposition. Instructions and more info at the top of the code
//*************** INSTRUCTIONS **********************
//
// Move the camera by dragging the mouse with left button held down
//
// Change scenes by redifining SCENE with either TORUS, CYLINDER or CONE in Buf A
//
// Uncomment #define USE_SECOND_DIRECTION to show second principal direction.
// This is only working for the torus though, since the other two objects have directions
// of zero curvature. In that case, the fallback is to the first direction
//
//***************************************************

//*************** INFO **********************
//
// This demo will visualize the curvature of an object
// For a real distance function f, ||grad f|| = 1 
// The hessian can then be used to compute principal curvatures and -directions
// Principal curvatures are the non-zero eigenvalues and the directions the corresponding
// eigenvectors
//
// Directions are then projected onto the screen yielding a 2D vector field
// That is visualized with a simple version of a line integral convolution
//
// Outlines are done with the distance gained from the distance field, so no sobel edge filter
//
//***************************************************



const int steps = 30;
const float size = 30.;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 sample =texture2D(iChannel0,uv);
    
    // Background
    if(sample.w < 1.)
    {
        fragColor = vec4(1.)*float(sample.z>0.07);
        return;
    }
    vec2 dir = normalize(sample.xy);
    
    vec2 texelSize = 1./iResolution.xy;
    
    // Simple line integral convolution
    // Step along line for some length and accumulate random weights
    dir *= size*texelSize;
    vec2 start = uv - 0.5*dir;
    float val = 0.;
    float realSteps = 0.;
    vec2 pos = start;
    for(int i = 0; i < steps; i++)
    {
        pos = start + dir*float(i)/float(steps);
        vec4 samplePos = texture2D(iChannel0,pos);
        
        val += texture2D(iChannel1,pos).r;
    }
    
 
    float sat = float(val/float(steps) );
    fragColor = vec4(sat < 0.5);
}