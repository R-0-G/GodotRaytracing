shader_type canvas_item;

//gotta be some transparency or something going on at certain points
//invalid direction of the rotation matrix but at this point i dont know that i care. 
// probably could adjust the projection matrix to account for the rotation 
// ensure that scaling, rotating and positinoing works as expected 

uniform vec4 viewParams;
uniform vec4 world_space_camera_pos;
uniform mat4 cam_local_world;
uniform sampler2D sphere_locations; //each pixel is a sphere
uniform sampler2D sphere_colours; 
uniform sampler2D sphere_sizes;
uniform vec3 max_bounds;
uniform vec3 min_bounds;
uniform int sphere_count;


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
};

HitInfo RaySphere(inout Ray ray, in vec3 sphereCenter, in float sphereRadius)
{
	HitInfo hitInfo;
	hitInfo.didHit = false;
	hitInfo.dst = 0.0;
	hitInfo.hitPoint = vec3(0.0);
	hitInfo.normal = vec3(0.0);
	
	vec3 offsetRayOrigin = ray.origin - sphereCenter;
	
	float a = dot(ray.dir, ray.dir);
	float b = dot(offsetRayOrigin, ray.dir) * 2.0;
	float c = dot(offsetRayOrigin, offsetRayOrigin) - sphereRadius * sphereRadius;
	float discriminant = b*b-4.0*a*c;
	
	if (discriminant >= 0.0)
	{
		float dist = (-b - sqrt(discriminant))/(2.0*a);
		if (dist >= 0.0)
		{
			hitInfo.didHit=true;
			hitInfo.dst = dist;
			hitInfo.hitPoint = ray.origin + ray.dir * dist;
			hitInfo.normal = normalize(hitInfo.hitPoint - sphereCenter);
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
	
	for (int i = 0; i<sphere_count; i++)
	{
		vec3 pos = texture(sphere_locations, vec2(0, 0)).xyz;
		pos.x = mix(min_bounds.x, max_bounds.x, pos.x);
		pos.y = mix(min_bounds.y, max_bounds.y, pos.y);
		pos.z = mix(min_bounds.z, max_bounds.z, pos.z);
		
		float rad = texture(sphere_sizes, vec2(0, 0)).x;
		
		HitInfo hi = RaySphere(ray, pos, rad);
		
		if (hi.dst < hitInfo.dst || hitInfo.didHit == false)
		{
			hitInfo = hi;
		}
	}
	
	return hitInfo;
}



void fragment() {

	vec3 viewPointLocal = vec3((UV.x-0.5), (UV.y-0.5), 1.0)* viewParams.xyz; //gets the pixels location in local space

	vec3 viewPoint = (vec4(viewPointLocal,1.0) * cam_local_world).xyz ; 
	//viewPoint.b = -viewPoint.b; //this is literally the thing thats breaking everything we will figure this out when less tired

	Ray ray;
	ray.origin = world_space_camera_pos.xyz;
	vec3 test = viewPoint-ray.origin; // if you think this isnt working in neg axis how could it display neg cols
	ray.dir = normalize(test); //this shouldnt change with linear motion of cam
	//COLOR = vec4((viewPoint), 1.0); 
//	COLOR = vec4((ray.dir), 1.0); 
	
	HitInfo hit = RayCalc(ray);
	if (hit.didHit)
	{
		//COLOR = vec4(vec3(hit.dst), 1);
		COLOR = texture(sphere_colours, vec2(0, 0));
	}
	else
	{
		COLOR = vec4(vec3(0), 1);
	}
	
	
//	COLOR = vec4(normalize(viewPoint), 1);
}

