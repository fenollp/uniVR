// Shader downloaded from https://www.shadertoy.com/view/ldc3zN
// written by shadertoy user jcowles
//
// Name: Sphere vs Zomboy
// Description: sphere + bwaaaaa bwaaaaa bwaaa pew pew pew


// ---------------------------------------------------------------------- //
// External code
// ---------------------------------------------------------------------- //
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdCylinder(vec3 p, vec3 c) {return length(p.xz-c.xy)-c.z;}
float sdSphere(vec3 p, float s) {return length(p)-s;}
// http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);float s = sin(angle);float c = cos(angle);float oc = 1.0 - c;
    return mat4(oc*axis.x*axis.x+c,       oc*axis.x*axis.y-axis.z*s,oc*axis.z*axis.x+axis.y*s,0.0,
                oc*axis.x*axis.y+axis.z*s,oc*axis.y*axis.y+c,       oc*axis.y*axis.z-axis.x*s,0.0,
                oc*axis.z*axis.x-axis.y*s,oc*axis.y*axis.z+axis.x*s,oc*axis.z*axis.z+c,       0.0,
                0.0,0.0,0.0,1.0);
}
// ---------------------------------------------------------------------- //

float bumpAmt = 0.0;
float strobeAmt = 10.0;
float globalTime = 0.0;
float darkAmt = 0.0;
float lightAmt = 0.0;
vec4 _m;

