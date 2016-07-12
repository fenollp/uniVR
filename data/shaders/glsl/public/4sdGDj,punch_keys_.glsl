// Shader downloaded from https://www.shadertoy.com/view/4sdGDj
// written by shadertoy user elias
//
// Name: Punch Keys!
// Description: Press numbers 1 through 4 (or change the amount of columns). You can also change the difficulty in Buf A.
//    
//    If the audio won't load: open iChannel2 in Buf A, click on the SoundCloud button, press enter and then play with the audio controls until it works.
// TODO
// - fix row scaling/alignment
// - prevent cheating by holding down the keys
// - maybe add longer/stretched beats

// Font by Flyguy (Bit Packed Sprites)
// https://www.shadertoy.com/view/XtsGRl

#define S 0.8 // scaling
#define N 4.0 // columns (change in buffers too)
#define M 8.0 // rows    (change in buffers too)

//#define ORTHOGRAPHIC_VIEW

#ifndef ORTHOGRAPHIC_VIEW
    #define NEAR 0.05
    #define FAR  1.8
#else
    #define NEAR 0.0
    #define FAR  100.
#endif

#define T sound_info.x
#define load(a,b) texture2D(b,(fract(a.x)==0.1?vec2(fragCoord.x,a.y+0.5):(a+0.5))/iResolution.xy)

const vec2 bufA_sound_info_uv = vec2(0.0,0);
const vec2 bufA_sound_freq_uv = vec2(0.1,1);

float sdLine(vec2 p, vec2 a, vec2 b, float r)
{
    vec2 ab = b-a;
    vec2 ap = p-a;
    return length(ap-ab*clamp(dot(ap,ab)/dot(ab,ab),0.,1.))-r;
}

float sdBox(vec2 p, vec2 q, vec2 s)
{
    vec2 d = abs(p-q)-s;
    return min(max(d.x,d.y),0.0)+length(max(d,0.0));
}

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uva = (2.*fragCoord.xy - iResolution.xy)/iResolution.yy;
    float a = iResolution.x/iResolution.y;
    
    float d = 1e10;
    float n = 0.0;
    
    float dboard = 1e10;
    float dblack = 1e10;
    float dfrets = 1e10;
    
    vec4 sound_info  = load(bufA_sound_info_uv, iChannel0);
    float sound_freq = load(bufA_sound_freq_uv, iChannel0).x;
    
    float cw = S/N;
    float cs = 1.-max(uv.y-NEAR,0.)/(FAR-NEAR);

    float top    = (FAR-0.5)*2.;
    float bottom = (NEAR-0.5)*2.;
    
    // font
    fragColor = vec4(texture2D(iChannel1,uv).x);
    
    // columns
    for(float i = 0.; i < N; i++)
    {
        vec2 pa = vec2((2.*i-N+1.)*cw,bottom);
        vec2 pb = vec2(0,top);
        vec2 pc = vec2(pa.x*cs,pa.y+cw);
        
        dboard = min(dboard,d=sdLine(uva,pa,pb,cw*cs));
        
        // border
        dblack = min(dblack,sdLine(vec2(abs(uva.x),uva.y),pa+vec2(cw,0),pb,cs*0.025));

        // sockets
        dblack = min(dblack, max(length(uva-pc)-cw*0.6,-(length(uva-pc)-cw*0.4)));
        
        if (dboard==d) { n = i; }
    }
    
    // bridge
    dboard = min(dboard,sdBox(uva,vec2(0,bottom-0.5/N),vec2(S,0.5/N)));

    // border/frets
    {
        float t = 1./(M+1.);
        
        dblack = min(dblack, sdBox(uva,vec2(0,bottom-cw),vec2(S+S/N,cw)));
        dfrets = sdLine(vec2(uv.x,mod((mod(uv.y,t)+T)/t,1.)),vec2(0,0.5),vec2(a,0.5),cs*0.05);
        dfrets = 1.-smoothstep(dfrets,dfrets+0.01,0.0);
    
        // key press indicator
        if (texture2D(iChannel3,vec2(49.5+n,0.5)/256.).x > 0.0)
        {
            vec2 p = vec2((n/(N-1.)-0.5)*2.*cw*(N-1.)*cs,bottom)+vec2(0,cw);
        
            dblack = min(dblack,length(uva-p)-cw*cs*0.4);
        }
        
        if (uva.y<bottom+2.*cw) { dfrets = 1.; }
    }
    
    // beats
    {
        for(float i = 0.; i < N; i++)
        {
            
            for(float j = 0.; j < M; j++)
            {               
                vec4 beat = load(vec2(j,i+3.),iChannel0);
                if (beat.w == 0.0) { continue; }

                float r = cw*(1.-max(uv.y-NEAR,0.)/(FAR-NEAR));
                vec2 pa = vec2((2.*i-N+1.)*r,bottom+cw);
                vec2 pb = vec2(pa.x,top);

                #ifdef ORTHOGRAPHIC_VIEW
                pb.y = 1.-r;
                #endif

                dblack = min(dblack, length(uva-pb-(pa-pb)*(beat.x+T))-r*0.5);
            }
        }

    }
    
    float f = 0.5*pow(abs(dboard/0.1),0.2)*clamp(pow(uv.y+0.5,0.5),0.,1.);
    vec3 bg = vec3((1.-sound_freq*0.5)>uv.y?f*0.5:f) -pow(length(uva*0.5),2.)*0.2;//*(1.-pow(sound_info.y,5.));

    // background
    if (dboard>0.0)
    {
        fragColor.rgb += bg;
        return;
    }

    float hit = texture2D(iChannel0,vec2(n+0.5,2.5)/iChannelResolution[0].xy).x;
    float fade = 1.-uv.y;
    
    vec3 col = hit < 0.01
    ? hsv2rgb(vec3(mod(n/N+0.2,1.),0.2,0.8))
    : hsv2rgb(vec3(mod(n/N+0.2,1.),0.2+hit,(0.8+hit)));
    
    dblack = 1.-smoothstep(dblack,dblack+0.01,0.0);
    
    fragColor.rgb += mix(col*dblack*dfrets,bg,1.-fade);
}