#include "res://scripts/shaders/random.gdshaderinc"

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