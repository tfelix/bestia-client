extends VoxelGenerator

export var amplitude:float = 10.0
export var period:Vector2 = Vector2(1/10.0, 1/10.0)
export var iso_scale:float = 0.1
export var channel:int = VoxelBuffer.CHANNEL_SDF

func get_used_channels_mask () -> int:
		return 1<<channel
 
func generate_block(buffer:VoxelBuffer, origin:Vector3, lod:int) -> void:
	var stride:int = 1 << lod
	var size:Vector3 = buffer.get_size()

	var gz:int = origin.z
	for z in range(0, size.z):

		var gx:int = origin.x
		for x in range(0, size.x):
			var ht:float = amplitude * (cos(gx * period.x) + sin(gz * period.y)) # Y is correct
			if channel == VoxelBuffer.CHANNEL_SDF:
				var gy:int = origin.y
				for y in range(0, size.y):
					var sdf:float = iso_scale * (gy-ht)
					buffer.set_voxel_f(sdf, x, y, z, channel)
					gy += stride
			else:
				ht -= origin.y
				if ht > size.y:
					ht = size.y
				buffer.fill_area(1, Vector3(x, 0, z), Vector3(x+1, ht, z+1), channel)
			gx += stride
		gz += stride
