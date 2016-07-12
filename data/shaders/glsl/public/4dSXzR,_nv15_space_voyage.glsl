// Shader downloaded from https://www.shadertoy.com/view/4dSXzR
// written by shadertoy user antonOTI
//
// Name: [NV15]space voyage
// Description: I let us go to the stars
/**
* - todo:
* - Better paralax
* - Better ship
*/

vec4 stars(in vec2 p)
{
    vec4 col = vec4(0.,0.,.1,1.);
    col += mix(vec4(0.),vec4(1.),step(texture2D(iChannel0,(p*1.2) + vec2(iGlobalTime*.4,.0)*.005).r,.026));
    col += mix(vec4(0.),vec4(1.),step(texture2D(iChannel0,(p*1.56)* vec2(.5,1.) + vec2(iGlobalTime*.1,.0)).r,.025));
    float f = .2;
    vec4 shifted = vec4(1.- f*p.x,0.99,1. - f*(1. -p.x),1.);
    col += mix(vec4(0.),shifted,step(texture2D(iChannel0,(p*1.36) * vec2(.025,1.) + vec2(iGlobalTime*.3,.0)).r,.075));
	return col;
}

float rectangle(vec2 p,vec2 dim,vec2 center,float a)
{
	p.x -= center.x;
	p.y -= center.y;
	float x =  p.x *cos(a) - p.y* sin( a) ;
	float y = p.y *cos(a) + p.x *sin(a) ;
	return step(-dim.x/2.,x)*step(x,dim.x/2.)*step(-dim.y/2.,y)*step(y,dim.y/2.);
}

float logo(in vec2 uv)
{
    uv = uv * iResolution.xy / iResolution.x;
 	float f = step(distance(uv ,vec2(.5,.5)),.1); 
    f -= step(distance(uv ,vec2(.55,.47)),.05);
    f -= step(distance(uv ,vec2(.5,.5)),.09)*.05;
    return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 col = stars(uv) ;
    
    
    
    
    //oscillation
    uv = (uv-vec2(.25)) * ((cos(iGlobalTime * .5)*.5+.5)*.25 +.95) + vec2(.25);
    uv.y += sin(iGlobalTime)*.05;
    
    //shake
    uv += (texture2D(iChannel0,vec2(0.,iGlobalTime)).xy - vec2(.5)) *.02 * (sin(iGlobalTime)*.5+1.);
    
    
    float t = iGlobalTime * 2.09439333;
    vec2 bp  = uv - vec2(.5,.26);
    bp *= vec2(.2 ,(7.5 + uv.x*10.5) *1.6);
    float r = (1.-distance(bp,vec2(cos(t*-9.),sin(t*.3))*.05))*1.25;
    t += 2.0943;
    float g = (1.-distance(bp,vec2(cos(t*-3. ),sin(t + bp.x*4.))*0.05))*1.25;
    t += 2.0943;
    float b = (1.-distance(bp,vec2(cos(t),-sin(t*4.8))*.05 ))*1.25;
    vec4 beam = vec4(r,g,b,1.);
    beam *= step(.18,uv.y)*step(uv.y,.34) * step(uv.x,.3);
    
    col += beam;
    
    //engin
    col = mix(col,vec4(1.-length(uv.y *8. - 2.4)),rectangle(uv + vec2(uv.y * .4,0.),vec2(.1),vec2(.235,.29),0.));
    col = mix(col,vec4(1.-length(uv.y *8. - 1.0)),rectangle(uv + vec2(uv.y * .4,0.),vec2(.1),vec2(.23,.24),0.));
    col = mix(col,vec4(1.-length(uv.y *8. - 1.9)),rectangle(uv + vec2(uv.y * .4,0.),vec2(.1),vec2(.22,.27),0.));
    //back wings
    col = mix(col,vec4(.25),rectangle(uv + vec2(uv.y * -.3,0.),vec2(.12),vec2(.18,.14),0.));
    col = mix(col,vec4(.25),rectangle(uv + vec2(uv.y * -.3,0.),vec2(.05,.04),vec2(.53,.21),0.));
    col = mix(col,vec4(.37),rectangle(uv + vec2(uv.y * .5,0.),vec2(.19,.20),vec2(.40,.41),0.));
    col = mix(col,vec4(.15),rectangle(uv + vec2(uv.y * .5,0.),vec2(.16,.17),vec2(.40,.41),0.));
    //main body
    col = mix(col,vec4(.5),rectangle(uv + vec2(uv.y * .4,0.),vec2(.4,.1),vec2(.5,.3),0.));
    col = mix(col,vec4(.7),rectangle(uv + vec2(uv.y * .4,0.),vec2(.4,.08),vec2(.5,.3),0.));
    col = mix(col,vec4(.5),rectangle(uv + vec2(uv.y * .4,0.),vec2(.3),vec2(.35,.3),0.));
    col = mix(col,vec4(.8),rectangle(uv + vec2(uv.y * .4,0.),vec2(.28),vec2(.35,.3),0.));
    
    col = mix(col,vec4(.9,.9,.9,1.),rectangle(uv + vec2(uv.y * .4), vec2(.28,.04),vec2(.35,.47),0.));
    col = mix(col,vec4(.9,.1,.1,1.),rectangle(uv + vec2(uv.y * .4), vec2(.28,.05),vec2(.35,.5),0.));
    col = mix(col,vec4(.9,.1,.1,1.),rectangle(uv + vec2(uv.y * .4), vec2(.28,.025),vec2(.35,.45),0.));
    
    //head
    col = mix(col,vec4(.5),rectangle(uv + vec2(uv.y * .4,0.),vec2(.18),vec2(.7,.3),0.));
    col = mix(col,vec4(.9),rectangle(uv + vec2(uv.y * .4,0.),vec2(.16),vec2(.7,.3),0.));
    float f = sin((uv.x +.4 * uv.y ) * 10. + iGlobalTime *10.);
    f = smoothstep(f,f+.01,.985);
    col = mix(col,mix(vec4(1.),vec4(.1,.1,.7,0.),f),rectangle(uv + vec2(uv.y * .4,0.),vec2(.07,.06),vec2(.755,.325),0.));
    //front wing
    col = mix(col,vec4(.4),rectangle(uv + vec2(uv.y * -.3,0.),vec2(.14),vec2(.20,.14),0.));
    col = mix(col,vec4(.49),rectangle(uv + vec2(uv.y * -.31,0.),vec2(.115),vec2(.20,.1525),0.));
    col = mix(col,vec4(.4),rectangle(uv + vec2(uv.y * -.3,0.),vec2(.05,.04),vec2(.54,.20),0.));
    col = mix(col,vec4(.58),rectangle(uv + vec2(uv.y * -.3,0.),vec2(.04,.03),vec2(.54,.205),0.));
    
    col = mix(col,vec4(.1,.4,.1,1.),logo(uv*2.- vec2(uv.y * -.3,0.) + vec2(.08,.25)));
    col = mix(col,vec4(.4,.4,.1,1.),logo(uv*4.- vec2(uv.y * -.3,0.) - vec2(1.81,.31)));
    
	fragColor = col;
}