extends Node

var apariencia = {
	"indice_cabello": 1,
	"indice_ojos": 0,
	"indice_boca": 0,
	"indice_cuerpo": 0,
	"indice_nariz": 0,
	"indice_cabeza": 0,
	
	# --- AQUÍ CAMBIAS LOS COLORES DEFAULT ---
	
	# Opción A: Usar código Hexadecimal (Recomendado para tonos exactos)
	"color_cabeza": Color("ffcea8"),  # Tono de piel vainilla
	"color_cabello": Color("2e1a06"), # Marrón muy oscuro (casi negro)
	
	# Opción B: Usar colores estándar de Godot
	"color_ojos": Color.BLUE,         # Azul
	"color_cuerpo": Color.RED,        # Ropa roja
	
	# Opción C: Usar RGB (Rojo, Verde, Azul) del 0.0 al 1.0
	"color_nariz": Color("ffcea8"),   # Igual que la piel
	"color_boca": Color(1, 1, 1)      # Blanco (Color original del sprite)
}
