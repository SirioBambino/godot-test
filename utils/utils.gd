class_name Utils

static func Vector2_to_Vector3(vector : Vector2) -> Vector3:
	return Vector3(vector.x, 0, vector.y)


static func Vector3_to_ground(vector : Vector3) -> Vector3:
	return Vector3(vector.x, 0, vector.z)


static func angle_difference(current: float, previous: float) -> float:
	return wrapf(current - previous, -PI, PI)


static func get_yaw_from_direction(direction: Vector3) -> float:
	return atan2(direction.x, direction.z)
