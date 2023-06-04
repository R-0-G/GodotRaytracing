shader_type canvas_item;

#include "res://scripts/shaders/random.gdshaderinc"
#include "res://scripts/shaders/ray.gdshaderinc"

#define MAX_OBJECTS 10

uniform vec4 viewParams;
uniform vec4 world_space_camera_pos;
uniform mat4 cam_local_world;
uniform vec3 sphere_locations[MAX_OBJECTS]; 
uniform vec3 sphere_colours[MAX_OBJECTS]; 
uniform vec3 sphere_emissions[MAX_OBJECTS]; 
uniform float sphere_emission_strs[MAX_OBJECTS];
uniform float sphere_sizes[MAX_OBJECTS];
uniform int sphere_count;
uniform int max_bounce;
uniform int num_ray_per_pix;

struct Material
{
	vec4 colour;
	vec3 emissionColour;
	float emissionStrength;
};

struct Sphere
{
	vec3 pos;
	float rad;
	Material material;
};

struct RayHit
{
	HitInfo hit;
	Material material;
};



RayHit RaySphere(inout Ray ray, in Sphere sphere)
{
	RayHit rayHit;
	rayHit.hit.didHit = false;
	
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
			rayHit.hit.didHit=true;
			rayHit.hit.dst = dist;
			rayHit.hit.hitPoint = ray.origin + ray.dir * dist;
			rayHit.hit.normal = normalize(rayHit.hit.hitPoint - sphere.pos);
			rayHit.material.colour = sphere.material.colour;
			rayHit.material.emissionColour = sphere.material.emissionColour;
			rayHit.material.emissionStrength = sphere.material.emissionStrength;
			
		}
	}
	
	return rayHit;
}

RayHit RayCalc(inout Ray ray)
{
	RayHit rayHit;
	rayHit.hit.didHit = false; //this needs to be set as I think it defaults to true? weird
	
	for (int i = 0; i<sphere_count; i++)
	{
		vec3 pos = sphere_locations[i];
		float rad = sphere_sizes[i];
		vec4 col = vec4(sphere_colours[i], 1);
		vec3 emi_col = sphere_emissions[i].rgb;
		float emi_str = sphere_emission_strs[i];
		Sphere sphere = Sphere(pos,rad,Material(col, emi_col, emi_str));
		
		RayHit hit = RaySphere(ray, sphere);
		
		if (hit.hit.dst < rayHit.hit.dst || rayHit.hit.didHit == false)
		{
			if (hit.hit.didHit)
			{
				rayHit = hit;
			}
		}
	}
	
	return rayHit;
}

vec3 BounceRay(vec3 normal, inout uint rngState)
{
	vec3 dir = random_dir_unit_sphere(rngState);
	return dir * sign(dot(normal, dir));
}

vec3 Trace(Ray ray, inout uint rngState, vec2 uv)
{
	vec3 incomingLight = vec3(0);
	vec3 rayColour = vec3(1, 1, 1);
	for (int i=0; i< max_bounce; i++)
	{
		RayHit hit = RayCalc(ray);
		if (hit.hit.didHit)
		{
			ray.origin = hit.hit.hitPoint;
			vec3 nrm = normalize(hit.hit.normal);
			ray.dir = BounceRay(hit.hit.normal, rngState);
			vec3 emittedLight = hit.material.emissionColour * hit.material.emissionStrength;
			incomingLight += emittedLight * rayColour;
			rayColour *= hit.material.colour.rgb;
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
	//UV is 0->1 this is basically confirmed
	// confirmed with COLOR = vec4(UV, 0.0, 1.0);
	vec2 resolution= 1.0/SCREEN_PIXEL_SIZE;
	vec2 pixelCoord = UV * resolution;
	uint rngState = uint(pixelCoord.y * resolution.x + pixelCoord.x);

	
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
	
	COLOR = vec4(pixelCol, 1.0);
}

