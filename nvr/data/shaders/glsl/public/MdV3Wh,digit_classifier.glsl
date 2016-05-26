// Shader downloaded from https://www.shadertoy.com/view/MdV3Wh
// written by shadertoy user bergi
//
// Name: digit classifier
// Description: not-handwritten digit classifier using a classic feed-forward neural network with back-propagation and stochastic gradient descent learning
/* Neural Net Digit classifier on Shadertoy

   (c) 0x7e0, Stefan Berke

   License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

   Trained to output the correct class for each of 10 digit images

   No hidden layer, simply
   16x16 input -> 10 output
   2560 weights, no bias

   Left image shows current training, 
	 with desired (top) and actual (bottom) net output
   
   Right image is a test,
     with the network output (bottom) 
     and indicator of the cell with the highest output 

   Restart to learn from scratch
   
   *Now FIXED* thanks to eiffie
*/




float inputState(in ivec2 ip)
{
    vec2 p = (vec2(ip) + vec2(0.5, 1.5)) / iChannelResolution[0].xy;
    return texture2D(iChannel0, p).x;
}

float expectedOutputState(in int op)
{
    vec2 p = vec2(float(op)+.5, .5) / iChannelResolution[0].xy;
    return texture2D(iChannel0, p).x;
}

float outputState(in int op)
{
    vec2 p = vec2(float(op)+.5, .5) / iChannelResolution[1].xy;
    return texture2D(iChannel1, p).x;
}

float inputState2(in ivec2 ip)
{
    vec2 p = (vec2(ip) + vec2(16.5, 1.5)) / iChannelResolution[0].xy;
    return texture2D(iChannel0, p).x;
}

float outputState2(in int op)
{
    vec2 p = vec2(float(op)+.5, .5) / iChannelResolution[3].xy;
    return texture2D(iChannel3, p).x;
}

float weight(in int inCell, in int outCell)
{
    ivec2 ip = ivec2(inCell, outCell);
    vec2 p = (vec2(ip) + .5) / iChannelResolution[2].xy; 
    return (texture2D(iChannel2, p).x - .5) * 4.;
}


vec3 classifier(in vec2 uv)
{
    uv /= 10.;
    
    vec3 col = vec3(0.);
    if (uv.x >= 0. && uv.y >= 0. && uv.x < 16. && uv.y < 18.)
    {    
        float v = 0.2 + 0.8 * inputState(ivec2(uv));
		col = vec3(v);
    
    	if (uv.y >= 16. && uv.x <= 10.)
    	{
        	float s = outputState(int(uv));
        	col = vec3(max(0., s), 0., max(0.,-s));
    	}
    	if (uv.y >= 17. && uv.x <= 10.)
    	{
        	float s = expectedOutputState(int(uv));
        	col = vec3(max(0., s), 0., max(0.,-s));
    	}
    
    }
    return col;
}

vec3 testImage(in vec2 uv)
{
    uv /= 10.;
    
    vec3 col = vec3(0.);
    
    if (uv.x >= 0. && uv.y >= 0. && uv.x < 16. && uv.y < 18.)
    {    
    	float v = 0.2 + 0.8 * inputState2(ivec2(uv));
		col = vec3(v);
    
    	// find output cell with highest output
    	float ma = 0.;
    	int outc = 0;
    	for (int i=0; i<10; ++i)
    	{
        	float s = outputState2(i);
        	if (s > ma)
        	{
            	ma = s;
            	outc = i;
        	}
    	}

    	// draw output state
    	if (uv.y >= 16. && uv.x <= 10.)
    	{
        	float s = outputState2(int(uv));
        	col = vec3(max(0., s), 0., max(0.,-s));
    	}
    
    	// draw highest state
    	if (uv.y >= 17. && uv.x <= 10.)
        	col = vec3(outc == int(uv.x) ? 1. : 0.);
    }
    return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    
    vec3 col = classifier(fragCoord.xy - 25.);
	col = max(col, testImage(fragCoord.xy - vec2(300., 25.)));
    
    // render weight matrix
    {
        int inCell = int(fragCoord.x/2. - 10.);
        int outCell = int(fragCoord.y/2. - 130.);
        if (inCell >= 0 && inCell < 256 && outCell >= 0 && outCell < 10)
        {
            float w = 3.*weight(inCell, outCell);
    		col = vec3(max(0., w), 0., max(0.,-w));
        }
    }
    
    fragColor = vec4(col, 1.);
    
	//fragColor = vec4(texture2D(iChannel0, uv/10.).xyz, 1.0);
}