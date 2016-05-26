// Shader downloaded from https://www.shadertoy.com/view/4dVXWh
// written by shadertoy user Serenus
//
// Name: Phong/Gouraud Shader Comparison
// Description: Based on one of the Shadertoy samples, this shows the differences between Phong shading (on the left) and Gouraud shading (on the right).
// ray marching
const int max_iterations = 255;
const float stop_threshold = 0.001;
const float grad_step = 0.1;
const float clip_far = 1000.0;

// math
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

// distance function
float dist_sphere( vec3 pos, float r ) {
	return length( pos ) - r;
}

float dist_box( vec3 pos, vec3 size ) {
	return length( max( abs( pos ) - size, 0.0 ) );
}

// get distance in the world
float dist_field( vec3 pos ) {
	// ...add objects here...
	
	// object 0 : sphere
	float d0 = dist_sphere( pos, 2.7 );
	
	// object 1 : cube
	float d1 = dist_box( pos, vec3( 2.0 ) );
		
	// union     : min( d0,  d1 )
	// intersect : max( d0,  d1 )
	// subtract  : max( d1, -d0 )
	return max( d1, -d0 );
}

// gouraud shading
vec3 g_shading(vec3 v, vec3 n, vec3 eye)
{
    vec3 final = vec3(0.0);
    
	vec3 ev = normalize( v - eye );
	vec3 ref_ev = reflect( ev, n );
    
	// light 0
    {
		vec3 light_pos   = vec3( 20.0, 20.0, 20.0 );
		vec3 light_color = vec3( 1.0, 0.7, 0.7 );
        
        float dist = length(light_pos - v);
        
        vec3 light_vec = normalize(light_pos - v);
        
        float diffuse = max(dot(n, light_vec), 0.1);
        float specular = max(dot(ref_ev, light_vec), 0.1);
        specular = pow(specular, 16.0);
        
        final += (diffuse + specular) * light_color;
    }
    
    // light 1
    {
		vec3 light_pos   = vec3( -20.0, -20.0, -20.0 );
		vec3 light_color = vec3( 0.3, 0.7, 1.0 );
        
        float dist = length(light_pos - v);
        
        vec3 light_vec = normalize(light_pos - v);
        
        float diffuse = max(dot(n, light_vec), 0.1);
        float specular = max(dot(ref_ev, light_vec), 0.1);
        specular = pow(specular, 16.0);
        
        final += (diffuse + specular) * light_color;
    }
    
    return final;
}

// phong shading
vec3 p_shading( vec3 v, vec3 n, vec3 eye ) {
	// ...add lights here...
	
	float shininess = 16.0;
	
	vec3 final = vec3( 0.0 );
	
	vec3 ev = normalize( v - eye );
	vec3 ref_ev = reflect( ev, n );
	
	// light 0
	{
		vec3 light_pos   = vec3( 20.0, 20.0, 20.0 );
		vec3 light_color = vec3( 1.0, 0.7, 0.7 );
	
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse + specular ); 
	}
	
	// light 1
	{
		vec3 light_pos   = vec3( -20.0, -20.0, -20.0 );
		vec3 light_color = vec3( 0.3, 0.7, 1.0 );
	
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse + specular ); 
	}

	return final;
}

// get gradient in the world
vec3 gradient( vec3 pos ) {
	const vec3 dx = vec3( grad_step, 0.0, 0.0 );
	const vec3 dy = vec3( 0.0, grad_step, 0.0 );
	const vec3 dz = vec3( 0.0, 0.0, grad_step );
	return normalize (
		vec3(
			dist_field( pos + dx ) - dist_field( pos - dx ),
			dist_field( pos + dy ) - dist_field( pos - dy ),
			dist_field( pos + dz ) - dist_field( pos - dz )			
		)
	);
}

// ray marching
float ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	float depth = start;
	for ( int i = 0; i < max_iterations; i++ ) {
		float dist = dist_field( origin + dir * depth );
		if ( dist < stop_threshold ) {
			return depth;
		}
		depth += dist;
		if ( depth >= end) {
			return end;
		}
	}
	return end;
}

// get ray direction
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, -z ) );
}

// camera rotation : pitch, yaw
mat3 rotationXY( vec2 angle ) {
	vec2 c = cos( angle );
	vec2 s = sin( angle );
	
	return mat3(
		c.y      ,  0.0, -s.y,
		s.y * s.x,  c.x,  c.y * s.x,
		s.y * c.x, -s.x,  c.y * c.x
	);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// default ray dir
	vec3 dir = ray_dir( 45.0, iResolution.xy, fragCoord.xy );
	
	// default ray origin
	vec3 eye = vec3( 0.0, 0.0, 10.0 );

	// rotate camera
	mat3 rot = rotationXY( vec2( 0.25 * iGlobalTime ) );
    //mat3 rot = rotationXY(vec2(0.25 * iGlobalTime, -0.6));
    dir = rot * dir;
	eye = rot * eye;
	
	// ray marching
	float depth = ray_marching( eye, dir, 0.0, clip_far );
	if ( depth >= clip_far ) {
	    fragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
        return;
	}
	
	// shading
	vec3 pos = eye + dir * depth;
	vec3 n = gradient( pos );
    fragCoord.xy /= iResolution.xy;
    
    if (fragCoord.x > 0.5)
    {
		fragColor = vec4( g_shading( pos, n, eye ), 1.0 );
    }
    else
    {
        fragColor = vec4( p_shading( pos, n, eye ), 1.0 );
    }
    
    if (fragCoord.x > 0.499 && fragCoord.x < 0.501)
    {
    	fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}