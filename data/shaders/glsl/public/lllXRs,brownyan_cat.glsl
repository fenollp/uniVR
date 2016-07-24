// Shader downloaded from https://www.shadertoy.com/view/lllXRs
// written by shadertoy user Patapom
//
// Name: Brownyan Cat
// Description: Nyan!
// Silly Brownyan Cat ^._.^
//
float hash(vec2 p) { return fract(21654.65155 * sin(35.51 * p.x + 45.51 * p.y)); }

float noise(vec2 p) {
	vec2 fl = floor(p);
	vec2 fr = fract(p);
	fr.x = smoothstep(0.0,1.0,fr.x);
	fr.y = smoothstep(0.0,1.0,fr.y);	
	float a = mix(hash(fl + vec2(0.0,0.0)), hash(fl + vec2(1.0,0.0)),fr.x);
	float b = mix(hash(fl + vec2(0.0,1.0)), hash(fl + vec2(1.0,1.0)),fr.x);
	return mix(a,b,fr.y);
}

float fbm(vec2 p) {
	float v = 0.0, f = 1.0, a = 0.6;
	for ( int i = 0; i < 5; i++ ) {
		v += noise(p * f) * a;
		f *= 2.0;
		a *= 0.5;
	}
	return v;
}

vec4 Nyan( in vec2 _uv, vec2 _Position, vec2 _Direction, float _Size, float _Slice ) {
    vec2	lsPos = vec2( (_uv.x - _Position.x) / _Size, (_uv.y - _Position.y) / _Size );
	vec2	X = vec2( _Direction.x, _Direction.y );
    vec2	Y = vec2( -_Direction.y, _Direction.x );
    vec2	UV = clamp( vec2( (32.0 / 40.0) * dot( lsPos, X ) + 0.5, 0.5 - dot( lsPos, Y ) ), 0.0, 1.0 );
	   		UV.x = (UV.x + floor( mod( _Slice, 6.0 ) )) * 40.0 / 256.0;
    return texture2D( iChannel0, UV );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2	uv = vec2( fragCoord.x / iResolution.x, fragCoord.y / iResolution.x );
    		uv -= vec2( 0.5, 0.5 * iResolution.y / iResolution.x );

    // Ludicrous speed!
    float	time = 1.5 * iGlobalTime;
    float	t = time - floor( time );
    		time -= t;
    		t -= 0.5;
    		t = sign(t) * pow( 2.0 * abs(t), 2.0 );
    		time += 0.5 * (t-1.0);
    
    float	size = mix( 0.002, 0.4, fbm( vec2( time ) ) );
    vec2	pos = vec2( 0.2/size * (2.0 * fbm( vec2( time ) ) - 1.0), 0.1/size * (2.0 * fbm( vec2( 1378.09 + time ) ) - 1.0) );
    float	a = 6.28 * (2.0 * fbm( vec2( 17.8 + time ) ) - 1.0);
    vec2	dir = vec2( cos( a ), sin( a ) );
    
	fragColor = Nyan( uv, pos, dir, size, 10.0 * iGlobalTime );
    fragColor = mix( vec4(13,66,121,255)/255.0, fragColor, fragColor.w );
}
