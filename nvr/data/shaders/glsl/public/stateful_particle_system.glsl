// Shader downloaded from https://www.shadertoy.com/view/lsy3R1
// written by shadertoy user oks2024
//
// Name: Stateful particle system
// Description: A particle system with basic physics, and mouse interaction.
//    
//    You can tweak the values of the defines to add particles, change their size, etc. With a smaller viewport you can add more particles with a good framerate.
// The total number of particles will be NB_PARTICLES * NB_PARTICLES.
#define NB_PARTICLES 40
#define PARTICLE_SIZE 0.006
#define OPACITY 2.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{ 
    
    vec2 pixelSize = 1.0 / iResolution.xy;
    
	vec2 uv = fragCoord.xy * pixelSize;
    
    vec3 finalColor = vec3(0.0);
    
    int resx = int(iResolution.x);
    int resy = int(iResolution.y);
    
    // Read each pixels of the position texture to find if some of them are 
    // close from the current pixel.
    for (int x = 0; x < NB_PARTICLES; x++)
    {
        for (int y = 0; y < NB_PARTICLES; y++)
        {
            // This is the bottleneck of the shader, there might be a
            // better way to read the particle textures.
            vec4 currentParticle = texture2D(iChannel0, vec2(x, y) * pixelSize);
            vec2 particlePixelVector = currentParticle.xy - uv;
            
            // If a particle is close to this pixel, add its color to the final color.
            if (particlePixelVector.x * particlePixelVector.x + particlePixelVector.y * particlePixelVector.y  < pixelSize.x * PARTICLE_SIZE)
            {
                float val = (currentParticle.z * currentParticle.z + currentParticle.w * currentParticle.w) *0.000001;
                vec3 velocityColor = vec3(-0.25 + val, 0.1, 0.25-val) * OPACITY;
                finalColor += velocityColor.xyz;
            } 
        }
    }
    
	fragColor = vec4(finalColor, 1.0);

    
    
}