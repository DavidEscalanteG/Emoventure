class_name AparienciaJugador
extends Resource

const COLOR_CABELLO_INICIAL: Color = Color("583517ff")
const COLOR_PIEL_INICIAL: Color = Color("d89878")
const COLOR_ROPA_INICIAL: Color = Color("ff0039ff")

@export var indice_cabello: int = 1
@export var indice_ojos: int = 0
@export var indice_boca: int = 0
@export var indice_cuerpo: int = 0
@export var indice_nariz: int = 0
@export var indice_cabeza: int = 0

@export var color_cabeza: Color = Color("ffcea8")
@export var color_cabello: Color = COLOR_CABELLO_INICIAL
@export var color_ojos: Color = Color("2b2afbff")
@export var color_cuerpo: Color = COLOR_PIEL_INICIAL
@export var color_nariz: Color = Color("ffcea8")
@export var color_boca: Color = COLOR_ROPA_INICIAL
