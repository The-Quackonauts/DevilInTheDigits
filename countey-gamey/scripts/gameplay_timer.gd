extends CanvasLayer

@onready var time_label: Label = $Panel/Margin/Time


func _process(_delta: float) -> void:
	time_label.text = "TIME  %s" % GameFlow.format_gameplay_time(
		GameFlow.get_gameplay_time()
	)
