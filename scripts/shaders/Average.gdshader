//shader_type canvas_item;
//
//uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
////uniform float lod: hint_range(0.0, 5) = 3000.0;
//
//void fragment() {
//	COLOR = textureLod(screen_texture, SCREEN_UV, 4.0);
//	if (COLOR.g > 0.5)
//	{
//		COLOR.g=0.0;
//		COLOR.r=1.0;
//	}
////	COLOR.b=1.0;
//}



shader_type canvas_item;

uniform float blur_amount = 2;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
}