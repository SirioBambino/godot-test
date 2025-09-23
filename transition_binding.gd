@abstract
class_name TransitionBinding
extends RefCounted

##
## Interface provided to transitions for lifecycle management.
##
## Transitions use this to:
## - Connect/disconnect signals
## - Schedule and cancel timers
## - Emit actions or log
## - Resolve state references
##

## Represents a unique handle to a connected signal.
class SignalHandle:
	var id: String = ""
	var meta: Variant

	func _init(_id: String, _meta : Variant = null) -> void:
		id = _id
		meta = _meta


## Represents a unique handle to a scheduled timer.
class TimerHandle:
	var id: String = ""
	var meta: Variant

	func _init(_id: String, _meta : Variant = null) -> void:
		id = _id
		meta = _meta


##
## Connects to a signal in the host environment.
##
## @param key A logical name or reference to the signal.
## @param callback Callable to invoke when the signal fires.
## @return SignalHandle representing the connection.
@abstract
func connect_signal(key: String, callback: Callable) -> SignalHandle;


##
## Disconnects a previously connected signal.
##
## @param handle SignalHandle returned by connect_signal().
@abstract
func disconnect_signal(handle: SignalHandle) -> void;


##
## Creates a deterministic timer.
##
## @param interval Time in seconds until the timer fires.
## @param repeat Whether the timer repeats.
## @param callback Callable to invoke when the timer elapses.
## @return TimerHandle representing the scheduled timer.
@abstract
func create_timer(interval: float, repeat: bool, callback: Callable) -> TimerHandle;


##
## Cancels a previously scheduled timer.
##
## @param handle TimerHandle returned by create_timer().
@abstract
func cancel_timer(handle: TimerHandle) -> void;


##
## Resolves a state reference (by ID, name, or instance) into a State object.
##
## Useful if transitions are defined declaratively and need to resolve names at runtime.
##
## @param ref Reference or name of the state.
## @return A State instance or null if not found.
@abstract
func resolve_state_ref(ref: Variant) -> State;


##
## Emits a domain-specific action into the outside world (e.g., "shoot", "play_sound").
##
## @param name Logical name of the action.
## @param payload Optional dictionary of arguments or metadata.
@abstract
func emit_action(name: String, payload: Dictionary) -> void;


##
## Logs a debug message via the host adapter.
##
## @param message String to output to the console or log system.
@abstract
func log(message: String) -> void;
