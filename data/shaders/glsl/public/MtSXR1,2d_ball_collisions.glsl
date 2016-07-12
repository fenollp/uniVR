// Shader downloaded from https://www.shadertoy.com/view/MtSXR1
// written by shadertoy user archee
//
// Name: 2d ball collisions
// Description: simplified continuously timed 2D ball physics with bounce sounds.
// please don't  change any constants :)
float gravity = 1.2;  // gravity value 
float bounceRatio = 0.8; // vertical speed multiplied by this at every bounce
float diskrad = 0.05;
float decayx = 0.2;

const int ballCount = 3;
vec4 balldatas[ballCount];
float balldatatimeshift[ballCount];
vec3 ballcolors[ballCount];
const bool debugCollis = false;
vec3 color=vec3(0.0);
vec2 uv;
float time;

float soundout=0.0; // ignored in the image shader file

void disk(vec2 pos,float radius,vec3 color2) // AA disk
{
    color = mix(color2,color,clamp((length(pos-uv)-radius)*iResolution.y+0.5,0.0,1.0)); 
}

vec4 extrapolate(vec4 inp, float querytime)
{
    // this is compile time calculation, until the time value comes in
    float startx = inp.x;
    float starty = inp.y;
    float startvelx = inp.z;
    float startvely = inp.w;
    
    float startmaxheight = starty+startvely*startvely*0.5/gravity;
    float startbouncetime = sqrt(startmaxheight*8.0/gravity);
    float startbouncestarttime = startbouncetime/(1.0/bounceRatio-1.0);
    float startbouncecount = log(startbouncestarttime)/log(1.0/bounceRatio);
    float startphase = fract(startbouncecount);
    float startfloorvel = startbouncetime*gravity*0.5;
    float starttime = pow(1.0/bounceRatio,startbouncecount+0.999) - startbouncetime*(startvely/startfloorvel*-0.5+0.5);
    
    // bounce timing follow a logarythmic pattern
    float ltime = max(starttime-querytime,0.01);
    float bouncecount = floor(log(ltime)/log(1.0/bounceRatio)-startphase)+startphase;
    float bouncestarttime = pow(1.0/bounceRatio,bouncecount);
    float bouncetime = (bouncestarttime)*(1.0/bounceRatio-1.0);
    float f = (ltime-bouncestarttime)/bouncetime;
    float y = f*(1.0-f)*bouncetime*bouncetime*gravity*0.5;
    float vely = bouncetime*gravity*0.5*(f*2.0-1.0);
    
//    float maxheight = bouncetime*bouncetime*gravity/8.0;
//    if ( abs(maxheight-uv.y)<0.01 ) color.y=0.5;
//    if ( abs(starty-uv.y)<0.01 ) color.z=0.5;
    
    // bouncing on the side walls is fully elastic, just need to mirror them 
    float x = (1.0-exp(-querytime*decayx))*(startvelx/decayx)+startx;
    float velx = exp(-querytime*decayx)*startvelx;
    float stime2 = 0.0;
    if (x>0.0) // balls start outside the walls, negative X means no need to mirror it
    {
        if (x>0.5) stime2 = velx<0.0?  fract(-x)/-velx : fract(x)/velx;
        x = mod(x,2.0);  // bounce left wall
        if (x>1.0)  
        {
            x=2.0-x; // bounce right wall
            velx *= -1.0;
        }
    }
    
    float stime = bouncetime-(ltime-bouncestarttime);
    soundout+=clamp(sin(stime*(0.2-stime)*7000.0)*exp(stime*-60.0)*pow(bouncetime,0.7)*4.0,-0.3,0.3); // botton floor bounce sound
    soundout+=clamp(sin(stime2*(0.2-stime2)*5000.0)*exp(stime2*-60.0)*4.0,-0.3,0.3); // wide wall bounce sound
    
    return vec4(x,y,velx,vely);
}

void collisSound(float starttime) // ball vs ball collision sound
{
    float stime = time-starttime;
    soundout+=clamp(sin(stime*(0.18-stime)*10000.0)*exp(stime*-50.0)*3.0,-0.4,0.4);
}


