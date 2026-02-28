shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform float label_height = 100.0;
uniform float distance_from_top = 14.0;

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	float alpha = texture(TEXTURE, UV).a;

	float g = clamp((local_y - distance_from_top) / (label_height - distance_from_top), 0.0, 1.0);

	vec4 gradient = mix(top_color, bottom_color, g);

	COLOR = vec4(gradient.rgb, alpha);
}
