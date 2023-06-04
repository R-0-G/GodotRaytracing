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



MaterialHitInfo get_ray_sphere_hit(inout Ray ray, in Sphere sphere)
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
