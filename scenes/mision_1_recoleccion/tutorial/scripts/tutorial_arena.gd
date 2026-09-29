extends ColorRect

# Mapa decorativo del tutorial. Los muros no tienen colisión: su función es
# anticipar visualmente el lenguaje de pasillos del laberinto real.

const WALL_DARK := Color("#152947")
const WALL_MID := Color("#284d72")
const WALL_LIGHT := Color("#6f9fc4")
const PATH := Color("#12324c")
const PATH_DOT := Color("#f2c76188")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	_draw_floor_grid(size)
	_draw_corridors()
	_draw_maze_walls()

func _draw_floor_grid(size: Vector2) -> void:
	for y in range(24, int(size.y), 48):
		for x in range(24, int(size.x), 48):
			var alternating: int = int(x / 48) + int(y / 48)
			var tile_color := Color("#10283f") if alternating % 2 == 0 else Color("#0d2339")
			draw_rect(Rect2(x - 20, y - 20, 40, 40), tile_color, true)

func _draw_corridors() -> void:
	draw_rect(Rect2(60, 260, 1240, 80), PATH, true)
	draw_rect(Rect2(620, 72, 80, 510), PATH, true)
	draw_rect(Rect2(170, 88, 450, 72), PATH, true)
	draw_rect(Rect2(700, 450, 470, 72), PATH, true)
	for x in range(96, 1280, 48):
		draw_circle(Vector2(x, 300), 3.5, PATH_DOT)
	for y in range(100, 570, 48):
		draw_circle(Vector2(660, y), 3.5, PATH_DOT)

func _draw_maze_walls() -> void:
	_draw_wall(Rect2(70, 72, 100, 32))
	_draw_wall(Rect2(70, 104, 32, 120))
	_draw_wall(Rect2(250, 160, 32, 100))
	_draw_wall(Rect2(360, 104, 220, 32))
	_draw_wall(Rect2(470, 136, 32, 124))
	_draw_wall(Rect2(760, 96, 32, 164))
	_draw_wall(Rect2(792, 96, 230, 32))
	_draw_wall(Rect2(990, 128, 32, 132))
	_draw_wall(Rect2(1120, 170, 170, 32))
	_draw_wall(Rect2(1180, 202, 32, 58))
	_draw_wall(Rect2(105, 340, 32, 150))
	_draw_wall(Rect2(137, 458, 260, 32))
	_draw_wall(Rect2(365, 340, 32, 118))
	_draw_wall(Rect2(500, 340, 32, 190))
	_draw_wall(Rect2(532, 498, 88, 32))
	_draw_wall(Rect2(760, 340, 32, 110))
	_draw_wall(Rect2(792, 418, 180, 32))
	_draw_wall(Rect2(1035, 340, 32, 118))
	_draw_wall(Rect2(1035, 458, 240, 32))

func _draw_wall(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(5, 7), rect.size), Color(0.01, 0.03, 0.08, 0.72), true)
	draw_rect(rect, WALL_DARK, true)
	draw_rect(rect.grow(-4), WALL_MID, true)
	draw_line(rect.position + Vector2(5, 5), Vector2(rect.end.x - 5, rect.position.y + 5), WALL_LIGHT, 3.0)
	# Remaches cuadrados para reforzar el aspecto pixel art.
	draw_rect(Rect2(rect.position + Vector2(7, 11), Vector2(4, 4)), WALL_LIGHT, true)
	draw_rect(Rect2(rect.end - Vector2(11, rect.size.y - 11), Vector2(4, 4)), WALL_LIGHT, true)
