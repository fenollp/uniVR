// Shader downloaded from https://www.shadertoy.com/view/4tXXzM
// written by shadertoy user BiiG
//
// Name: PBR GGX Materials
// Description: Test case for PBR GGX lighting formula
const float cDetailNormalPower = 0.3;

vec3 gv3View = vec3(0.0,0.0,-1.0);
vec3 gv3LightDir = vec3(0.0,0.0,-1.0);
vec3 gv3LightColor = vec3(1.0,1.0,1.0);


float G1V(float NdotV, float k)
{
	return 1.0/(NdotV*(1.0-k)+k);
}

float SpecGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0 )
{
	float SqrRoughness = roughness*roughness;

	vec3 H = normalize(V+L);

	float NdotL = clamp(dot(N,L),0.0,1.0);
	float NdotV = clamp(dot(N,V),0.0,1.0);
	float NdotH = clamp(dot(N,H),0.0,1.0);
	float LdotH = clamp(dot(L,H),0.0,1.0);

	// Geom term
	float RoughnessPow4 = SqrRoughness*SqrRoughness;
	float pi = 3.14159;
	float denom = NdotH * NdotH *(RoughnessPow4-1.0) + 1.0;
	float D = RoughnessPow4/(pi * denom * denom);

	// Fresnel term 
	float LdotH5 = 1.0-LdotH;
    LdotH5 = LdotH5*LdotH5*LdotH5*LdotH5*LdotH5;
	float F = F0 + (1.0-F0)*(LdotH5);

	// Vis term 
	float k = SqrRoughness/2.0;
	float Vis = G1V(NdotL,k)*G1V(NdotV,k);

	float specular = NdotL * D * F * Vis;
    
	return specular;
}

vec3 GetGIReflexion(in vec3 Normal, in float Roughness)
{
    vec3 R0 = textureCube (iChannel1,reflect(-Normal,gv3View) ).rgb;
    vec3 R1 = textureCube (iChannel2,reflect(-Normal,gv3View) ).rgb;
    return mix ( R0, R1, Roughness );
}

vec3 Sphere( in vec2 uv, in vec2 center, in float radius, in float roughness, in float Metallicness )
{        
    vec2 delta = center-uv;
    
    float l = dot ( delta, delta);     
    
    float sqrRadius = radius*radius;
        
    l = ((sqrRadius - l) / sqrRadius);
    l = max ( l, 0.0 );     
    
    float IsInSphere = 1.0-step(l,0.0);
    delta = delta;
    
    // Compute normal
    vec3 normal = vec3(delta.xy/radius,radius-sqrt(l));
    normal = normalize ( normal );   
    
    // Generate UV from normal
    vec2 texUV = normal.xy/normal.z;    
    texUV = texUV+vec2(0.5,0.5);        
    vec3 textureColor = texture2D(iChannel0,texUV).rgb;
    
    // Use albedo R as a tangent space normal map
    normal.xyz += textureColor.r * cDetailNormalPower;
    normal = normalize ( normal );    

    // Compute light contribution
    float Diffuse = dot ( normal, gv3LightDir );
    float Spec = SpecGGX(normal,gv3View,gv3LightDir,roughness,Metallicness);
     
    // Fresnel
    float NdotV = clamp(dot(normal,gv3View),0.0,1.0);
	NdotV = pow(1.0-NdotV,5.0);    
	float Fresnel = Metallicness + (1.0-Metallicness)*(NdotV);

    // Tint lights
    vec3 SpecColor = Spec * gv3LightColor;
    vec3 DiffColor = Diffuse * gv3LightColor * (1.0 - Fresnel);
    
    // Add GI
    const float	cAmbientMin = 0.04;    
    float		ambient = cAmbientMin * (IsInSphere);    
    vec3		ColorAmbient = vec3(ambient,ambient,ambient);
    vec3		GIReflexion = GetGIReflexion ( normal, roughness );
    
    
    ColorAmbient = GIReflexion * cAmbientMin;
        
    vec3 lightSum = max(((DiffColor + SpecColor)*(1.0-cAmbientMin) ),vec3(0.0,0.0,0.0));
       
    return ( lightSum + ColorAmbient + ( Fresnel * GIReflexion ) ) * IsInSphere;
      
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	    
    // Compute normalized UV
    vec2 uv = fragCoord.xy / iResolution.xy;    
    // Adapt coord to aspect ratio
    uv = uv * vec2(1.0,iResolution.y/iResolution.x);
    
    
    // Rotate light
    gv3LightDir = vec3(sin(iGlobalTime),cos(iGlobalTime)+0.2,cos(iGlobalTime));
    gv3LightDir = normalize (gv3LightDir);
        
    // Compute all spheres lighting
    vec3 color = vec3(0.0,0.0,0.0);	
    for ( float Roughness=0.05; Roughness<1.0; Roughness+=0.1)
    {
        for ( float Metallicness=0.05; Metallicness<1.0; Metallicness+=0.1)
        {
            const float Radius = 0.04;
            color += Sphere ( uv,vec2( Roughness , Metallicness*0.8 ), Radius, Roughness, Metallicness );
        }
    }    
    
    
	fragColor = vec4 (color,1.0);
}