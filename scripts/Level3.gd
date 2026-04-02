extends "res://scripts/Level.gd"
## Level 3 — Finals Week.  Fast enemies, tight timer, many hazards.

func _setup_level_data() -> void:
	level_number = 3
	bg_top    = Color(0.12, 0.04, 0.04)
	bg_bottom = Color(0.18, 0.06, 0.06)

	platform_data = [
		[0,  10, 20, 1],    # ground
		[1,   8,  2, 1],
		[4,   7,  2, 1],
		[7,   5,  2, 1],
		[10,  7,  2, 1],
		[13,  5,  2, 1],
		[16,  7,  2, 1],
		[2,   3,  3, 1],
		[8,   3,  4, 1],
		[14,  3,  4, 1],
		[5,   1,  3, 1],
		[11,  1,  4, 1],
	]

	enemy_data = [
		[2,   8, 1.8, true],
		[5,   7, 1.9, false],
		[8,   5, 1.7, true],
		[11,  7, 2.0, false],
		[14,  5, 1.8, true],
		[3,   3, 1.6, true],
		[9,   3, 2.0, false],
		[15,  3, 1.9, true],
	]

	collectible_data = [
		[2,  7,  false],
		[5,  6,  false],
		[8,  4,  false],
		[11, 6,  false],
		[14, 4,  false],
		[3,  2,  false],
		[4,  2,  false],
		[9,  2,  false],
		[10, 2,  false],
		[15, 2,  false],
		[16, 2,  false],
		[6,  0,  false],
		[7,  0,  false],
		[12, 0,  false],
		[8,  0,  true ],   # Coffee cups
		[13, 0,  true ],
	]

	hazard_data = [
		[3,  10],
		[6,  10],
		[9,  10],
		[12, 10],
		[15, 10],
		[6,   5],
		[12,  5],
		[9,   3],
	]

	exit_pos = Vector2(17, 1)
