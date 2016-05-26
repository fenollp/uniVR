// Shader downloaded from https://www.shadertoy.com/view/4lfSD4
// written by shadertoy user RavenWorks
//
// Name: De-Burn-In
// Description: Use at your own risk :P I just had a burnt-in screen so I figured I'd try it... (I know it's not perfect noise, I can see the 'seams' too, but it should be good enough for these purposes!)
const float pi = 3.14159;

float random(vec2 inPt, float offset){
    const float a = 98765.432;
    const float b = 12345.678;
    const float c = 45678.912;
    const float d = 78945.612;
    
    vec2 p = inPt;
    p -= 5000.0;
    p += iGlobalTime*0.1;
    p += offset;
    p.x += sin(inPt.y);
    p.y += sin(inPt.x);
    
    
    
    float sinvalX = sin(p.x*a*sin(p.x*b));
    float sinvalY = sin(p.y*c*sin(p.y*d));
    
    float sinval = (sinvalX+sinvalY)*0.5;
    
    return sinval;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float channelGap = 500.0;
    vec3 randChans = vec3(random(fragCoord,0.0),random(fragCoord,1.0*channelGap),random(fragCoord,2.0*channelGap));
    float winner = max(max(randChans.r,randChans.g),randChans.b);
    if (winner == randChans.r) {
        fragColor = vec4(1.0,0.0,0.0,1.0);
    } else if (winner == randChans.g) {
        fragColor = vec4(0.0,1.0,0.0,1.0);
    } else {
        fragColor = vec4(0.0,0.0,1.0,1.0);
    }
}