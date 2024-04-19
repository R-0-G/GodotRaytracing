shader_type canvas_item;

uniform vec3 cam_pos = vec3(0);
uniform vec3 cam_forward = vec3(0);
uniform float cam_fov = 90;
uniform float cam_near = 3;
uniform float cam_far = 100;
uniform float cutoff = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D last_tex;

void vertex() {
	
}

void fragment() {
	vec2 pos = vec2(1) * (sin(TIME*0.5)+1.0)/2.0;
	vec2 disp = pos-UV;
	
	vec4 last = vec4(textureLod(last_tex, SCREEN_UV, 0.0).rgb, 1);
	vec4 this = last;
	
	if (length(disp) < cutoff )
	{
		this= vec4(cam_forward,1);
	}
	//COLOR = ((vec4(last,1) +this)/2.0);
	COLOR=mix(this,last, 0.5);
	
	
	
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
