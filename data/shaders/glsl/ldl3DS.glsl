// Shader downloaded from https://www.shadertoy.com/view/ldl3DS
// written by shadertoy user fb39ca4
//
// Name: Voxel Ambient Occlusion
// Description: Wrote this a while back, and forgot to release it. As seen in Reinder's Minecraft shader: https://www.shadertoy.com/view/4ds3WS
const bool USE_BRANCHLESS_DDA = true;
const int MAX_RAY_STEPS = 64;

vec2 rotate2d(vec2 v, float a) {
	float sinA = sin(a);
	float cosA = cos(a);
	return vec2(v.x * cosA - v.y * sinA, v.y * cosA + v.x * sinA);	
}

float sum(vec3 v) { return dot(v, vec3(1.0)); }

float sdSphere(vec3 p, float d) { return length(p) - d; } 

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float getVoxel(vec3 c) {
	vec3 p = floor(c) + vec3(0.5);
	float d = min(max(-sdSphere(p, 7.5), sdBox(p, vec3(6.0))), -sdSphere(p, 25.0));
	return float(d < 0.0);
}

float vertexAo(vec2 side, float corner) {
	//if (side.x == 1.0 && side.y == 1.0) return 1.0;
	return (side.x + side.y + max(corner, side.x * side.y)) / 3.0;
}

vec4 voxelAo(vec3 pos, vec3 d1, vec3 d2) {
	vec4 side = vec4(getVoxel(pos + d1), getVoxel(pos + d2), getVoxel(pos - d1), getVoxel(pos - d2));
	vec4 corner = vec4(getVoxel(pos + d1 + d2), getVoxel(pos - d1 + d2), getVoxel(pos - d1 - d2), getVoxel(pos + d1 - d2));
	vec4 ao;
	ao.x = vertexAo(side.xy, corner.x);
	ao.y = vertexAo(side.yz, corner.y);
	ao.z = vertexAo(side.zw, corner.z);
	ao.w = vertexAo(side.wx, corner.w);
	return 1.0 - ao;
}

float zeroToOne(float x) { return x + float(!bool(x)); } 

float voxelDistance(vec3 pos) {
	vec3 p = floor(pos); //integer coordinates
	pos = mod(pos, 1.0);
	const vec3 o = vec3(0, 1.0, -1.0); //for swizzling
	
	float faceX = min(zeroToOne(pos.x * getVoxel(p + o.zxx)), zeroToOne((1.0 - pos.x) * getVoxel(p + o.yxx)));
	float faceY = min(zeroToOne(pos.y * getVoxel(p + o.xzx)), zeroToOne((1.0 - pos.y) * getVoxel(p + o.xyx)));
	float faceZ = min(zeroToOne(pos.y * getVoxel(p + o.xxz)), zeroToOne((1.0 - pos.z) * getVoxel(p + o.xxz)));
	float face = min(faceX, min(faceY, faceZ));
	
	//float edgeX1 = 
	return 0.0;
	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 screenPos = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	vec3 cameraDir = vec3(0.0, 0.0, 0.8);
	vec3 cameraPlaneU = vec3(1.0, 0.0, 0.0);
	vec3 cameraPlaneV = vec3(0.0, 1.0, 0.0) * iResolution.y / iResolution.x;
	vec3 rayDir = cameraDir + screenPos.x * cameraPlaneU + screenPos.y * cameraPlaneV;
	vec3 rayPos = vec3(0.0, 2.0 * sin(iGlobalTime * 2.7), -12.0);
		
	rayPos.xz = rotate2d(rayPos.xz, iGlobalTime);
	rayDir.xz = rotate2d(rayDir.xz, iGlobalTime);
	
	vec3 mapPos = vec3(floor(rayPos));

	vec3 deltaDist = abs(vec3(length(rayDir)) / rayDir);
	
	vec3 rayStep = sign(rayDir);

	vec3 sideDist = (sign(rayDir) * (mapPos - rayPos) + (sign(rayDir) * 0.5) + 0.5) * deltaDist; 
	
	vec3 mask;
	
	for (int i = 0; i < MAX_RAY_STEPS; i++) {
		if (bool(getVoxel(mapPos))) continue;
		mask = step(sideDist.xyz, sideDist.yzx) * step(sideDist.xyz, sideDist.zxy);
		
		sideDist += mask * deltaDist;
		mapPos += mask * rayStep;
	}
	
	vec3 intersectPlane = vec3(mapPos + vec3(lessThan(rayDir, vec3(0.0))));
	vec3 endRayPos;
	vec2 uv;
	vec4 ambient;
	
	ambient = voxelAo(mapPos - rayStep * mask, mask.zxy, mask.yzx);
	endRayPos = rayDir / sum(mask * rayDir) * sum(mask * (intersectPlane - rayPos)) + rayPos;
	
	uv.x = dot(mask * endRayPos.yzx, vec3(1.0));
	uv.y = dot(mask * endRayPos.zxy, vec3(1.0));
	uv = mod(uv, vec2(1.0));

	float interpAo = mix(mix(ambient.z, ambient.w, uv.x), mix(ambient.y, ambient.x, uv.x), uv.y);
	interpAo = pow(interpAo, 1.0 / 3.0);

	float color = 0.75 + interpAo * 0.25;

	fragColor.rgb = pow(vec3(color), vec3(2.2));
}