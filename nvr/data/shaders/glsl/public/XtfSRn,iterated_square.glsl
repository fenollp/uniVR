// Shader downloaded from https://www.shadertoy.com/view/XtfSRn
// written by shadertoy user FabriceNeyret2
//
// Name: iterated square
// Description: ( try SPACE or F )
float n = 120.; 
float a = 4.*2.*3.1416;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y -vec2(.9,.5)); 
    float luv = length(uv)/sqrt(2.);
    if (keyToggle(32)) { uv.x /= (1.-.5*uv.y); uv.y /= (.8-.2*uv.y); luv*=.9; }
      
    float t = cos(.5*iGlobalTime);
    a = a/n*pow(t,3.);   float  c=cos(a),s=sin(a);  
    float z=(0.98+.03*cos(.1*iGlobalTime))/(abs(s)+abs(c)),  l=1.; 
    mat2 m=mat2(c,-s,s,c)/z;
    vec4 paint = vec4(pow(.4,1.),pow(.15,1.),pow(.06,1.),1.), col=vec4(1.), p=vec4(1.);
    
    for (float i=0.; i<250.; i++) {
        if (l<luv) break;
        float w = l/n;
        p *= pow(paint,vec4(w,w,w,1.));
        float d = max(abs(uv.x),abs(uv.y));
        vec4 col0 = smoothstep(.9+.008*l,.9-.008*l,d)*p; if (keyToggle(64+6)) col0*=(.5+.5*sin(100.*d));
           col0.a = smoothstep(.9+.008*l,.9-.008*l*(1.-abs(t)),d);
        col = col0 + (1.-col0.a)*col;
        l /= z;
        uv *= m;  if (keyToggle(32)) uv.y -= .02*l;
    }
    
	fragColor = col;
}