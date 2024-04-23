shader_type canvas_item;
#include "res://addons/ROGodot/ROGOverlay/shaders/random.gdshaderinc"
#include "res://addons/ROGodot/ROGOverlay/shaders/ray.gdshaderinc"
#include "res://addons/ROGodot/ROGOverlay/shaders/ray_material.gdshaderinc"
#include "res://addons/ROGodot/ROGOverlay/shaders/sphere.gdshaderinc"
#include "res://addons/ROGodot/ROGOverlay/shaders/camera.gdshaderinc"



uniform sampler2D last_tex;
uniform int max_bounce;
uniform int num_ray_per_pix;
uniform int sphere_count;
uniform int frame_count;
uniform vec2 screen_pixel_size;

MaterialHitInfo get_ray_hit(inout Ray ray)
{
	MaterialHitInfo rayHit;
	rayHit.hit.didHit = false; //this needs to be set as I think it defaults to true? weird
	
	int total_count = sphere_count; //add to this for triangles when we get there
	
	for (int i = 0; i<total_count; i++)
	{
		MaterialHitInfo hit;
		if (i<sphere_count)
		{		
			hit = get_sphere_index_hit(ray, i);
		}
		//if i<tri_count, hit = get_tri_hit(ray, tri)
		
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


vec3 get_ray_light(Ray ray, inout uint seed)
{
	vec3 incomingLight = vec3(0);
	vec3 rayColour = vec3(1, 1, 1);
	for (int i=0; i< max_bounce; i++)
	{
		MaterialHitInfo hit = get_ray_hit(ray);
		if (hit.hit.didHit)
		{
			ray.origin = hit.hit.hitPoint;
			vec3 nrm = normalize(hit.hit.normal);
			ray.dir = diffuse_bounce(hit.hit.normal, seed);
//			ray.dir = reflect( ray.dir, hit.hit.normal)
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

vec3 get_light(Ray ray, uint seed)
{
	vec3 totalLight = vec3(0);

	for (int i = 0; i<num_ray_per_pix; i++)
	{
		totalLight += get_ray_light(ray, seed);
	}

	return totalLight/float(num_ray_per_pix);
}


void vertex() {
	
}

void fragment() {
	
	//vec4 last = vec4(textureLod(last_tex, SCREEN_UV, 0.0).rgb, 1);
	//vec4 this = vec4(cam_forward, 0.5);
	
	Ray ray = pixel_to_ray(UV);
	uint seed = rand_seed_reso(screen_pixel_size, UV);
	vec3 light = get_light(ray, seed);

	
	//COLOR=mix(this,last, 0.5);
	//COLOR = vec4(ray.dir, 0.5);
	COLOR = vec4(light, 0.9);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
