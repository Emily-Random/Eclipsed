extends Node2D
var player: Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health += 1
		self.queue_free()
