// Shader downloaded from https://www.shadertoy.com/view/ltBSzt
// written by shadertoy user erkaman
//
// Name: sparkle effect
// Description: This simple shader draws a sparkle particle effect.
// Created by Eric Arnebäck - erkaman/2015
// This work is licensed under a 
// Creative Commons Attribution 4.0 International License

/*
This simple shader draws a sparkle particle effect.
Every particle is drawn as a superellipse. 
*/

#define PARTICLE_COUNT 70


float hash( float n ) { return fract(sin(n)*753.5453123); }

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0;
    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

// 2D rotation matrix by approximately 36 degrees.
mat2 m = mat2(0.8, 0.6, -0.6, 0.8);

float fbm(vec2 r) {
      
    
    float f;
    
    // rotate every octave to add more variation. 
    f  = 0.5000*noise( r ); r = r*m*2.01;
    f += 0.2500*noise( r ); r = r*m*2.02;
    f += 0.1250*noise( r ); r = r*m*2.03;
    f += 0.0625*noise( r ); r = r*m*2.01;
    
    return f;   
}

float rand(float co){
    return fract(sin(dot(vec2(co ,co ) ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand_range(float seed, float low, float high) {
	return low + (high - low) * rand(seed);
}


vec3 rand_color(float seed, vec3 col, vec3 variation) {
    return vec3(
        col.x + rand_range(seed,-variation.x, +variation.x),
        col.y + rand_range(seed,-variation.y, +variation.y),
        col.z + rand_range(seed,-variation.z, +variation.z));
}


// Rotation matrix for rotating a point around the origin.
// rot is in radians.
mat2 rot_matrix(float rot) {
    return mat2(    
        cos(rot), -sin(rot),
        sin(rot),  cos(rot)
    );
}


// id = particle id
vec4 sparkle(float time, float id, vec2 q) { 
   
    float lifespan = rand_range(id*1232.23232, 3.0, 4.5);
    
    // pgen = particle generation
    // every time a particle has outlived its lifespan,
    // it is respawned as a new particle at a new position
    // the generation of this new particle is one plus
    // the generation of the old particle. 
    float pgen = float(int(time / lifespan));
    
    // how long the particle of the current generation has lived. 
    float lifetime = time - lifespan * pgen;
    
    // pseed is used to determine the random attributes of the particle.
    // two particles with the same id but different generations
    // are essentially different particles.
    float pseed = id *12.2 + pgen * 50.3;
    
    
    // we globally move all particles in an ellipse at this speed.
    float rot_speed = 0.0454;
    
    // ranges from -0.2 to  0.9
    float xsource = 0.35 + 0.55* cos(time*rot_speed);
    //float xsource = 0.2;
    
    // ranges from -0.40 to 0.15
    float ysource = -0.125 + 0.27500 * sin(time*rot_speed);
    
    // inital particle position.
    vec2 pos =  q - vec2(
            rand_range(pseed*1.3+3.0, xsource - 0.2, xsource + 0.2),   
            rand_range(pseed*113.2+0.6, ysource-0.02, ysource+0.02)          
            );
    
    // particle velocity
    vec2 vel = vec2(  
        rand_range(pseed*-4.4314+123.3243, -0.012, +0.012),       
        rand_range(pseed*-54.3232+33.323043, -0.06, -0.04)        
            );
    
    // move particle based on velocity.
    pos += vel * lifetime;
    
    
    
    // controls the diameter of the superellipse.
    // we vary it over the lifetime to animate the particle.
    float dx = 0.02 + 0.01*sin(9.0*(time+pseed*12.5454));
    float dy = 0.02 + 0.01*sin(9.0*(time+pseed*223.323) );
    
    
    // slightly rotate the superellipse randomly.
    float rot = rand_range(pseed*23.33+3.4353, -0.10, 0.10);
    pos = rot_matrix(rot) * pos;
    
    // every particle is described by a superellipse
    // https://en.wikipedia.org/wiki/Superellipse
    float func =
        pow(abs(pos.x/ (dx)  ), 0.5)  + pow(abs(pos.y/dy), 0.5) - 0.5;
    
    vec4 res;
    
    vec3 start_color = rand_color(pseed *19.3232, 
                         vec3(0.9,0.9,0),
                         vec3(0.4,0.4,0.4)
                         );
    
    // now rgb-value over 1.0 allowed.
    if(start_color.r > 1.0) {
        start_color.r = 1.0;
    } 
    if(start_color.g > 1.0) {
        start_color.g = 1.0;
    }
    
    vec3 end_color;
    
    if(start_color.r < 0.85 && start_color.r < 0.85) {
    
     	end_color = start_color + vec3(0.10);
       
    } else {
        
        end_color = start_color - vec3(0.10);
    }
    
    // slightly vary color over lifetime; 
    // makes for a small blinking effect.
    float f= 1.0/2.0 + (  sin(9.0*(time+12.5454))  ) / 2.0;
    res.xyz = mix(start_color, end_color, f);
    
    
    
    // uncomment this section to overlay a noise function over the particles.
    // this adds more color variation to the individual particles.
    // however, be vary that this is VERY slow. 
    /*
    pos *= 100.0;
      
    vec3 rainbow = vec3(
         fbm(pos + pseed * 10.430 + vec2(0.2,0.1)),
         fbm(pos + pseed * 12.5443 + vec2(0.3554,0.94343)),
         fbm(pos + pseed * -12.12 + vec2(1.8343,13.23454)) 

        );
    
    res.xyz = mix(res.xyz, rainbow, 0.3);
    */
    
    // we use this value to combine the particle with the rest
    // of the image.
    res.w = smoothstep(0.0, 1.1, 1.0-func);
    
    //fade out a particle quickly when its about to die. 
    // but before that time, leave it mostly unchanged.
    f = 0.000976175 * exp(6.93187* (lifetime/lifespan) );
    res.w = mix(res.w, 0.0, f);
    
    return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 
    vec2 p = fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
  
    vec3 col = vec3(0,0,0); // black background color. 

    vec2 q = p - vec2(0.5,0.5);
   
    for(int i = 0; i <PARTICLE_COUNT; i += 1){
       
        // particle id
        float id = float(i);
         
        vec4 res = sparkle(iGlobalTime, id, q);
    
        // combine particle with image.
        col = mix(col, res.xyz, res.w);       
    }
    

    fragColor = vec4(col,1.0);
    
    
}