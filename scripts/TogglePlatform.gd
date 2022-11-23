tool
extends KinematicBody2D

export (int) var width = 1 setget set_width

func _ready():
	set_width(width)
	deactivate()

func set_width(i):
	width = i
	update_tilemap()
	update_collision_shapes()

func update_tilemap():
	for tilemap in [$OfflineTileMap, $OnlineTileMap]:
		tilemap.clear()
		for idx in range(width):
			var centered_idx = idx - int(width / 2)
			tilemap.set_cell(centered_idx, 0, 0)
			tilemap.update_bitmask_area(Vector2(centered_idx, 0))
		tilemap.position.x = -32 * (width % 2)

func update_collision_shapes():
	$CollisionShape2D.shape.extents.x = width * 32
	$Area2D/CollisionShape2D.shape.extents.x = width * 32

func activate():
	collision_layer = 1
	collision_mask = 1
	$Area2D.collision_layer = 2
	$Area2D.collision_mask = 2
	$OnlineTileMap.show()

func deactivate():
	collision_layer = 0
	collision_mask = 0
	$Area2D.collision_layer = 0
	$Area2D.collision_mask = 0
	$OnlineTileMap.hide()
