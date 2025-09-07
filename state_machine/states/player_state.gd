class_name PlayerState
extends State

const SPAWN = "Spawn"
const ACTIVE = "Active"
const INACTIVE = "Inactive"
const DEAD = "Dead"

var player: Player


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
