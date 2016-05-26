// Shader downloaded from https://www.shadertoy.com/view/4tSGRm
// written by shadertoy user mahmud9935
//
// Name: Glowing flower
// Description: Simple glowing flower via the sphere deformation
void mainImage( out vec4 fragColor, in vec2 fragCoord )
    
    
{
	vec2 p = (fragCoord.xy / iResolution.xy)-vec2(0.5);
    
    // radius deformation
    
    float r=0.2+0.1*cos(atan(p.x,p.y)*19.);
    // sphere
    
    float s=length(p)-r;
    vec3 q=vec3(0.9,0.2,0.05);
        vec3 col;            
    col+=smoothstep(0.1,1.,pow(s,0.5));             
                    
    col=q/col;
	fragColor = vec4(col,1.0);
}