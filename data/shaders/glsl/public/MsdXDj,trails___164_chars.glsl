// Shader downloaded from https://www.shadertoy.com/view/MsdXDj
// written by shadertoy user GregRostami
//
// Name: Trails - 164 chars
// Description: This is a size reduced version of iq's brilliant Trails shader: https://www.shadertoy.com/view/MsKGWR  ... calling all golfers (Fabrice, coyote, etc) please help me reduce this to one tweet.
// 164 chars - Pattern shifts diagonally
void mainImage(out vec4 o,vec2 u)
{
    o -= o;
    u = u/iResolution.x + (o.a=iDate.w)*.02;
    for(float i=0.;i<3.;i+=.1)
        o += pow(texture2D(iChannel0, u + .04*cos( 8.*u + i + 3.*o.a) ), vec4(5) );
}

/*
// 156 chars -  Pattern doesn't shift
void mainImage(out vec4 o,vec2 u)
{
	u /= iResolution.xy;
    o -= o;
    for(float i=0.;i<3.;i+=.1)
        o += pow(texture2D(iChannel0, u + .04*cos( 8.*u + i + 3.*iDate.w) ), vec4(3) );
	o /= 5.;
}
*/

/*
// iq's original shader - 307 chars
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy + 0.01*iGlobalTime;
    
    vec3 col = vec3(0.0);
    
    for( int i=0; i<35; i++ )
    {
        vec2 off = 0.04*cos( 8.0*uv + 0.07*float(i) + 3.0*iGlobalTime + vec2(0.0,1.0));
        vec3 tmp = texture2D( iChannel0, uv + off ).yzx;
        col += tmp*tmp*tmp;
    }
    
    col /= 5.0;
    
	fragColor = vec4( col, 1.0 );
}
*/