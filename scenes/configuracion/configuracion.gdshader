shader_type canvas_item;

// Toma la textura de lo que está renderizado detrás del ColorRect
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Controla la intensidad del desenfoque
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
// Controla qué tan oscuro se vuelve el fondo (1.0 = normal, 0.5 = más oscuro)
uniform float darken_amount : hint_range(0.0, 1.0) = 0.7;

void fragment() {
    // Lee la pantalla con un nivel de detalle (LOD) para generar el blur
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    // Oscurece un poco el fondo para que la UI resalte más
    color.rgb *= darken_amount;
    COLOR = color;
}