extends "res://scripts/Level.gd"
## Level 1 — The Library.  Gentle introduction.  Wide platforms, slow enemies.

func _setup_level_data() -> void:
	level_number = 1
	bg_top    = Color(0.06, 0.06, 0.18)
	bg_bottom = Color(0.10, 0.08, 0.22)

	# Ground + platforms  [col, row, width, height]
	# Screen is 320×180 pixels, TILE=16 → 20×11 tiles
	platform_data = [
		# Ground row  (row 10 = y 160)
		[0, 10, 20, 1],
		# Platforms
		[2,  7,  5, 1],
		[8,  5,  4, 1],
		[13, 7,  5, 1],
		[4,  3,  6, 1],
		[12, 3,  5, 1],
	]

	# Enemies  [col, row, speed_mult, face_right]
	enemy_data = [
		[3,  7, 1.0, true],
		[14, 7, 1.0, false],
		[5,  3, 0.9, true],
	]

	# Collectibles  [col, row, is_boost]
	collectible_data = [
		[3,  6,  false],
		[4,  6,  false],
		[5,  6,  false],
		[9,  4,  false],
		[10, 4,  false],
		[14, 6,  false],
		[15, 6,  false],
		[16, 6,  false],
		[6,  2,  false],
		[7,  2,  false],
		[13, 2,  true ],  # Coffee cup
	]

	# Hazards  [col, row]
	hazard_data = [
		[11, 10],
		[7,  10],
	]

	exit_pos = Vector2(17, 3)
