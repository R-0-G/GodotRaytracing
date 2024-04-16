shader_type canvas_item;

void vertex() {
	
}

void fragment() {
	COLOR = vec4(UV, 1, 1);
	//ALPHA = abs(sin(TIME));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
