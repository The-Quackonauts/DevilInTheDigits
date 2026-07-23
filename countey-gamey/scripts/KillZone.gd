extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("DEATHHHHHHHHHH")	
	body.get_node("CollisionShape2D").call_deferred("queue_free")
	get_tree().reload_current_scene.call_deferred()
