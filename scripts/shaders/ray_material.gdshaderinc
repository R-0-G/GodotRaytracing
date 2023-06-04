#include "res://scripts/shaders/ray.gdshaderinc"

uniform int object_count;

struct Material
{
	vec4 colour;
	vec3 emissionColour;
	float emissionStrength;
};

struct MaterialHitInfo
{
	HitInfo hit;
	Material material;
};

