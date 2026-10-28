shader_type canvas_item;
render_mode unshaded;

// #D89878: tono medio de las hojas char_a_pONE1/2/3_0bas_humn_v00.
// El material usa este color como referencia para conservar la paleta dibujada.
uniform vec4 color_referencia : source_color = vec4(0.847058824, 0.596078431, 0.470588235, 1.0);
varying vec4 tinte_piel;

vec3 convertir_a_hsv(vec3 color) {
	float mayor = max(color.r, max(color.g, color.b));
	float menor = min(color.r, min(color.g, color.b));
	float diferencia = mayor - menor;
	float tono = 0.0;
	if (diferencia > 0.00001) {
		if (mayor == color.r) {
			tono = (color.g - color.b) / diferencia;
		} else if (mayor == color.g) {
			tono = (color.b - color.r) / diferencia + 2.0;
		} else {
			tono = (color.r - color.g) / diferencia + 4.0;
		}
		tono = fract(tono / 6.0 + 1.0);
	}
	return vec3(tono, mayor > 0.00001 ? diferencia / mayor : 0.0, mayor);
}

vec3 convertir_a_rgb(vec3 color) {
	vec3 canales = abs(fract(color.xxx + vec3(0.0, 0.666666667, 0.333333333)) * 6.0 - 3.0);
	return color.z * mix(vec3(1.0), clamp(canales - 1.0, 0.0, 1.0), color.y);
}

void vertex() {
	tinte_piel = COLOR;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	vec3 referencia = convertir_a_hsv(color_referencia.rgb);
	vec3 elegido = convertir_a_hsv(tinte_piel.rgb);
	vec3 original = convertir_a_hsv(pixel.rgb);
	vec3 resultado = vec3(
		fract(original.x + elegido.x - referencia.x + 1.0),
		clamp(original.y * elegido.y / max(referencia.y, 0.00001), 0.0, 1.0),
		clamp(original.z * elegido.z / max(referencia.z, 0.00001), 0.0, 1.0)
	);
	// Con el tono inicial, luces, medios, sombras y contornos conservan sus RGB.
	// Saturación cero produce piel neutra y el brillo sigue respondiendo a la barra.
	COLOR = vec4(convertir_a_rgb(resultado), pixel.a * tinte_piel.a);
}
