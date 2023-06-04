shader_type canvas_item;

//gotta be some transparency or something going on at certain points
//invalid direction of the rotation matrix but at this point i dont know that i care. 
// probably could adjust the projection matrix to account for the rotation 
// ensure that scaling, rotating and positinoing works as expected 

uniform vec4 viewParams;
uniform vec4 world_space_camera_pos;
uniform mat4 cam_local_world;
uniform vec3 sphere_locations[10]; 
uniform vec3 sphere_colours[10]; 
uniform vec3 sphere_emissions[10]; 
uniform float sphere_emission_strs[10];
uniform float sphere_sizes[10];
uniform int sphere_count;
uniform int max_bounce;
uniform int num_ray_per_pix;

struct Sphere
{
	vec3 pos;
	float rad;
	vec4 col;
	vec3 emissionColour;
	float emissionStrength;
};

struct Ray 
{
	vec3 origin;
	vec3 dir;
};

struct HitInfo
{
	bool didHit;
	float dst;
	vec3 hitPoint;
	vec3 normal;
	vec4 colour;
	vec3 emissionColour;
	float emissionStrength;
};

HitInfo RaySphere(inout Ray ray, in Sphere sphere)
{
	HitInfo hitInfo;
	hitInfo.didHit = false;
	hitInfo.dst = 0.0;
	hitInfo.hitPoint = vec3(0.0);
	hitInfo.normal = vec3(0.0);
	hitInfo.colour = vec4(1,0,0,1);
	hitInfo.emissionColour = vec3(0);
	hitInfo.emissionStrength = 0.0;
	
	vec3 offsetRayOrigin = ray.origin - sphere.pos;
	
	float a = dot(ray.dir, ray.dir);
	float b = dot(offsetRayOrigin, ray.dir) * 2.0;
	float c = dot(offsetRayOrigin, offsetRayOrigin) - sphere.rad * sphere.rad;
	float discriminant = b*b-4.0*a*c;
	
	if (discriminant >= 0.0)
	{
		float dist = (-b - sqrt(discriminant))/(2.0*a);
		if (dist >= 0.0)
		{
			hitInfo.didHit=true;
			hitInfo.dst = dist;
			hitInfo.hitPoint = ray.origin + ray.dir * dist;
			hitInfo.normal = normalize(hitInfo.hitPoint - sphere.pos);
			hitInfo.colour = sphere.col;
			hitInfo.emissionColour = sphere.emissionColour;
			hitInfo.emissionStrength = sphere.emissionStrength;
			
		}
	}
	
	return hitInfo;
}

HitInfo RayCalc(inout Ray ray)
{
	HitInfo hitInfo;
	hitInfo.didHit = false;
	hitInfo.dst = 0.0;
	hitInfo.hitPoint = vec3(0.0);
	hitInfo.normal = vec3(0.0);
	hitInfo.colour = vec4(1,0,0,1);
	hitInfo.emissionColour = vec3(0);
	hitInfo.emissionStrength = 0.0;
	
	for (int i = 0; i<sphere_count; i++)
	{
		vec3 pos = sphere_locations[i];
		float rad = sphere_sizes[i];
		vec4 col = vec4(sphere_colours[i], 1);
		vec3 emi_col = sphere_emissions[i].rgb;
		float emi_str = sphere_emission_strs[i];
		Sphere sphere = Sphere(pos,rad,col, emi_col, emi_str);
		
		HitInfo hi = RaySphere(ray, sphere);
		
		if (hi.dst < hitInfo.dst || hitInfo.didHit == false)
		{
			if (hi.didHit)
			{
				hitInfo = hi;
			}
		}
	}
	
	return hitInfo;
}

float RandomValue(inout uint state)
{
	state = state * uint(747796405) + uint(2891336453);
	uint result = ((state >> ((state >> uint(28)) + uint(4))) ^ state) * uint(277803737);
	result = (result >>uint(22)) ^ result;
	return float(result) / 4294967295.0;
}

float RandomValueNormalDistribution(inout uint state)
{
	float theta = 2.0 * 3.1415926 * RandomValue(state);
	float rho = sqrt(-2.0 * log(RandomValue(state)));
	return rho * cos(theta);
}

vec3 RandomDirection(inout uint state)
{
	float x = RandomValueNormalDistribution(state);
	float y = RandomValueNormalDistribution(state);
	float z = RandomValueNormalDistribution(state);
	return normalize(vec3(x,y,z));
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

vec3 random_vec (vec2 uv) 
{
    float x = fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
	float y = fract(sin(dot(uv.xy, vec2(122.9898,78.233))) * 432758.5453123);
	float z = fract(sin(dot(uv.xy, vec2(1442.9898,78.233))) * 4344758.5453123);
	return vec3(x,y,z);
}


vec3 BounceRay(vec3 normal, inout uint rngState)
{
	vec3 dir = RandomDirection(rngState);
	return dir * sign(dot(normal, dir));
}

vec3 BounceRaySimple(vec3 normal, vec2 uv)
{
	vec3 dir = random_vec(uv);
	return dir * sign(dot(normal, dir));
}

vec3 Trace(Ray ray, inout uint rngState, vec2 uv)
{
	vec3 incomingLight = vec3(0);
	vec3 rayColour = vec3(1, 1, 1);
	for (int i=0; i< max_bounce; i++)
	{
		HitInfo hit = RayCalc(ray);
		//return hit.colour.xyz;
		if (hit.didHit)
		{
			ray.origin = hit.hitPoint;
			vec3 nrm = normalize(hit.normal);
			//ray.dir = ray.dir - 2.0 * nrm * (dot(ray.dir, nrm)); //reflection
			ray.dir = BounceRaySimple(hit.normal, uv*float(i+1));
//			ray.dir = BounceRay(hit.normal, rngState);
			vec3 emittedLight = hit.emissionColour * clamp(hit.emissionStrength, 0,1);
//			incomingLight = rayColour;
			incomingLight += emittedLight * rayColour;
			rayColour *= hit.colour.rgb;
			//incomingLight = ray.dir;
		}
		else
		{
			break;
		}
	}
	return incomingLight;
}



void fragment() 
{
	vec2 pixelCoord = UV * SCREEN_PIXEL_SIZE;
	uint pixelIndex = uint(pixelCoord.y * SCREEN_PIXEL_SIZE.x + pixelCoord.x);
	uint rngState = pixelIndex;
	
	vec3 viewPointLocal = vec3((UV.x-0.5), (UV.y-0.5), 1.0)* viewParams.xyz; //gets the pixels location in local space
	vec3 viewPoint = (vec4(viewPointLocal,1.0) * cam_local_world).xyz ; 
	viewPoint.b = -viewPoint.b; //this is literally the thing thats breaking everything we will figure this out when less tired
	viewPoint.g = -viewPoint.g;
	
	Ray ray;
	ray.origin = world_space_camera_pos.xyz;
	vec3 dir = viewPoint-ray.origin; // if you think this isnt working in neg axis how could it display neg cols
	ray.dir = normalize(dir); //this shouldnt change with linear motion of cam
	
	vec3 totalLight = vec3(0);
	
	for (int i = 0; i<num_ray_per_pix; i++)
	{
		totalLight += Trace(ray, rngState, UV);
	}
	
	vec3 pixelCol = totalLight/float(num_ray_per_pix);
	COLOR = vec4(pixelCol, 1);
//	uint test = uint(UV.x);
//	COLOR = vec4(random_vec(UV), 1);
//	COLOR = vec4(RandomValue(test));
	//COLOR = vec4(1);

}

