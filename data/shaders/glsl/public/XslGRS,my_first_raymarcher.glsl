// Shader downloaded from https://www.shadertoy.com/view/XslGRS
// written by shadertoy user fb39ca4
//
// Name: My First Raymarcher
// Description: Test.
float square(float x) {
	return x * x;
}

float sdSphere(vec3 p, float r) {
	return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
  	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdPlane(vec3 p, vec4 n) {
	return dot(p, n.xyz) + n.w;
}

float join(float a, float b) { return min(a, b); }
float carve(float a, float b) { return max(a, -b); }
float intersection(float a, float b) { return max(a, b); }

float distanceField(vec3 p) {
	float sphere = sdSphere(p - vec3(0.0, 0.0, 4.0), 2.0);
	float box = sdBox(p - vec3(0.0, 0.0, 4.0), vec3(3.5, 1.0, 1.0));
	float plane = sdPlane(p, vec4(0.0, 1.0, 0.0, 1.0));
	return join(carve(box, sphere), plane);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 mousePos = (iMouse.xy / iResolution.xy) * 2.0 - 1.0;
	vec2 screenPos = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	vec3 cameraPos = vec3(0.0, 0.0, 0.0);
	vec3 cameraDir = vec3(0.0, 0.0, 1.0);
	vec3 planeU = vec3(1.5, 0.0, 0.0);
	vec3 planeV = vec3(0.0, iResolution.y / iResolution.x * 1.5, 0.0);
	vec3 rayDir = normalize(cameraDir + screenPos.x * planeU + screenPos.y * planeV);
	vec3 rayPos = cameraPos;
	float rayDist;
	float rayDistTotal = 0.0;
	
	for (int i = 0; i < 64; i++) {
		rayDist = distanceField(rayPos);
		if (rayDist < 0.01) break;
		rayPos += rayDist * rayDir;
	}
	
	vec3 lightPos;
	//lightPos.xyz = vec3(2.5 * mousePos, 2.0);
	lightPos = vec3(0.0, 1.0, sin(iGlobalTime) * 3.0 + 4.0);
	vec3 lightRayDir = normalize(lightPos - rayPos);
	vec3 lightRayPos = rayPos + 0.001 * lightRayDir;
	
	float lightDistTotal = length(lightPos - rayPos);
	float lightDistAccum = 0.001;
	float lightDist;
	for (int i = 0; i < 128; i++) {
		lightDist = distanceField(lightRayPos);
		if (lightDistAccum > lightDistTotal) continue;
		if (lightDist < 0.001) {
			fragColor = vec4(0.0);
			return;
		}
		lightRayPos += lightDist * 0.9 * lightRayDir;
		lightDistAccum += lightDist;
	}
	
	const float derivDist = 0.0001;
	const float derivDist2 = 2.0 * derivDist;
	vec3 surfaceNormal;
	surfaceNormal.x = distanceField(vec3(rayPos.x + derivDist, rayPos.y, rayPos.z)) 
					- distanceField(vec3(rayPos.x - derivDist, rayPos.y, rayPos.z));
	surfaceNormal.y = distanceField(vec3(rayPos.x, rayPos.y + derivDist, rayPos.z)) 
					- distanceField(vec3(rayPos.x, rayPos.y - derivDist, rayPos.z));
	surfaceNormal.z = distanceField(vec3(rayPos.x, rayPos.y, rayPos.z + derivDist)) 
					- distanceField(vec3(rayPos.x, rayPos.y, rayPos.z - derivDist));
	surfaceNormal = normalize(surfaceNormal / derivDist2);

	//fragColor = vec4(lightDistAccum / 8.0);
	fragColor = vec4(3.0 * vec3(dot(surfaceNormal, lightRayDir)) / square(lightDistTotal), 1.0);
}