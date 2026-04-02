extends "res://scripts/Level.gd"
## Level 2 — The Labs.  More vertical platforms, faster enemies, more hazards.

func _setup_level_data() -> void:
	level_number = 2
	bg_top    = Color(0.04, 0.10, 0.08)
	bg_bottom = Color(0.06, 0.14, 0.10)

	# Ground + platforms
	platform_data = [
		[0,  10, 20, 1],     # ground
		[1,   8,  3, 1],
		[5,   6,  3, 1],
		[9,   4,  3, 1],
		[13,  6,  3, 1],
		[16,  8,  4, 1],
		[3,   2,  4, 1],
		[11,  2,  6, 1],
	]

	enemy_data = [
		[2,   8, 1.4, true],
		[6,   6, 1.4, false],
		[10,  4, 1.3, true],
		[14,  6, 1.5, false],
		[4,   2, 1.2, true],
	]

	collectible_data = [
		[2,  7,  false],
		[3,  7,  false],
		[6,  5,  false],
		[7,  5,  false],
		[10, 3,  false],
		[11, 3,  false],
		[14, 5,  false],
		[15, 5,  false],
		[4,  1,  false],
		[5,  1,  false],
		[12, 1,  false],
		[13, 1,  false],
		[8,  1,  true ],   # Coffee
		[17, 7,  false],
	]

	hazard_data = [
		[4,  10],
		[8,  10],
		[12, 10],
		[7,   6],
		[15,  8],
	]

	exit_pos = Vector2(16, 2)
