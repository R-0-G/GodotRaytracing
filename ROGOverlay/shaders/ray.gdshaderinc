#include "res://addons/ROGodot/ROGOverlay/shaders/random.gdshaderinc"

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

vec3 diffuse_bounce(vec3 normal, inout uint seed)
{
	vec3 dir = random_dir_unit_sphere(seed);
	return dir * sign(dot(normal, dir));
}