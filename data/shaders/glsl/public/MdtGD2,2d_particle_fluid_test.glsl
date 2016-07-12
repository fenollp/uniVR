// Shader downloaded from https://www.shadertoy.com/view/MdtGD2
// written by shadertoy user RavenWorks
//
// Name: 2d particle fluid test
// Description: Messing around with the Multipass capabilities! Started this ages ago, but only finished it now&amp;amp;hellip; The math is a huge kludge, but isn't that half the fun of ShaderToy ;) [b]Press+hold to move the slime.[/b]
//COMPOSITE

const vec3 lightPt = vec3(0.5,0.75,0.0);
const float diffuseCheat = 0.85;
const vec3 baseColor = vec3(0.0,1.0,0.0);
const float specP = 8.0;
const float specA = 0.75;

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    
    vec4 normalData = texture2D(iChannel0,fragCoord/iResolution.xy);
    
    vec3 color = texture2D(iChannel2,fragCoord/iResolution.x).xyz;
    
    if (normalData.a > 0.0) {
        
        vec3 normal = -normalData.xyz;
        vec3 intersectPt = vec3(fragCoord/iResolution.x,1.0-normal.z*0.1);
        vec3 curCameraRayUnit = normalize(intersectPt);//not quite correct but whatever
        
        vec3 lightGap = lightPt-intersectPt;
        vec3 lightGapNorm = normalize(lightGap);
        float litAmt = dot(normal,lightGapNorm);
        litAmt = litAmt*(1.0-diffuseCheat)+diffuseCheat;

        float lightDist = length(lightGap);
        lightDist /= 16.0;
        lightDist = max(lightDist,0.0);
        lightDist = min(lightDist,1.0);
        lightDist = pow(1.0-lightDist,2.0);

        float specular = max(0.0,dot(normalize(lightGapNorm-curCameraRayUnit),normal));

        color *= (-normal.z)*0.75;
        color += baseColor*litAmt*lightDist + pow(specular,specP)*specA;
        
    } else {
    	color.g += (texture2D(iChannel1,fragCoord/iResolution.xy).r > 0.1) ? 0.5 : 0.0;
    }
    
    fragColor = vec4(min(vec3(1.0),color),1.0);
    
}