float noise1(vec2 uv){
	return texture2D(iChannel1, uv).x;   
}
float noise1s(vec2 uv){
	return noise1(uv)*2.0 - 1.0;
}
vec4 getMusic(){
    return _m;
}
vec4 blinnPhong(vec3 l, vec3 p, vec3 n, vec3 c)
{
    // Diffuse
    vec4 diff = vec4(c * max(dot(n, (l - p) / length(l - p)), 0.0) * 1., 1.0);
    // Specular
    return diff + vec4(c * 
                   pow(max(
                       dot(n, normalize(((l - p) / length(l - p)) 
                                        + normalize(-p))), 0.0), 64.0) * 1., 1.0);
}
vec2 intersect(vec3 ro, vec3 rd, 
               out vec3 pOut, out vec3 nOut)
{
    vec3 xf = vec3(0.0, 0.0, 0.);
    float r = mix(.4,
                  getMusic().x * getMusic().x*.9,
                  .5*bumpAmt);
    
    // Matrix constructed as inverse.
    mat4 rot = rotationMatrix(vec3(0,0,1), 3.1415/2.);
    // Translation after roation
    rot[3].xyz = vec3(-1., 1., 0.);
            
    // ray parameter
    float t = 0.0;
    
    for (float i = 0.0; i < 40.0; i += 1.) {
       	vec3 p = ro + rd * t;
        vec4 pCyl = rot*vec4(p,1.0);
        float dd = sdSphere(p-xf, r);
        
        if (abs(dd) < 0.01) {
            pOut = p;
            nOut = normalize(p-xf);
			return vec2(t, 1.0);
        }
        
		float dc = sdCylinder((pCyl).xyz, vec3(0.,0.,.1));
        if (abs(dc) < 0.01) {
            pOut = (vec4(p,1.)*rot).xyz;
            nOut = vec3(0);//normalize(p-xf);
			return vec2(t, 2.0);
        }
        
        float dc2 = sdCylinder(vec3(0.,0.,.4+ getMusic().z)+(pCyl).xyz, vec3(0.,0.,.1));
        if (abs(dc2) < 0.01) {
            pOut = (vec4(p,1.)*rot).xyz;
            nOut = vec3(0); //normalize(p-xf);
			return vec2(t, 2.0);
        }
        
        float dc3 = sdCylinder(vec3(0.,0.,-.4- getMusic().z)+(pCyl).xyz, vec3(0.,0.,.1));
        if (abs(dc3) < 0.01) {
            pOut = (vec4(p,1.)*rot).xyz;
            nOut = vec3(0); //normalize(p-xf);
			return vec2(t, 2.0);
        }

        t += min(min(min(abs(dd), abs(dc))
                 ,dc2)
                 ,dc3)-.008;
    }
    
   	nOut = vec3(0);
    pOut = vec3(0);
    
    return vec2(0.0, 0.0);
}
// Specialized intersector just for tubes to make secondary rays
// super fast.
vec2 intersectTubes(vec3 ro, vec3 rd)
{
    mat4 rot = rotationMatrix(vec3(0,0,1), 3.1415/2.);
    rot[3].xyz = vec3(-1., 1., 0.);
    float t = 0.0;
    
    vec3 offsetPlus = vec3(0.,0.,.4+ getMusic().z);
    vec3 offsetMinus = vec3(0.,0.,-.4- getMusic().z);
    
    for (float i = 0.0; i < 10.0; i += 1.) {
       	vec3 p = ro + rd * t;
        vec3 pCyl = (rot*vec4(p,1.0)).xyz;
		float dc = sdCylinder(pCyl, vec3(0.,0.,.1));        
        dc = min(dc, sdCylinder(offsetPlus+pCyl, vec3(0.,0.,.1)));
        dc = min(dc, sdCylinder(offsetMinus+pCyl, vec3(0.,0.,.1)));
        if (abs(dc) < 0.01) {
			return vec2(t, 2.0);
        }

        t += dc -.001;
    }
        
    return vec2(0.0, 0.0);
}
vec4 getColor2(vec3 ro, vec3 rd)
{
    // For speed, only accept hits from the tubes.
    return mix(vec4(0),
               vec4(1),
               vec4(intersectTubes(ro, rd).y == 2.0));
}
vec4 getColor(vec3 ro, vec3 rd, vec3 offset) {
    // Intersection
    vec3 p, n;
    vec2 hit;
    
    // hit.x = ray parameter
    // hit.y = object id
    hit = intersect(ro, rd, p, n);
    if (hit.x == 0.0) {
        return vec4(.5*textureCube(iChannel0, rd-offset)
                   +.5*textureCube(iChannel0, rd+offset));
    }
    vec4 normColor = vec4(.5 * n + .5, 1.0);
    vec4 hitColor = vec4(.0,.0,.0, 1.0);
    
    // Lighting
    
    //return hitColor;
    hitColor += .75*vec4(textureCube(iChannel0, reflect(rd, n)).rgb, 1.0);
    
    hitColor += .8*getColor2(p + n*.01, reflect(rd,n));
    
    float flake = texture2D(iChannel1, n.yz*3.0).x;
    flake += .1*texture2D(iChannel1, n.xz).x;
    float fresnelDarken = dot(-rd,n);
    vec3 c = .5*vec3(1.,1,1.);
    fresnelDarken *= fresnelDarken;
    hitColor += fresnelDarken*flake*blinnPhong(vec3(3,1,0), p, n, c);
    hitColor += fresnelDarken*flake*blinnPhong(vec3(-3,1,0), p, n, c);
    hitColor += fresnelDarken*flake*blinnPhong(vec3(0,1,0), p, n, c);
    
    return mix(hitColor,
               vec4(1),
               vec4(hit.y != 1.0));    
}
vec4 strobe(vec4 color) 
{
    return 1.7*color 
         * 1.5 * vec4(getMusic().x*.6, getMusic().x*.4, .3*getMusic().x, 1.0);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // XXX: should be vec2(0.), but requres vec2(1.,0.)
    _m = texture2D(iChannel2, vec2(1.0,0.));
    // Mouse controls
    vec2 mo = iMouse.xy/iResolution.xy;
    mo -= vec2(.5,.5);

    globalTime = iChannelTime[2] + .4;
    // drop
    float fadeIntro = mix(0.0, 1.0, globalTime/5.85);
    float fadeIn = smoothstep(60.0, 61.0, globalTime);
    float fadeSpin = smoothstep(17.0, 20.5, globalTime);
    float fadeBump = smoothstep(20.0, 30.5, globalTime);
    float fadeCamSpaz = fadeBump;
    float fadeFirstBreak = smoothstep(28.0, 30.5, globalTime);
    bumpAmt = .1+fadeBump;
    
    fadeSpin = fadeSpin*(.9+getMusic().x/45.);
        
    // Fade in: 6s
	if (fadeIntro < 1.0) {
        fragColor = vec4(vec3(fadeIntro-.15), 1.0);
        return;
    }
    
    if (globalTime < 16.25) {
		bumpAmt = 1.0;   
    }

    if (globalTime > 28.0 && globalTime < 39.2) {
        fadeCamSpaz = 0.0;
        fadeSpin = 0.0;
        bumpAmt = mix(0.2,0.6, (globalTime-28.0)/(39.2-28.0));
    }
        
    if (globalTime > 228.) {
    	fragColor = vec4(vec3(1.-(globalTime-228.)/(233.-228.)),1.0);
    }
    
    // Calm, looing up from below
    if (globalTime > 27.0 && globalTime < 59.5) {
        float s = globalTime/59.5;
     	fadeCamSpaz = mix(0.0, fadeCamSpaz, s);
        fadeSpin  = mix(0.0, fadeSpin, s);
        bumpAmt = mix(0.0, bumpAmt, s);
        
        // Build up, looking down
        if (globalTime < 39.2) {
    	    mo += vec2(.5, 1.0);
        }
        if (globalTime > 59.5 && globalTime < 60.) {
			mo += vec2(.5, 1.0);
        }
    }
    
    // First Drop, looking up from below
    if (globalTime > 61.0 && globalTime < 85.) {
        mo += vec2(.5, 1.0);
    }

    // 1:25 - grr, looking up from below
    if (globalTime > 126.8 && globalTime < 128.) {
        mo += vec2(.5, 1.0)+.4*getMusic().x;
        //darkAmt = 1.0;
    }
    
    // faster at 116
    // 138 - drop out
    // 148 - build
    // 160 - drop in
    if (( globalTime > 0.5 && fadeIntro >= 1.0 && globalTime < 6.1)
       ||(globalTime > 16.25 && fadeIn < 1.0) 
       ||(globalTime > 104.5 && globalTime < 160.5)
    ) {
    	strobeAmt = fadeIn = getMusic().x;
        float s = (globalTime-104.5)/(160.0-104.5);
     	fadeCamSpaz = mix(0.0, fadeCamSpaz, s);
        //fadeSpin  = 0.5; //mix(0., 0.1, globalTime/110.); //mix(0.0, fadeSpin, s);
        fadeSpin  = mix(0.0, fadeSpin, s);
        bumpAmt = mix(0.0, bumpAmt, s);

        if ((globalTime > 60. && globalTime < 116.) 
            || (globalTime > 138. && globalTime < 140.5)
            || (globalTime > 143.5 && globalTime < 146.5 )
        ) {
    	    mo += vec2(.5, 1.0);
        }
    }
    
    if (globalTime > 160.5 && globalTime < 204.) {
     	darkAmt = mix(0.3, 1.0, (globalTime-160.5)/(204.-160.5));
        if (globalTime < 170. || globalTime > 171.5)
        	mo += vec2(.5, 1.0);
    }
    
    if ((globalTime > 203. && globalTime < 320.))
    {
    	strobeAmt = fadeIn = getMusic().x;
        float s = (globalTime-204.)/(220.0-204.);
     	fadeCamSpaz = mix(0.0, fadeCamSpaz, s);
        fadeSpin  = getMusic().x/45.; //mix(0.0, fadeSpin, s);
        bumpAmt = mix(0.0, bumpAmt, s);
        lightAmt = mix(0.0, 1.0, s);
        darkAmt = mix(1.0, 0.0, s);
    }
    
    if (( globalTime > 11.0 && globalTime < 11.2))
	{
        strobeAmt = fadeIn = getMusic().x;
	}
    	
    
    // Camera, spherical coords
	float an1 = -6.2831*mo.x + 1.55 
        		+ mix(1.0,
                      (.1*globalTime*10.0 + noise1(vec2(globalTime)*.2)),
                      fadeSpin)
        	;
	float an2 = clamp(1.0  + 1.5*mo.y, 0.3, 3.35)
        		+ mix(mix(0.0, noise1(vec2(globalTime)*.2), fadeCamSpaz),
                      0.0, fadeFirstBreak);
    vec3 ro = normalize(vec3(sin(an2)*cos(an1), cos(an2)-0.5, sin(an2)*sin(an1)));
    
	vec2 uv = (2.*fragCoord.xy - iResolution.xy) / iResolution.y;
    
    // Camera Transform
    vec3 ww = normalize(vec3(0.,0.,0.) - ro);
    vec3 uu = normalize(cross(vec3(0.0,1.0,0.0), ww));
    vec3 vv = normalize(cross(ww,uu));
    // Ray Direction
    vec3 rd = normalize(uv.x*uu + uv.y*vv + 1.4*ww);
    
    vec3 offset;
    {
    	float m = getMusic().x*.02;
    	float n1 = noise1s(vec2(globalTime));
    	float n2 = noise1s(vec2(globalTime*7.));
    	float n3 = noise1s(vec2(globalTime*3.));
    	offset = vec3(m*n1,m*n2,m*n3);   
    }
    
    vec4 c = getColor(ro, rd, offset);
    
    c.r = mix(c.r,
        	  getColor(ro, rd 
        			       +vec3(noise1(uv+sin(globalTime)*1e7)*.04 
                      	   		      +(getMusic().x*.12-.066)),
                       offset).r,
    		  float(  (globalTime > 126.8 && globalTime < 128.)
        			|| (globalTime > 80.5 && globalTime < 83.)
        			|| (globalTime > 92.0 && globalTime < 93.5)
        			|| (globalTime > 103.5 && globalTime < 105.)
        			|| (globalTime > 138.0 && globalTime < 139.)
        			|| (globalTime > 158. && globalTime < 160.)
        			|| (globalTime > 180.5 && globalTime < 182.5)
        			|| (globalTime > 191.5 && globalTime < 193.0)
        			|| (globalTime > 203. && globalTime < 204.0)
        			|| (globalTime > 59.5 && globalTime < 61.) 
       				)
             );

    
    c.b += mix(.0,  getMusic().x*.5, fadeIn);
    c.rgb = pow(c.rgb, vec3(1.3));
   	fragColor = mix(strobe(c), c, 
                    1.0 - 
                    fadeIn*strobeAmt * 
                    (.5+.5*sin(2.*globalTime)));
    fragColor = mix(fragColor,
                    fragColor - .7*(length(uv)*length(uv)),
                    darkAmt);
    fragColor = mix(fragColor,
                    fragColor + .7*(length(uv)*length(uv)),
                    lightAmt);    
    fragColor = fragColor - .02*(length(uv)*length(uv)*length(uv)*length(uv));
}

