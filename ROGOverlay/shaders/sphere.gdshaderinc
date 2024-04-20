#include "res://addons/ROGodot/ROGOverlay/shaders/ray_material.gdshaderinc"
#include "res://addons/ROGodot/ROGOverlay/shaders/ray.gdshaderinc"

#define MAX_SPHERE_COUNT 10

uniform vec3 sphere_locations[MAX_SPHERE_COUNT]; 
uniform vec3 sphere_colours[MAX_SPHERE_COUNT]; 
uniform vec3 sphere_emissions[MAX_SPHERE_COUNT]; 
uniform float sphere_emission_strs[MAX_SPHERE_COUNT];
uniform float sphere_sizes[MAX_SPHERE_COUNT];

struct Sphere
{
	vec3 pos;
	float rad;
	Material material;
};



MaterialHitInfo get_sphere_hit(inout Ray ray, in Sphere sphere)
{
	MaterialHitInfo result;
	result.hit.didHit = false;
	
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
			vec3 hit_point = ray.origin + ray.dir * dist;
			vec3 normal = normalize(hit_point - sphere.pos);
			HitInfo hit = HitInfo(true, dist, hit_point, normal);
			result = MaterialHitInfo(hit, sphere.material);
		}
	}
	
	return result;
}

MaterialHitInfo get_sphere_index_hit (inout Ray ray, int i)
{
	vec3 pos = sphere_locations[i];
	float rad = sphere_sizes[i];
	vec4 col = vec4(sphere_colours[i], 1);
	vec3 emi_col = sphere_emissions[i].rgb;
	float emi_str = sphere_emission_strs[i];
	Sphere sphere = Sphere(pos,rad,Material(col, emi_col, emi_str));
	
	return get_sphere_hit(ray, sphere);
}


