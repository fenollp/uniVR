// Shader downloaded from https://www.shadertoy.com/view/Xt2GRD
// written by shadertoy user ap
//
// Name: ripple7
// Description: simple shader
// Copyright (c) 2015, shadertoy user ap. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of ap nor the names of its
//    contributors may be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

float sinc(float r, float width)
{
    width *= 10.0;
    
    float scale = 1.0;
    
    float N = 1.1;
    float numer = sin(r / width);
    float denom = (r /width);
    
    if(abs(denom) <= 0.1 ) return scale;
    else return scale * abs(numer / denom);
}

float expo(float r, float dev)
{
    return 1.0 * exp(- r*r / dev);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy);
    float aspect = iResolution.x / iResolution.y;
    uv.x *= aspect;
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0); 
       
    vec2 cdiff = abs(uv - 0.5 * vec2(aspect, 1.0));
    
    
    float myradius = length(cdiff) * mix(1.0, texture2D( iChannel0, uv ).r, 0.02);//max(cdiff.x, cdiff.y);
    
    vec3 wave = texture2D( iChannel0, vec2(myradius, 0.25) ).rgb;
    
    float radius =1.5 * (iGlobalTime)/3.0; 
   
    float r = sin((myradius - radius) * 5.0);
     
    r = r*r;
    
    vec3 dev = wave * vec3(1.0/500.0, 1.0/500.0, 1.0/500.0);
      
    fragColor = vec4(sinc(r, dev.x), sinc(r, dev.y), sinc(r, dev.z), 1.0);
    
    float siny = sin(fragCoord.y/1.5);
    
    fragColor =  fragColor * vec4(1.0 - 0.5*siny*siny);
    
    fragColor = mix(fragColor, 
        vec4(
            texture2D(iChannel1, uv / 1000.0).xy * 0.3, 
            0.7 * sin(iGlobalTime) * sin(iGlobalTime), 0.0), 0.5);
    
}