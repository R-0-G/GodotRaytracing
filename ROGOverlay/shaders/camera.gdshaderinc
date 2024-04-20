#include "res://addons/ROGodot/ROGOverlay/shaders/ray.gdshaderinc"

uniform vec4 frustrum_info; //send over a Plane() NOT a vector. 3 params should be near clip plane's width, height and distance from cam
uniform mat4 cam_local_world; //this needs a Projection() not a Transform3D. All w components need to be the position of the item. w vector should be 0
uniform vec4 world_space_camera_pos;

vec3 pixel_to_world (vec2 uv)
{
	vec3 pixel_local_pos = vec3((uv.x-0.5), (uv.y-0.5), 1.0)* frustrum_info.xyz; //gets the pixels location in local space
	vec3 pixel_world_pos = (vec4(pixel_local_pos,1.0) * cam_local_world).xyz ; 
	pixel_world_pos.z = -pixel_world_pos.z; 
	pixel_world_pos.y = -pixel_world_pos.y;
	return pixel_world_pos;
}

Ray pixel_to_ray(vec2 uv)
{
	vec3 cam_position = world_space_camera_pos.xyz;
	vec3 dir = normalize(pixel_to_world(uv)-cam_position);
	
	return Ray(cam_position, dir);
}