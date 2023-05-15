shader_type canvas_item;

uniform float throw_charge : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 texColor = texture(TEXTURE, UV);
	if (texColor.a != 0.0) {
	    if (1.0 - UV.y < throw_charge) {
	        texColor.a = 0.7;
	    } else {
	        texColor.a = 0.0;
	    }
	    COLOR = texColor;
	}
}
