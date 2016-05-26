// Shader downloaded from https://www.shadertoy.com/view/lsGGRc
// written by shadertoy user jviedma
//
// Name: San PGATR shader
// Description: This shader represents my friend's treacherous love triangle ;)
//    
//    Javier Viedma
//    &Aacute;lvaro Rosa
//    
vec4 pintaCorazon(vec2 uv, vec2 despl,vec4 color1 ,vec4 color2, vec4 color3, vec4 bgColor, float tamano, float brightradius,vec2 brightcenter, float maximo, float minimo)
{
    //Corazon: no es un corazon de nadie, es nuestro propio: j.viedma y a.rosa
    

    vec2 q = uv + despl;
    vec2 center = vec2(0.0,0.0)- despl;
    
    float tamanobase = mix(minimo,maximo,tamano);
    
    float arturadelpedaso = mix(0.4,0.6,sin(tamano*3.14*2.));
    float anchuradelpedaso = mix(1.4,1.7,sin(tamano*3.14*1.));
    float aperturadelpedaso = mix(1.7,2.0,sin(tamano*3.14*2.));
    float larguradelpedaso = mix(0.3,0.25,sin(tamano*3.14*1.));
    
    float radius = (tamanobase + 0.25*cos(sin(q.y*anchuradelpedaso)/cos(q.x)*aperturadelpedaso -6.*abs(sin(q.x))) + larguradelpedaso *(sin(3.14*q.y+arturadelpedaso))); //esta es la función que define el corazon
    
    float brightdiffuse = 0.1 + clamp(0.11,0.15,tamano); //modifica esto para hacer el brillo mas difuso o menos
    
    vec4 HeartColor = mix(color2,color3,(length(q+brightcenter)));
    HeartColor = mix(color1,HeartColor,smoothstep(brightradius-brightdiffuse,brightradius+brightdiffuse,sqrt(length(q+brightcenter))));
	
    
    float val = smoothstep(radius+0.01,radius-0.01,length(uv-center)); //aqui se pinta el corazón y sus colores
    return mix(bgColor,HeartColor,val);
}

vec4 pintaFondo(vec2 uv, vec4 color1 ,vec4 color2,vec2 posluz)
{
    return  mix(color1,color2,smoothstep(0.0,2.0,sqrt(length(uv-posluz))));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x = uv.x * iResolution.x/iResolution.y;
    
    //Colorines
    vec4 pink = vec4(1.0,.6,0.6,1.0);
    vec4 purple = vec4(.6,.0,0.5,1.0);
    vec4 darkpurple = vec4(.3,.0,0.2,1.0);
    vec4 red = vec4(1.0,0.0,0.0,1.0);
    vec4 red2 = vec4(0.4,0.1,0.01,1.0);
    vec4 white = vec4(1.0,1.0,1.0,1.0);
    vec4 bg = vec4(0.2,0.2,0.2,0.2);
    
    //Color de fondo
    vec4 ret = pintaFondo(uv, pink ,darkpurple, vec2(sin(iGlobalTime)*atan(iGlobalTime)*0.2+0.7,cos(iGlobalTime)*0.2+0.7));
    //ret = mix(ret , pintaFondo(uv,bg,purple, vec2(-0.7,-0.7)),smoothstep(0.4,1.0,sqrt(length(vec2(0.7,0.7)-vec2(-0.7,-0.7)))));
    
    
    
    //Corazoncitos
    float velocidadlatido = 3.; //Con esto se controla la velocidad del latido
    float velocidadlatido2 = 5.;
    
    float time = smoothstep(0.5,1.,1.5*sin(iGlobalTime*velocidadlatido));
    float minitime = smoothstep(0.5,1.,1.5*sin(iGlobalTime*velocidadlatido2));
    
    
    ret = pintaCorazon(uv, vec2(cos(iGlobalTime+3.14),sin(iGlobalTime+3.14)),white,pink,purple,ret,clamp(0.1,0.4,minitime),0.3,vec2(-0.2,-0.3),0.1,0.4);
    
    ret = pintaCorazon(uv, vec2(0.0,0.2),white,red,red2,ret,time,0.3,vec2(-0.3,-0.4),0.5,0.65);
    
    ret = pintaCorazon(uv, vec2(1.2*cos(iGlobalTime),1.1*sin(iGlobalTime)),white,pink,purple,ret,clamp(0.1,0.4,minitime),0.3,vec2(-0.2,-0.3),0.1,0.4);

    
	fragColor = ret;
}