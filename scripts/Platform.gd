tool
extends KinematicBody2D

export (int) var width = 1 setget set_width

func _ready():
	set_width(width)

func set_width(i):
	width = i
	update_tilemap()
	update_collision_shapes()

func update_tilemap():
	$TileMap.clear()
	for idx in range(width):
		var centered_idx = idx - int(width / 2)
		$TileMap.set_cell(centered_idx, 0, 0)
		$TileMap.update_bitmask_area(Vector2(centered_idx, 0))
	$TileMap.position.x = -32 * (width % 2)

func update_collision_shapes():
	$CollisionShape2D.shape.extents.x = width * 32
	$Area2D/CollisionShape2D.shape.extents.x = width * 32
