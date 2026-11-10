extends RefCounted
## Original generated prop atlas: four columns, three rows; see assets/art/README.md.
const ATLAS: Texture2D = preload("res://assets/art/lagos-props-v1.png")
const CELLS := {
	"room": 0, "food": 1, "kiosk": 2, "clothes": 3,
	"parcel": 4, "stock": 5, "bus": 6, "bed": 7,
	"desk": 8, "chair": 9, "plant": 10, "generator": 11,
}

static func sprite(prop: String, width: float) -> Sprite2D:
	var cell := Vector2(ATLAS.get_width() / 4.0, ATLAS.get_height() / 3.0)
	var index: int = CELLS[prop]
	var region := AtlasTexture.new()
	region.atlas = ATLAS
	region.region = Rect2(Vector2(index % 4, index / 4) * cell, cell)
	region.filter_clip = true
	var result := Sprite2D.new()
	result.name = "PixelArt"
	result.texture = region
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.scale = Vector2.ONE * (width / cell.x)
	result.position.y = 20.0 - width * 0.5
	return result
