shader_type canvas_item;
render_mode unshaded;

varying vec4 tinte_personaje;

void vertex() {
	// En vertex, COLOR contiene modulate y self_modulate sin el color del PNG.
	tinte_personaje = COLOR;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	// Base neutra: conserva los niveles de luz y el contorno del pixel art,
	// y permite aplicar el tono, saturación y brillo elegidos sin mezclarlos
	// con el marrón, naranja o rosa de la textura original.
	float luz = max(pixel.r, max(pixel.g, pixel.b));
	COLOR = vec4(vec3(luz), pixel.a) * tinte_personaje;
}
