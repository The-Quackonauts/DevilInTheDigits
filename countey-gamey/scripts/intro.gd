extends Node

const LINES := [
	{
		"speaker": 0,
		"emotion": "smug",
		"text": "hello skibidy bro, i am the devil, disguised as a gnome. i shall grant you one wish, with no drawbacks trust me bro fr fr",
	},
	{
		"speaker": 1,
		"emotion": "sad",
		"text": "my girlfriend has passed recently, i want to travel back in time to before she died",
	},
	{
		"speaker": 0,
		"emotion": "smug",
		"text": "aight bet my dude, i will totally do that no cap. poggers",
	},
	{
		"speaker": 1,
		"emotion": "thinking",
		"text": "thinking: oh no but its the devil and im making a deal with him. that usually has bad connotations.",
	},
	{
		"speaker": 0,
		"emotion": "excited",
		"text": "slay queen lemme cook imma lock in twin",
	},
	{
		"speaker": 1,
		"emotion": "whispering",
		"text": "whispers: also, i wish it to be opposite day!",
	},
	{
		"speaker": 0,
		"emotion": "smug",
		"text": "now you gotta collect all the aura points to travel back in time successfully cause they open the aura portal. i wish you mid luck unc",
	},
	{
		"speaker": 0,
		"emotion": "panicked",
		"text": "wait why am i being sucked into the vortex nooo what did you do i wnated to monkeys paw you by sending you back way before your girlfriend got born i totally would have gotten you. wait, why did i say that out loud?",
	},
	{
		"speaker": 1,
		"emotion": "triumphant",
		"text": "haha, opposite day! have fun traveling to the stone age!",
	},
]

@onready var cutscene: Cutscene = $Cutscene


func _ready() -> void:
	cutscene.play(LINES, GameFlow.CAST)
	await cutscene.finished
	GameFlow.go_to(GameFlow.State.GAMEPLAY)
