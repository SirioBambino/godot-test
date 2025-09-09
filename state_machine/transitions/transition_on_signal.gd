class_name TransitionOnSignal
extends Transition

@export var source_node: NodePath
@export var signal_name: String

signal triggered

func _ready():
	#super._ready()
	if source_node and signal_name:
		var node = get_node(source_node)
		if node and node.has_signal(signal_name):
			node.connect(signal_name, Callable(self, "can_transition"))

func can_transition() -> bool:
	triggered.emit()
	return true
