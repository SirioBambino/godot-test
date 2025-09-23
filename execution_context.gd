class_name ExecutionContext
extends RefCounted

##
## Read-only context passed to states and transitions.
##
## Contains deterministic timing and the most recent event, plus a minimal services interface
## for logging and side-effects (like emitting game actions).
##
## Responsibilities:
## - Prevent touching global engine state
## - Enable deterministic behavior
## - Make unit testing easy
##

## The state machine instance currently executing.
var machine: StateMachine

## Time since last frame (in seconds).
var delta: float

## Total elapsed time since the state machine started (in seconds).
var time: float

## The most recent event processed (can be null if none).
var last_event: Dictionary = {}

## Service interface for side-effect injection (logging, emit, etc.)
var services: Object


##
## Constructs a new immutable execution context.
##
## @param _machine The current state machine instance.
## @param _delta The delta time since the last frame.
## @param _time The total time elapsed in the machine.
## @param _last_event The most recently processed event (nullable).
## @param _services A service object with minimal surface area.
func _init(_machine: StateMachine, _delta: float, _time: float, _last_event: Dictionary, _services: Object) -> void:
	machine = _machine
	delta = _delta
	time = _time
	last_event = _last_event
	services = _services
