#include "res://scripts/shaders/ray_material.gdshaderinc"
#include "res://scripts/shaders/ray.gdshaderinc"

#define MAX_SPHERE_COUNT 10

uniform vec3 sphere_locations[MAX_SPHERE_COUNT]; 
uniform vec3 sphere_colours[MAX_SPHERE_COUNT]; 
uniform vec3 sphere_emissions[MAX_SPHERE_COUNT]; 
uniform float sphere_emission_strs[MAX_SPHERE_COUNT];
uniform float sphere_sizes[MAX_SPHERE_COUNT];
uniform int sphere_count;

struct Sphere
{
	vec3 pos;
	float rad;
	Material material;
};



MaterialHitInfo RaySphere(inout Ray ray, in Sphere sphere)
{
	MaterialHitInfo rayHit;
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

MaterialHitInfo[MAX_SPHERE_COUNT] get_sphere_hits(Ray ray)
{
	MaterialHitInfo[MAX_SPHERE_COUNT] result;
	for (int i = 0; i<sphere_count; i++)
	{
		vec3 pos = sphere_locations[i];
		float rad = sphere_sizes[i];
		vec4 col = vec4(sphere_colours[i], 1);
		vec3 emi_col = sphere_emissions[i].rgb;
		float emi_str = sphere_emission_strs[i];
		Sphere sphere = Sphere(pos,rad,Material(col, emi_col, emi_str));
		
		result[i] = RaySphere(ray, sphere);
	}
	return result;
}
