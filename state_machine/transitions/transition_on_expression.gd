class_name TransitionOnExpression
extends Transition

@export var source: NodePath
@export var expression_text: String

var _expr := Expression.new()
var _source: Node

func _ready():
	if source:
		_source = get_node(source)
	if expression_text != "":
		var parse_result = _expr.parse(expression_text, ["self"])
		if parse_result != OK:
			push_error("Invalid expression: %s" % expression_text)

func can_transition() -> bool:
	if not _expr or not _source:
		return false
	var result = _expr.execute([], self)
	if _expr.has_execute_failed():
		return false
	return bool(result)
