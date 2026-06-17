shader_type canvas_item;

void fragment() {
    // Tomamos el color original del fotograma
    vec4 color_original = texture(TEXTURE, UV);
    
    // Calculamos el brillo usando los pesos estándar para escala de grises
    float grises = dot(color_original.rgb, vec3(0.299, 0.587, 0.114));
    
    // Aplicamos el nuevo color manteniendo la transparencia original (alpha)
    COLOR = vec4(vec3(grises), color_original.a);
}