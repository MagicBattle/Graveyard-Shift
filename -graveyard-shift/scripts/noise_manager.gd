extends Node

# Broadcast when something makes noise
signal noise_emitted(position: Vector3, volume: float)

# Shared tuning parameters
@export var falloff: float = 12.0            # how fast sound fades with distance
@export var max_hear_distance: float = 30.0  # max distance a monster can hear
@export var wall_damping: float = 0.25       # volume multiplier if blocked by a wall

# Called by any noise source (player, items, machines, etc.)
func emit_noise(pos: Vector3, volume: float) -> void:
	emit_signal("noise_emitted", pos, volume)


# Compute perceived volume given distance and occlusion
# 'occluded' should be true if a RayCast3D detects a wall
func compute_perceived(from_pos: Vector3, to_pos: Vector3, base_volume: float) -> float:
	var distance := from_pos.distance_to(to_pos)

	# Too far away → can’t hear anything
	if distance > max_hear_distance or base_volume <= 0.0:
		return 0.0

	# Distance-based falloff (inverse-square style)
	var perceived := base_volume / (1.0 + pow(distance / falloff, 2.0))

	return perceived
