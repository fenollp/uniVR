// Shader downloaded from https://www.shadertoy.com/view/MddGRS
// written by shadertoy user skaven
//
// Name: Cloud shader
// Description: Some kind of schematic cloud.
float sphere(vec2 spherePos, vec2 pos, float radius)
{
    vec2 df = spherePos-pos;
    return max((radius - sqrt(dot(df,df)))/radius,0.0);
}


vec2 rotate(vec2 xy, float angle)
{
    float sn = sin(angle);
    float cs = cos(angle);
    return vec2(xy.x*cs-xy.y*sn, xy.y*cs + xy.x*sn);
}

float hash( float n ) { return fract(sin(n)*753.5453123); }


float udBox( vec2 p, vec2 b )
{
  return length(max(abs(p)-b,0.0));
}

float cloud(vec2 uv)
{
    float intensity = sphere(vec2(0.0), uv, 0.2);
    
    for (int i=0;i<10;i++)
    {
        float ifl = float(i);
        vec2 sph = vec2(hash(ifl), hash(ifl+67.47))*0.3;
    	intensity = max(intensity, sphere(rotate(sph.xy,(hash(ifl+18.47)*0.3 + 0.05)*iGlobalTime) , uv, hash(ifl+119.47)*0.16+0.05));
    }
    intensity = min(intensity, uv.y*10.0);
    intensity = max(intensity, (0.02-udBox(uv, vec2(0.5,0.01))) * 10.0);
    
    return intensity;
}

float cloudSat(vec2 uv)
{
    float intensity = cloud(uv);
    
    return mix( 0.0, 1.0, smoothstep(0.06, 0.1, intensity));
}
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
    uv *= vec2(iResolution.x/iResolution.y, 1.0);
    uv *= 0.7;
    uv.y += 0.175;
    
    
    float occCloud = 0.0;
    for (float y = -2.0; y<2.0;y+=0.5)
    {
        for (float x = -2.0; x<2.0;x+=0.5)
        {
            occCloud += cloud(uv*0.8 + vec2(x,y)*0.025 + vec2(0.08));
        }
	}
    occCloud = smoothstep(0.0,12.0,occCloud);
    

    vec3 skyColor = vec3(0.25,0.26,0.8);
    vec3 col = mix(skyColor, skyColor*0.5, occCloud);
        
    col = mix(col, vec3(1.0), cloudSat(uv));
    //col = vec3(occCloud);
	fragColor = vec4(col,1.0);
}