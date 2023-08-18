extends RigidBody3D


const ball = preload("res://ball.tscn")
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.is_in_group("ball"):
		queue_free()

func shoot():
	var main = get_tree().current_scene
	var instance = ball.instantiate()
	instance.remove_from_group("ball")
	main.add_child(instance)
	instance.position = self.position
	instance.apply_central_force(Vector3(100, 0, 0))

func _on_timer_timeout():
	shoot()
