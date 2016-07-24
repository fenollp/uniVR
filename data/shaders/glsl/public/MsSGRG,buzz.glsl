// Shader downloaded from https://www.shadertoy.com/view/MsSGRG
// written by shadertoy user hat
//
// Name: buzz
// Description: modeling with distance field
	//#define SHADOWS

	const int max_iterations = 150;
	const float stop_threshold = 0.1;
	const float grad_step = 0.1;
	const float clip_far = 6000.0;
	const float PI = 3.14159265359;

	float uAngle = iGlobalTime * 50.0;

	mat3 rotX(float angle) {
		angle = radians(angle);
		float c = cos(angle);
		float s = sin(angle);
		return mat3(1.0, 0.0, 0.0,
					0.0, c, -s,
					0.0, s, c);
	}

	mat3 rotY(float angle) {
		angle = radians(angle);
        float c = cos(angle);
        float s = sin(angle);
		return mat3(c, 0.0, s,
					0.0, 1.0, 0.0,
					-s, 0.0, c);
	}

	mat3 rotZ(float angle) {
		angle = radians(angle);
        float c = cos(angle);
        float s = sin(angle);
		return mat3(c, -s, 0.0,
					s, c, 0.0,
					0.0, 0.0, 1.0);
	}

	float roundCylinder(in vec3 p, in float h, in float r1, in float r2) {
	    float a = abs(p.x)-(h-r2);
	    float b = length(p.yz)-r1;
	    return min(min(max(a, b), max(a-r2, b+r2)), length(vec2(b+r2,a))-r2);
	}

	float roundCylinderH(in vec3 p, in float h, in float r1, in float r2) {
	    float a = abs(p.y)-(h-r2);
	    float b = length(p.xz)-r1;
	    return min(min(max(a, b), max(a-r2, b+r2)), length(vec2(b+r2,a))-r2);
	}

	float displace(float u, vec3 xcomp, float smooth) {
		xcomp.x *= 0.5;
		float xD = (u + xcomp.x) * step(-u, xcomp.x) * step(u, xcomp.y - xcomp.x) / xcomp.y;
		xD += step(-u, xcomp.x - xcomp.y) * step(u, xcomp.x - xcomp.z);
		xD += (xcomp.x - u) * step(-u, xcomp.z - xcomp.x) * step(u, xcomp.x) / xcomp.z;
		return xD * xD * (3. - 2. * xD);
	}

    vec3 coloring_head(vec3 p) {

        p.y -= 900.;
        p *= rotY(uAngle);

        vec3 outData = vec3(0.0, 0.0, 0.0);
        vec3 u = p.xyz;

        float ratio = 150.0;
        u.y = 0.00225 * u.y * u.y;
        u.x *= 1.15 * (1.0 + .4 * sin((u.y)/ ratio) * step(p.y, 0.0)) * (1.0 - .06 * (ratio - p.y) / ratio);
        u.z += (0.05 + step(p.z, 0.0) * clamp(p.z * 0.1, -0.18, 0.0)) * p.y;

        float head = length(u) - 200.0;

        u.z = p.z -40.0 + 5.0 * cos(p.y * 0.011 + 1.1) + 190.0 * cos(p.x * 0.008) - 25.0 * cos(p.y * 0.02 + 1.1) + 0.05 * p.y;
        head -= 4.0 * clamp(u.z, 0.0, 1.);

        vec3 v = vec3(abs(p.x) - 170., p.yz - vec2(60., 130.));
        float val = length(v);
        head -= 4.0 * pow((60.0 - clamp(val, 0.0, 60.0)), 0.5)  * step(val, 60.0);

        float l = 270.0;
        float c = 50.0;
        float y0 = 65.0;
        float w = 190.0;
        float m = (p.y + y0) * step(p.y, c - y0) / c + step(-p.y, -c + y0) * (1.0 - (p.y - c + y0) / (l - c));
        float n = m * m;
        float s = clamp(w - 2.0 * abs(p.x), 0.0, w) / w;
        s *= s;
        s = s * s * (3.0 - 2.0 * s);
        float nose = 0.28 * clamp((w - 2.0 * abs(p.x)) * s, 0.0, w) * step(-p.y, y0) * step(p.y, l - y0) * step(p.z, 0.0);
        nose *= n;

        head -= nose;
        outData.y = clamp(u.z, 0.0, 1.);

        float eS = 68.0;
        v = vec3(abs(p.x) - 60., p.yz + vec2(-110., 130.));
        val = length(v);
        m = 4.0 * pow((eS - clamp(val, 0.0, eS)), 0.5) * step(val, eS);
        head -= m;

        v.x -= 20.0;
        c = v.x - 20.0;

        s = step(val, eS) * step(v.y + 0.01 * c * c, 35.0);
        outData.y += (2. - outData.y) * step(val, eS);

        v.xy += vec2(28., 10.);
        ratio = length(v);
        vec4 ratios = vec4(59.5, 59.2, 58.4, 57.8);
        outData.z = atan(v.y, v.x);
        outData.y += (3. - outData.y) * step(-ratio, -ratios.y) * step(ratio, ratios.x);
        outData.y += (4. - outData.y) * step(-ratio, -ratios.z) * step(ratio, ratios.y);
        outData.y += (3. - outData.y) * step(ratio, ratios.z);

        v.xy += vec2(1.7, -5.);
        ratio = length(v);
        outData.y += (2. - outData.y) * step(ratio, ratios.w);
        v.xy -= vec2(1.7, 5.);
        outData.y += (0. - outData.y) * step(-(v.y + 0.01 * c * c), -20.0) * step(val, eS);

        v.x -= 28.0;
        v.x *= 0.9;
        v.y -= 10.0 + 8.0 * cos(v.x * 0.07 - 0.4);
        s = 10.0;
        w = 34.0;
        n = s + 75.0 * cos(v.x * 0.016);
        m = step(-v.y, -s) * step(v.y, n) * step(abs(v.x), 80.0) * step(p.z, 0.0);
        c = v.y * step(v.y, w) + w * step(-v.y, -w) - (v.y - n + w ) * step(-v.y, -n + w);
        c /= w;
        c = c * c * c;
        c = c * c *( 3.0 - 2.0 * c);
        l = (110.0 - (abs(p.x) - 20.0))/ 80.0;
        l = l * l * ( 3.0 - 2.0 * l);
        head -= 30.0 * c * m * l;
        c = 5.0;

        outData.y += (5.0 - outData.y) * step(v.y, n - w + c) * step(-v.y, -w + c) * m * step(abs(v.x + 3.0), 60.0) * step(abs(v.x - 3.0), 60.0);

        u = vec3(abs(p.x) - 90., p.yz + vec2(83., 200.));
        val = length(u);
        float rad = 180.0;
        m = (val - rad) / rad;
        m *= m;
        m = m * m * m * (3.0 - 2.0 * m * m);
        head += 12.0 * m * step(val, rad);

        u = vec3(abs(p.x) - 110., p.yz + vec2(0., 120.));
        val = length(u);
        rad = 130.0;
        m = (val - rad) / rad;
        m *= m;
        m = m * m * m * (3.0 - 2.0 * m * m);
        head -= 10.0 * m * step(val, rad);

        head *= 0.3;
        outData.x = head;


        return outData;
    }


	vec3 coloring(vec3 p) {

		p.y -= 900.;
		p *= rotY(uAngle);

		vec3 outData = vec3(0.0, 0.0, 0.0);
		vec3 u = p.xyz;

		float ratio = 150.0;
		u.y = 0.00225 * u.y * u.y;
		u.x *= 1.15 * (1.0 + .4 * sin((u.y)/ ratio) * step(p.y, 0.0)) * (1.0 - .06 * (ratio - p.y) / ratio);
		u.z += (0.05 + step(p.z, 0.0) * clamp(p.z * 0.1, -0.18, 0.0)) * p.y;

		float head = length(u) - 200.0;

		u.z = p.z -40.0 + 5.0 * cos(p.y * 0.011 + 1.1) + 190.0 * cos(p.x * 0.008) - 25.0 * cos(p.y * 0.02 + 1.1) + 0.05 * p.y;
		head -= 4.0 * clamp(u.z, 0.0, 1.);

        vec3 v = vec3(abs(p.x) - 170., p.yz - vec2(60., 130.));
		float val = length(v);
		head -= 4.0 * pow((60.0 - clamp(val, 0.0, 60.0)), 0.5)  * step(val, 60.0);

		float l = 270.0;
		float c = 50.0;
		float y0 = 65.0;
		float w = 190.0;
		float m = (p.y + y0) * step(p.y, c - y0) / c + step(-p.y, -c + y0) * (1.0 - (p.y - c + y0) / (l - c));
		float n = m * m;
		float s = clamp(w - 2.0 * abs(p.x), 0.0, w) / w;
		s *= s;
		s = s * s * (3.0 - 2.0 * s);
		float nose = 0.28 * clamp((w - 2.0 * abs(p.x)) * s, 0.0, w) * step(-p.y, y0) * step(p.y, l - y0) * step(p.z, 0.0);
		nose *= n;

		head -= nose;
		outData.y = clamp(u.z, 0.0, 1.);

		float eS = 68.0;
		v = vec3(abs(p.x) - 60., p.yz + vec2(-110., 130.));
		val = length(v);
		m = 4.0 * pow((eS - clamp(val, 0.0, eS)), 0.5) * step(val, eS);
		head -= m;

		v.x -= 20.0;
		c = v.x - 20.0;

		s = step(val, eS) * step(v.y + 0.01 * c * c, 35.0);
		outData.y += (2. - outData.y) * step(val, eS);

        v.xy += vec2(28., 10.);
		ratio = length(v);
		vec4 ratios = vec4(59.5, 59.2, 58.4, 57.8);
		outData.z = atan(v.y, v.x);
		outData.y += (3. - outData.y) * step(-ratio, -ratios.y) * step(ratio, ratios.x);
		outData.y += (4. - outData.y) * step(-ratio, -ratios.z) * step(ratio, ratios.y);
		outData.y += (3. - outData.y) * step(ratio, ratios.z);

        v.xy += vec2(1.7, -5.);
		ratio = length(v);
		outData.y += (2. - outData.y) * step(ratio, ratios.w);
        v.xy -= vec2(1.7, 5.);
		outData.y += (0. - outData.y) * step(-(v.y + 0.01 * c * c), -20.0) * step(val, eS);

		v.x -= 28.0;
		v.x *= 0.9;
		v.y -= 10.0 + 8.0 * cos(v.x * 0.07 - 0.4);
		s = 10.0;
		w = 34.0;
		n = s + 75.0 * cos(v.x * 0.016);
		m = step(-v.y, -s) * step(v.y, n) * step(abs(v.x), 80.0) * step(p.z, 0.0);
		c = v.y * step(v.y, w) + w * step(-v.y, -w) - (v.y - n + w ) * step(-v.y, -n + w);
		c /= w;
		c = c * c * c;
		c = c * c *( 3.0 - 2.0 * c);
		l = (110.0 - (abs(p.x) - 20.0))/ 80.0;
		l = l * l * ( 3.0 - 2.0 * l);
		head -= 30.0 * c * m * l;
		c = 5.0;

		outData.y += (5.0 - outData.y) * step(v.y, n - w + c) * step(-v.y, -w + c) * m * step(abs(v.x + 3.0), 60.0) * step(abs(v.x - 3.0), 60.0);

        u = vec3(abs(p.x) - 90., p.yz + vec2(83., 200.));
		val = length(u);
		float rad = 180.0;
		m = (val - rad) / rad;
		m *= m;
		m = m * m * m * (3.0 - 2.0 * m * m);
		head += 12.0 * m * step(val, rad);

        u = vec3(abs(p.x) - 110., p.yz + vec2(0., 120.));
		val = length(u);
		rad = 130.0;
		m = (val - rad) / rad;
		m *= m;
		m = m * m * m * (3.0 - 2.0 * m * m);
		head -= 10.0 * m * step(val, rad);

		head *= 0.3;
		outData.x = head;

		u = p;
		u.y += 80.0;
		float helmet = length(u) - 500.0;
		helmet = max(helmet, -length(u) + 490.0);
		helmet = max(helmet, -u.y);
		helmet = max(helmet, - u.z);

		float an = mod(0.1 * uAngle + 0.0, 140.0);
		if(an > 70.0) an = 140.0 - an;
		u *= rotX(an);
		float innerHelmet = length(u) - 490.0;
		innerHelmet = max(innerHelmet, -length(u) + 480.0);
		innerHelmet = max(innerHelmet, -u.y);
		innerHelmet = max(innerHelmet, -u.z -0.7* u.y);
		helmet = min(helmet, innerHelmet);

		outData.x = min(outData.x, helmet);
		if(outData.x == helmet) {
			outData.y = 6.0;
			outData.z = 4.;
		}

		u = p;
		u.y += 110.;
		float base = max(length(u.xz) - 510., abs(u.y) - 30.0);
		base = max(base, -max(length(u.xz) - 480., abs(u.y) - 40.0));
		base = max(base, -p.z);

		u *= rotX(18.);
		m = max(length(u.xz) - 510., abs(u.y) - 30.0);
		m = max(m, -max(length(u.xz) - 480., abs(u.y) - 40.0));
		m = max(m, p.z);


		u = vec3(abs(p.x) - 490., p.yz + vec2(120., 0.));
		base = min(base, roundCylinder(u, 30.0, 95.0, 15.0));
		base = min(base, roundCylinder(u, 60.0, 55.0, 20.0));
		base = min(base, m);

		outData.x = min(outData.x, base);
		if(outData.x == base) {
			outData.z = 4.;
			outData.y = 7.;
			if(length(u.yz) <= 51.0) outData.y = 1.;
		}

        u = vec3(abs(p.x), p.y + 445., abs(p.z));
		m = u.y - 275.;
		n = 1. + 0.000001 * m * m;
		u.x *= n;
		u.z *= n;
		float body = max(length(u.xz) - 500.0, abs(u.y) - 300.0);

		float inner = step(length(u.xz), 490.0);
		body = max(body, -max(length(u.xz) - 490.0, abs(u.y - 250.) - 150.0));

		v = u = p;
		v.x = u.x = abs(p.x);

		v.y += 0.3 * v.x;
		m = displace(v.y, vec3(1150., vec2(30.)), 2.);

		v.y = -p.y  + 0.3 * (u.x - 250.0);
		m *= displace(v.y, vec3(1150., vec2(30.)), 2.);

		v.y = -p.y + 1.6 * (u.x - 380.0);
		m *= displace(v.y, vec3(1150., vec2(30.)), 2.);

		body -= 26.0 * m;

		v.y = 280.0 + p.y + 0.9 * v.x;
		n = displace(v.y, vec3(150., vec2(20.)), 2.) * (1. - m);
		body -= 23. * n;

		v.y = p.y - 0.3 * v.x;
		w = displace(v.y, vec3(920., vec2(30.)), 2.);

		v.y = p.y -5. * (u.x - 110.0);
		w *= displace(v.y, vec3(750., vec2(30.)), 2.) * step(p.z, 0.);

		v.y = p.y - 0.3 * v.x;
		an = displace(v.y, vec3(885., vec2(30.)), 2.);

		v.y = p.y -5. * (u.x - 90.0);
		an *= displace(v.y, vec3(750., vec2(30.)), 2.) * step(p.z, 0.);

		body += 26.0 * w;

		body = max(body, p.y - 0.3 * p.z + 150.0);
		body = max(body, p.y + 140.0);

		float f = 3.;
		float k = 1. / pow(10., 4.5);

		u = vec3(p.xy + vec2(170., 430.), p.z);
		u *= rotZ(-5.0);
		u.y *= 0.4;
		float bh = length(u.xy);
		bh *= (bh * bh);
		c = step(length(u.xy), 30.) * step(p.z, 0.) * clamp(exp( -k * bh), 0., 1.);

		u = vec3(p.xy + vec2(250., 420.), p.z);
		u *= rotZ(-5.0);
		u.y *= 0.4;
		bh = length(u.xy);
        bh *= (bh * bh);
		l = step(length(u.xy), 30.) * step(p.z, 0.) * clamp(exp( -k * bh), 0., 1.);

		u = vec3(p.xy + vec2(330., 410.), p.z);
		u *= rotZ(-5.0);
		u.y *= 0.4;
		bh = length(u.xy);
        bh *= (bh * bh);
		s = step(length(u.xy), 30.) * step(p.z, 0.) * clamp(exp( -k * bh), 0., 1.);

		u = vec3(p.xy + vec2(-230., 430.), p.z);
		f = 10.;
		k = 1. / pow(10., 18.);
		f = step(length(u.xy), 60.) * step(p.z, 0.) * clamp(exp( -k * pow(length(u.xy), f)), 0., 1.);

		body -= 20.0 * (c + l + s + 1.3 * f);

		u = p;
		u.y += 500.;
		body += 15. * displace(u.x, vec3(35., vec2(15.)), 2.) * displace(u.y, vec3(150., vec2(15.)), 2.) * step(p.z, 0.);

		u = p;
		u.x += 9.0 * cos(u.y * 0.1);
		u.z += 10.0 * cos(u.y * 0.1 - 0.5 * PI);
		u.y += 800.0;

		body = min(body, max(length(u.xz) - 325., abs(u.y) - 130.));

		body *= 0.5;
		outData.x = min(outData.x, body);
		if(outData.x == body){
			outData.y = 2.;
			outData.y += (8. - outData.y) * step(1. - m, 0.99);
			outData.y += (2. - outData.y) * step(1. - w, 0.);
			outData.y += (12. - outData.y) * step(1. - an, 0.);
			outData.y += (1. - outData.y) * step(1. - n, 0.99);
			outData.y += (7. -outData.y) * inner;
			outData.y += (3. - outData.y) * step(u.y, 50.);
			outData.y += (9. - outData.y) * step(1. - c, 0.9);
			outData.y += (9. - outData.y) * step(1. - f, 0.9);
			outData.y += (10. - outData.y) * step(1. - l, 0.9);
			outData.y += (11. - outData.y) * step(1. - s, 0.9);
			outData.z = 4.;
		}

		u= p;
		u.x = abs(p.x);
		u.x -= 500.0;
		u.y += 370.;
		u *= rotZ(15.);
		float arms = roundCylinder(u, 20.0, 200.0, 15.0);
		u.x -= 30.;
		arms = min(arms, roundCylinder(u, 20.0, 190.0, 15.0));
		u *= rotX(90.);
		w = length(u);
		m = w - 160.;
		m += 7.* displace(u.x, vec3(1270.0, vec2(80.0)), 2.) * displace(u.y, vec3(27.0, vec2(8.0)), 2.);
		arms = min(arms, m);

		u = p;
		u.x = -abs(u.x);
		u.x += 760.0;
		u.y += 380.;

		u.y = abs(u.y);
		u.y -= 0.04 * u.x;
	 	m = u.y * u.y * 0.005;
		u.x -= m * step(u.x, 50.);
		n = roundCylinder(u, 130., 135., 10.);

		u= p;
		f = 10.;
		k = 1. / pow(10.,17.5);
		u.x = -abs(u.x);
		u.x += 660.0;
		u.y += 380.;
		u.x += 0.1 * (110. - abs(u.y));
		u.y *= 0.45;
		u.x *= 0.5;
		c = step(length(u.xy), 110.) * step(p.z, 0.) * clamp(exp( -k*pow(length(u.xy), f)), 0., 1.);

		n -= 20. * c;
		arms = min(arms, n);

		u = p;
		u.x = -abs(u.x);
		u.x += 890.0;
		u.y += 380.;
		m = length(u);
		s = m - 130.;
		u *= rotX(90.);
		s += 10.* displace(u.x, vec3(1270.0, vec2(80.0)), 2.) * displace(u.y, vec3(27.0, vec2(8.0)), 2.);
		arms = min(arms, s);

		u = p;
		u.x = -abs(u.x);
		u.y += 50. + 380.;
		u.x += 1140.;
		l = u.x - 200.;
		l = 1.0 +  0.000005 * l * l;
		u.y *= l;
		u.z *= l;
		u.y -= 50.;

		f = roundCylinder(u, 170., 110., 15.);

		u.x -= 190.;
		u.x -= 0.5 * u.y;
		l = 10. * displace(u.x, vec3(400., vec2(20.)), 1.);
		f -= l;

		arms = min(arms, f);

		arms *= 0.5;
		outData.x = min(outData.x, arms);
		if(outData.x == arms) {
			outData.y = 3.;
			outData.y += (7.0 - outData.y) * step(w, 160.2);
			outData.y += (7.0 - outData.y) * step(m, 130.2);
			if(arms == n * 0.5) outData.y = 2.0;
			if(arms == f * 0.5) {
				outData.y = 2.0;
				outData.y += (8. - outData.y) * step(1. - l, 0.99);
			};
			outData.z = 4.;
		}

		u = p;
		float h = 160.;
		c = 70.;
		u.y += c + 1100.;
		m = (u.y - h) * step(u.y, h);
		u.y -= c;
		u.x *= 1.0 - 0.0011 * u.y * step(u.y, h);
		u.x *= 1.0 + 0.00002 * m * m;
		u.z *= 1.0 + 0.00001 * m * m;


		float hips = roundCylinderH(u, h, 290., 20.);
		hips = max(hips, p.y + 970.);

		v = u = p;
		v.x = u.x = abs(p.x);

		v.y += 0.2 * v.x + 910.;
		m = displace(v.y, vec3(230., vec2(10.)), 2.);


		v.y = p.y + 920. - 0.2 * (u.x - 250.0);
		m *= displace(v.y, vec3(230., vec2(10.)), 2.);

		hips -= 20.0 * m;

		u= p;
		f = 10.;
		k = 1. / pow(10., 17.);
		u.y += 950.;
		u.x *= 0.5;
		s = step(length(u.xy), 100.) * step(p.z, 0.) * clamp(exp( -k*pow(length(u.xy), f)), 0., 1.);

		hips -= 20. * s;

		hips *= 0.5;
		outData.x = min(outData.x, hips);
		if(outData.x == hips){
			outData.y = 2.;
			outData.y += (8. - outData.y) * step(1. - m, 0.99);
			outData.z = 4.;
		}

		u = p;
		u.x = -abs(u.x);
		u.y += 1440.;
		u.x += 190.;

		u.x *= 1.0 - 0.0003 * u.y;
		m = u.z * u.z * 0.004;
		u.z *= 0.8;
		u.y -= m * step(u.y, 50.);

		float legs = roundCylinderH(u, 240., 140., 5.);

		u.y -= 240.;
		legs = min(legs, length(u)- 140.);

		u = p;
		u.x = -abs(p.x);
		u.x += 190.;
		u.y += 1660.;
		u.z -= 30.;
		m = length(u);
		legs = min(legs, m - 125.);

		u = p;
		u.x = -abs(p.x);
		u.x += 190.;
		u.y += 2020.;

		l = u.z + 200.;
		n = l * l * 0.0015;
		f = u.z * .5;
		u.z *= 0.9;

		u.y += f;
		u.y -= n * step(u.y, 260.);

		u.x *= 1.0 + 0.0004 * u.y;
		u.z *= 1.0 + 0.001 * u.y;
		s = roundCylinderH(u, 280., 150., 10.);
		f = 15. * step(u.y, -190.);
		s -= f;

		an = 5.;
		u.y -= 200.;
		u.y *= 0.8;
		k = 1. / pow(10., 10.7);
		an = step(length(u.xy), 200.) * step(p.z, 0.) * clamp(exp( -k * pow(length(u.xy), an)), 0., 1.);

		s -= an * 55.;

		legs = min(legs, s);

		u = p;
		u.x = abs(p.x);
		u.x -= 190.;
		u.y += 2200.;
		c = length(u);
		legs = min(legs, c - 140.);

		u = p;
		u.x = -abs(p.x);
		u.x += 190.;
		legs += 10. * displace(u.x, vec3(25., vec2(12.)), 2.);

		u = p;
		u.x = abs(p.x);
		u.x -= 350.;
		u.y += 2200.;
		n = roundCylinder(u, 30.0, 85.0, 20.0);
		u.x += 315.;
		n = min(n, roundCylinder(u, 30.0, 85.0, 20.0));

		h = 10.;
		k = 1. / pow(10., 17.5);
		n += 10.* step(length(u.yz), 80.) * clamp(exp( -k*pow(length(u.yz), h)), 0., 1.);

		legs = min(legs, n);
		n = length(u.yz);

		legs *= 0.7;
		outData.x = min(outData.x, legs);
		if(outData.x == legs) {
			outData.y = 2.;
			outData.y += (7.0 - outData.y) * step(m, 126.);
			outData.y += (8. - outData.y) * step(1. - f, 0.9);
			outData.y += (8. - outData.y) * step(n, 86.);
			outData.y += (7.0 - outData.y) * step(c, 141.);
			outData.z = 4.;
		}

		u = p;
		u.x = abs(p.x);
		u.x -= 190.;
		u.y += 2500.;
		v = u;
		u.z += 90.;
		u.z *= 0.5;
		u.y = 0.002 * u.y * u.y;
		u.x *= 0.85 - u.z *u.z * 0.00001;
		u.y *= 1.2;
		float shoes = length(u) - 150.;
		shoes = max(shoes, -v.y + 60.);
		v.y -= 40.;
		m = displace(v.y, vec3(100., vec2(7.)), 2.);
		shoes -= 15. * m;

		f = displace(v.x, vec3(700, vec2(50.)), 2.) * step(-v.y, -59.) * step(v.z + v.y, -140.);
		shoes -= 10. * f;

		n = displace(v.x, vec3(180, vec2(50.)), 2.) * step(-v.y, -59.) * step(-v.z, 30.);
		shoes -= 10. * n;

		outData.x = min(outData.x, shoes);
		if(outData.x == shoes) {
			outData.y = 2.;
			outData.y += (1. - outData.y) * step(1. - m, 0.99);
			outData.y += (8. - outData.y) * step(1. - f, 0.99);
			outData.y += (8. - outData.y) * step(1. - n, 0.99);
		}

		p.x = abs(p.x);
		p.xy += vec2(-1450., 400.);
		p *= 1.2;
		p *= rotX(-50.);

		u = p;
		bh = u.x / 30. + 0.5;
		bh *= bh * bh;
		vec2 g = vec2(1. / max(1. + (bh * bh), 0.00001), 0.);

		u.z = abs(p.z);
        bh = u.x / 35. + 2.5;
        bh *= bh * bh;
		u.yz *= vec2(1.0 + 0.6 * (1. / max(1. + (bh * bh), 0.00001), 0.));

		u.z += 1.9 * u.x;
		u.z *= 1.0 - 0.305 * g.x * step(p.z, 0.);
		u.z -= 1.9 * u.x;

		g.x = clamp((u.x + 123.) / 200., 0., 1.);
		u.y *= 1.0 + 2.2 * pow(g.x, 0.8);
		u.x = 0.00002 * u.x * u.x * u.x;

		float hands = length(u) - 100.;

		g.x = displace(u.y, vec3(225., vec2(100.)), 2.) * displace(u.z, vec3(140., vec2(20.)), 2.);
		g.x *= step(-p.x, -110.);
		hands += 300. * g.x;

		g.x = displace(u.x - 12., vec3(18., vec2(7.)), 2.);
		hands -= 10. * g.x;

		g.x = p.x - 10.;
		u.z = abs(p.z);
		u.z += 0.005 * g.x * g.x;
		g.x = displace(u.x, vec3(2.1, vec2(1.)), 2.) * displace(u.z + 10., vec3(175., vec2(30.)), 2.);
		hands -= 15. * g.x * step(-u.y, 0.);

		hands *= 0.3;

		u = vec3(p) + vec3(-140., 50., -100.);
		g.x = 55.;
		u.y -= 50. * cos(0.008 * u.x);
		for (int i = 0; i < 4; i++) {
			u.xz += vec2(-17., 40.);
			g.x += 17.;
			if(i == 3) {
				g.x -= 30.;
				u.x += 30.;
			}
			g.y = roundCylinder(u, g.x, 20., 20.);
			hands = min(hands, g.y);
		}

		u = vec3(p) + vec3(-60., 0., 135. + 26. * cos(.024 * p.x + 0.8));
		u *= rotY(-33.);
		g.x = roundCylinder(u, 75., 20., 20.);

		outData.x = min(outData.x, hands);
		if(outData.x == hands) outData.y = 2.;


		return outData;
	}


	vec3 gradient( vec3 v ) {
		const vec3 delta = vec3( grad_step, 0.0, 0.0 );
		float va = coloring( v ).x;
		return normalize (
			vec3(
				coloring( v + delta.xyy).x - va,
				coloring( v + delta.yxy).x - va,
				coloring( v + delta.yyx).x - va
			)
		);
	}

    vec3 ray_marching_head( vec3 origin, vec3 dir, float start, float end ) {
        float depth = start;
        vec3 salida = vec3(end);
        vec3 dist = vec3(2800.0);
        for ( int i = 0; i < max_iterations; i++ ) 		{
            if ( dist.x < stop_threshold || depth > end ) break;

                dist = coloring_head( origin + dir * depth );
                depth += dist.x;
        }

        salida = vec3(depth, dist.y, dist.z);
        return salida;
    }

	vec3 ray_marching( vec3 origin, vec3 dir, float start, float end ) {
		float depth = start;
		vec3 salida = vec3(end);
		vec3 dist = vec3(2800.0);
		for ( int i = 0; i < max_iterations; i++ ) 		{
			if ( dist.x < stop_threshold || depth > end ) break;

                dist = coloring( origin + dir * depth );
                depth += dist.x;
		}

		salida = vec3(depth, dist.y, dist.z);
		return salida;
	}

	float shadow( vec3 v, vec3 light ) {
		vec3 lv = v - light;
		float end = length( lv );
		lv /= end;

		float depth = ray_marching( light, lv, 2800.0, end ).x;

		return step( end - depth, 0.5);
	}

	vec3 shading( vec3 v, vec3 n, vec3 eye, vec3 lightMix) {

		vec3 final = vec3( 0.0 );

		vec3 ev = normalize( v - eye );
		vec3 ref_ev = reflect( ev, n );

		{
			vec3 light_pos   = vec3(0.0, 5000.0, -5000.0);
			vec3 vl = normalize( light_pos - v );
			float diffuse  = max( 0.0, dot( vl, n ) );
			float specular = max( 0.0, dot( vl, ref_ev ) );
			specular = pow( specular, lightMix.x );
			final += vec3( 0.9 ) * ( diffuse * lightMix.y + specular * lightMix.z);

			#ifdef SHADOWS
			final = final * (0.75 + 0.25 * shadow( v, light_pos ));
			#endif

			final += vec3(0.19);
		}


		return final;
	}

	vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
		vec2 xy = pos - size * 0.5;

		float cot_half_fov = tan(radians( 90.0 - fov * 0.5 ));
		float z = size.y * 0.5 * cot_half_fov;

		return normalize( vec3( xy, z ) );
	}

	vec3 getColor(vec3 data) {
		vec3 color = vec3(0.0);
		if(data.y == 0.0) color = vec3(0.9803, 0.8627, 0.7058);

		if(data.y == 1.0) color = vec3(0.4313, 0.1960, 0.5098);

		if(data.y == 2.0) color = vec3(1.0);

		if(data.y == 3.0) color = vec3(0.15); // negro

		if(data.y == 4.0) color = vec3(0.5, 0.7, 0.9) * (0.2 + 0.8 * abs(cos(data.z - 1.7)));

		if(data.y == 5.0) color = vec3(0.2745, 0.1960, 0.1176);

		if(data.y == 6.0) color = vec3(0.1); // casco
		if(data.y == 7.0) color = vec3(0.7);

		if(data.y == 8.0) color = vec3(0.3764, 0.6784, 0.0);

		if(data.y == 9.0) color = vec3(0.7, 0.0, 0.0);

		if(data.y == 10.0) color = vec3(0.0, 0.3607, 0.2078);

		if(data.y == 11.0) color = vec3(0.0, 0.4745, 0.7372);

		if(data.y == 12.0) color = vec3(0.2627, 0.5882, 0.6980);

		return color;
	}

	vec3 getMat(float data) {
		vec3 lightMix = vec3(0.0);
		bool cond = data >= 4.;
		lightMix.x = cond ? 64. : 1.;
		lightMix.y = cond ? 0.4 : 0.36;
		lightMix.z = cond ? 1.9 : 0.1;
		return lightMix;
	}

	void mainImage( out vec4 fragColor, in vec2 fragCoord )
	{
		vec3 rd = ray_dir(50.0, iResolution.xy, fragCoord.xy );

		vec3 eye = vec3( 0.0, 000.0, -4800.0 );

		vec3 color = vec3(0.12);

		vec3 data = ray_marching( eye, rd, 2800.0, clip_far );
		if ( data.x < clip_far ) {

			vec3 pos = eye + rd * data.x;
			vec3 n = gradient( pos );

			vec3 lightColor =  shading( pos, n, eye, getMat(data.z)) * 2.0;
			color = getColor(data) * lightColor;

			//Casco...
			if(data.y == 6.0) {
				color += 0.1 * textureCube(iChannel0, n).rgb;
				rd = refract(rd, n, 1.01);
				data = ray_marching_head( eye, rd, data.x + 50.0, clip_far);
				if ( data.x < clip_far ) {
					pos = eye + rd * data.x;
					n = gradient( pos );
					lightColor =  shading( pos, n, eye, getMat(data.z)) * 2.0;
					color += 0.37 * getColor(data) * lightColor;
				}
			}
		}

		fragColor = vec4(color, 1.0 );
	}