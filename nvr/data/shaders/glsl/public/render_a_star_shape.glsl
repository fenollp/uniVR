// Shader downloaded from https://www.shadertoy.com/view/4tfGWr
// written by shadertoy user stebi
//
// Name: render a star shape
// Description: render a star shape
// Parameters to play with:
const float segments = 5.0;
const float indent = 0.08;
const float softness = 0.6;

// constants
const float pi = 3.141592654;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    // vec2 q = p - vec2(iMouse.x / iResolution.x, iMouse.y / iResolution.y);
    vec2 q = p - vec2(0.5, 0.5);
    q *= normalize(iResolution).xy; // maintain aspect ratio

    // Rotation
    float startAngle = iGlobalTime * 0.7;
    mat4 RotationMatrix = mat4( cos( startAngle ), -sin( startAngle ), 0.0, 0.0,
			    sin( startAngle ),  cos( startAngle ), 0.0, 0.0,
			             0.0,           0.0, 1.0, 0.0,
				     0.0,           0.0, 0.0, 1.0 );    
    q = (RotationMatrix * vec4(q, 0.0, 1.0)).xy;

    float distance = length(q);
    float progress = (sin(iGlobalTime) + 1.0) / 2.0;
    
    vec4 col;
    col = texture2D( iChannel0, q).xyzw;

    
    float angle = (atan(q.y, q.x) + pi) / (2.0 * pi); // 0-1
    
    float segment = angle * segments;
    
    
    float segmentI = floor(segment);
    float segmentF = fract(segment);
        
    angle = (segmentI + 0.5) / segments;
    if (segmentF > 0.5) {
		col *= vec4(1.0, .9, 0.6, 1.0);
        angle -= indent;
    } else
    {
		col *= vec4(1.0, 0.5, 0.5, 1.0);
        angle += indent;
    }
    angle *= 2.0 * pi;

	vec2 outline;
	outline.y = sin(angle);
    outline.x = cos(angle);

	// Distance Point/Line (Hessische Normalform)
	distance = abs(dot(outline, q));
    
    col *= smoothstep(progress, progress + softness * progress, distance * 6.0);

    vec4 starcol = texture2D( iChannel1, (RotationMatrix * vec4(q, 0.0, 1.0)).xy).xyzw; 
    starcol = mix(starcol, vec4(2.0, 2.0, 1.0, 1.0), 0.5);
    col = mix(starcol, col, col.w);
    fragColor = vec4((col));
}