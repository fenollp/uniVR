// Shader downloaded from https://www.shadertoy.com/view/4lfSzn
// written by shadertoy user FabriceNeyret2
//
// Name: iterated square 2
// Description: .
// variant from https://www.shadertoy.com/view/XtfSRn

float n = 120.; 
float a = 32.*2.*3.1416;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5)); 
    float luv = length(uv)/sqrt(2.);

      
    float t = cos(.5*iGlobalTime);
    a = a/n*pow(t,3.);   float  c=cos(a),s=sin(a);  
    float l=1.; 
    float k = 2.+(.5+.5*cos(.1*iGlobalTime));
    mat2 m=mat2(c,-s,s,c)*k;
    vec4 paint = vec4(pow(.4,1.),pow(.15,1.),pow(.06,1.),1.), col=vec4(1.), p=vec4(1.);
    
    for (float i=0.; i<5.; i++) {
        //if (l<luv) break;
        float w = l/n;
        p *= pow(paint,vec4(w,w,w,1.));
        float d = max(abs(uv.x),abs(uv.y));
        vec4 col0 = smoothstep(.9+.008*l,.9-.008*l,d)*p; 
           col0.a = smoothstep(.9+.008*l,.9-.008*l*(1.-abs(t)),d);
        col = col0 + (1.-col0.a)*col;
        l *= k;
        uv *= m; uv -= sign(uv);
    }
    
	fragColor = col;
}