// won't work as a function
// this function finds out the balls position and velocity at a given timepoint
// find the velocities after a collision
// then sets up their parameter to start from their actual position with the new velocity
#define collis(balla,ballb,collistime)     if (time>collistime) { collisSound(collistime);   vec4 resa = extrapolate(balldatas[balla],collistime-balldatatimeshift[balla]);    vec4 resb = extrapolate(balldatas[ballb],collistime-balldatatimeshift[ballb]);    vec2 bouncenormal = normalize((resa.xy-resb.xy));    vec2 bouncepos = (resa.xy+resb.xy)*0.5;    if (debugCollis) disk(bouncepos,0.003,vec3(0.0));    vec2 midvel = (resa.zw+resb.zw)*0.5;    vec2 newvela = resa.zw-midvel;    newvela -= bouncenormal*dot(bouncenormal,newvela)*(bounceRatio+1.0);    vec2 newvelb = resb.zw-midvel;    newvelb -= bouncenormal*dot(bouncenormal,newvelb)*(bounceRatio+1.0);    resa.x += 30.0;    resb.x += 30.0;    balldatas[balla] = vec4(resa.xy,newvela+midvel);    balldatas[ballb] = vec4(resb.xy,newvelb+midvel);    balldatatimeshift[balla] = collistime;    balldatatimeshift[ballb] = collistime;    }

void rundemo(float timein) 
{
    timein = mod(timein,30.0);
    
    ballcolors[0] = vec3(0.9,0.0,0.0);
    ballcolors[1] = vec3(0.8,0.5,0.0);
    ballcolors[2] = vec3(0.1,0.6,0.0);
    
    balldatas[0] = vec4(-0.2,0.5,0.5,0.5);
    balldatatimeshift[0] = 0.0;
    balldatas[1] = vec4(-0.2,0.7,0.7,0.5);
    balldatatimeshift[1]= 0.0;
    balldatas[2] = vec4(-0.4,0.7,0.6,0.6);
    balldatatimeshift[2]= 0.0;
        
    color = vec3(1.0);
    time = timein-1.5;
    
    float cameramove = pow(max((-time+2.0)/4.0,0.0),2.0);
    uv/=1.2;//clamp(timein-1.0,0.9,1.2);   // zoom
    uv.x += 0.5-cameramove*1.5; // scroll world
    uv.y -= 0.07;
    

    // precomputed collision ball vs ball times  note: wall collisions are fully automatic
    collis(0,2,1.545);
    collis(0,2,2.687);
    collis(1,2,3.563);
    collis(0,2,3.86);
    collis(0,2,4.22);
    collis(1,2,5.34);
    collis(0,2,6.00);
    collis(0,2,7.93);
    collis(1,2,10.09);
    collis(0,2,12.73);
    collis(1,2,16.57);
}

// the part above this line is copied to the sound shader file

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	uv = fragCoord.xy / iResolution.xy;
    uv.x -= 0.5;
    uv.x*=16.0/9.0;
  
    
    rundemo(iGlobalTime);
    if (uv.x>1.0+diskrad+0.02 || (uv.y>0.5 && time>3.0)) // optimization for the area where balls never go
    {
        fragColor = vec4(1.0);
        return;
    }
    
    // render balls
    for(int i=0;i<ballCount;i++)
    {
        vec4 res = extrapolate(balldatas[i],time-balldatatimeshift[i]);
        disk(res.xy,diskrad,ballcolors[i]);
    }
    
    // render walls and floor
    if ( abs(abs(uv.x-0.5)-0.5-diskrad-0.01)<0.01 && uv.y<0.5 && uv.y>-diskrad ) color=vec3(0.0);
    if (  abs(uv.x-0.1) < 0.9+diskrad && uv.y<0.0-diskrad && uv.y>-0.02-diskrad) color=vec3(0.0);
    
	fragColor = vec4(color,1.0);
}