// Shader downloaded from https://www.shadertoy.com/view/MtlGWS
// written by shadertoy user netgrind
//
// Name: ngPsy0
// Description: far out
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime*0.3;
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv*=4.0;
    uv-= 2.0;
    uv = abs(uv);
    //uncomment below for extra symmetry goodness
   // uv -= 1.0;
   // uv = abs(uv);
    vec4 c = texture2D(iChannel0,vec2(
                       uv.x+sin(i+uv.y)*.2+i*.2,
                       uv.y+cos(i+uv.x)*.6+i*.3));
    vec4 c2 = texture2D(iChannel1,vec2(
                       uv.x+sin(i+uv.y)*.7+i*.1,
                       uv.y+cos(i-uv.x)*.2+i*.4));
    for(int j = 0; j<3;j++){
     c +=texture2D(iChannel0,vec2(
                       uv.x+sin(i+uv.y+float(j))*.7+i*.1,
                       uv.y+cos(i-uv.x-float(j))*.2+i*.4));
     c2 +=texture2D(iChannel1, vec2(
                       uv.x+sin(i+uv.y-float(j))*.3+i*.5,
                       uv.y+cos(i-uv.x+float(j))*.5+i*.2));
    }
    c.rgb *= mix(vec3(1,0,.9),vec3(.2,1,.8),sin(i+uv.x)*.5+.5);
    //c2 = 1.0-c2;
    c2.rgb *= mix(vec3(.7,.6,.1),vec3(.1,.5,1),sin(i*.9+uv.y)*.5+.5);
	fragColor = normalize(c+c2)*3.0;//mix(c,c2,sin(uv.x*6.0+i));
}