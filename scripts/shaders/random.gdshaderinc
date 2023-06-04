//use get_seed and pass into all of these functions

uint rand_seed(vec2 screen_pixel_size, vec2 uv)
{
	vec2 resolution= 1.0/screen_pixel_size;
	vec2 pixelCoord = uv * resolution;
	return uint(pixelCoord.y * resolution.x + pixelCoord.x);
}

float rand_value(inout uint seed)
{
	seed = seed * uint(747796405) + uint(2891336453);
	uint result = ((seed >> ((seed >> uint(28)) + uint(4))) ^ seed) * uint(277803737);
	result = (result >>uint(22)) ^ result;
	return float(result) / 4294967295.0;
}

float rand_value_norm_dist(inout uint seed)
{
	float theta = 2.0 * 3.1415926 * rand_value(seed);
	float rho = sqrt(-2.0 * log(rand_value(seed)));
	return rho * cos(theta);
}

float rand_range(inout uint seed, float min_value, float max_value)
{
	return mix(min_value, max_value, rand_value(seed));
}

float rand_range_norm_dist(inout uint seed, float min_value, float max_value)
{
	return mix(min_value, max_value, rand_value_norm_dist(seed));
}

//using norm dist prevents clumping around cube edges
vec3 random_dir_unit_sphere(inout uint seed)
{
	return normalize(vec3(rand_value_norm_dist(seed),rand_value_norm_dist(seed),rand_value_norm_dist(seed)));
}

vec3 random_dir_unit_cube(inout uint seed)
{
	return normalize(vec3(rand_value(seed),rand_value(seed),rand_value(seed)));
}

