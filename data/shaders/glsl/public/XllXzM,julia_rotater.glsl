// Shader downloaded from https://www.shadertoy.com/view/XllXzM
// written by shadertoy user spookdy
//
// Name: Julia Rotater
// Description: Fast Julia Set Animator
//    
//    Known Bugs: Orbit trap code returns black (???) for some hardware
//JULIA ROTATOR GLSL 6-26-15

/*
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
} */

vec3 yuv2rgb(vec3 c){
    return vec3(dot(c,vec3(1,0,1.14)),dot(c,vec3(1,-0.395,-0.581)),dot(c,vec3(1,2.032,0)));
}


// # of iterations 6.0, 20.0 and 50.0 are my favorites
const float iter = 30.0;
 
// Julia animation from IQ's Julia Trap 1 shader    
vec2 c = 0.51*cos( vec2(0.0,1.5708) + 0.1*iGlobalTime ) - 0.25*cos( vec2(0.0,1.5708) + 0.2*iGlobalTime ); 

//const float speed = 5.0;
//vec c = vec2(0.6*sin(iGlobalTime/speed),0.8*cos(iGlobalTime/speed));
    
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
   
    //translate from pixel coords to [-2,2]x[-2,2] meshgrid
    vec4 z = vec4(fragCoord.xy - 0.5*iResolution.xy,1,1);
    z = vec4(4.0 * z.xy / iResolution.xy,1,1);
   
    bool inset = true;
    float col=0.0;
    
    //main iteration loop
    for(float i=0.0; i<iter; i++){
        
        //z_n+1 = z_n^2 + c
        //Uses dual numbering for automatic differentiation
        float tzx = z.x*z.x - z.y*z.y + c.x;
        float tzy = 2.0*z.x*z.y + c.y;
        float tzdx = 2.0*(z.x - z.y);
        z.w = 2.0*(z.x + z.y);
        z.x = tzx;
        z.y = tzy;
        z.z = tzdx;
        
        float mag = z.x*z.x+z.y*z.y;
        
        //uses exponential sum coloring to smooth area outside of set
        col = col + exp(-sqrt(mag));
        
        if((mag)>200.0){
            col = col / 3.0; // for contrast
            inset=false;
            break;
        }
    }
    
    //distance formula f(z) = |z|*log|z|/|z'|
    if(inset)col = 0.5*sqrt(dot(z.xy,z.xy)/dot(z.zw,z.zw))*log(dot(z.xy,z.xy));
    col = pow(col,0.25);
    
    //Plots pixel using a quick YUV2RGB algorithm
    fragColor = vec4(yuv2rgb(vec3(0.5+0.5*sin(col),0.8,-col)),1.0);
	//fragColor = vec4(hsv2rgb(vec3(col+0.55,1,1)),1.0);
}