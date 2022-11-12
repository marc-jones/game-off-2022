tool
extends TileSet

const Tiles = 2
const FakeDoor = 3

var binds = {
	Tiles: [FakeDoor],
	FakeDoor: [Tiles],
}

func _is_tile_bound(id, nid):
	return binds.has(id) and nid in binds[id]
