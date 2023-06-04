shader_type canvas_item;

#include "res://scripts/shaders/random.gdshaderinc"
#include "res://scripts/shaders/ray.gdshaderinc"
#include "res://scripts/shaders/ray_material.gdshaderinc"
#include "res://scripts/shaders/sphere.gdshaderinc"
#include "res://scripts/shaders/camera.gdshaderinc"

uniform int max_bounce;
uniform int num_ray_per_pix;

MaterialHitInfo RayCalc(inout Ray ray)
{
	MaterialHitInfo rayHit;
	rayHit.hit.didHit = false; //this needs to be set as I think it defaults to true? weird
	
	MaterialHitInfo[] spheres = get_sphere_hits(ray);
	
	for (int i = 0; i<spheres.length(); i++)
	{
		MaterialHitInfo hit = spheres[i];
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


vec3 Trace(Ray ray, inout uint rngState, vec2 uv)
{
	vec3 incomingLight = vec3(0);
	vec3 rayColour = vec3(1, 1, 1);
	for (int i=0; i< max_bounce; i++)
	{
		MaterialHitInfo hit = RayCalc(ray);
		if (hit.hit.didHit)
		{
			ray.origin = hit.hit.hitPoint;
			vec3 nrm = normalize(hit.hit.normal);
			ray.dir = diffuse_bounce(hit.hit.normal, rngState);
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
	uint seed = rand_seed(SCREEN_PIXEL_SIZE, UV);
	Ray ray = pixel_to_ray(UV);

	vec3 totalLight = vec3(0);

	for (int i = 0; i<num_ray_per_pix; i++)
	{
		totalLight += Trace(ray, seed, UV);
	}

	vec3 pixelCol = totalLight/float(num_ray_per_pix);
	
	COLOR = vec4(pixelCol, 1.0);
}

