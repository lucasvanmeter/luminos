extends Node

signal ai_action(source, target)

var ai_color

func suggest_random_move(star_graph_dict, color):
	var attacks = []
	var repositions = []
	for star in star_graph_dict:
		if star.color == color:
			var weak_neighbors = []
			var ally_neighbors = []
			for neighbor in star_graph_dict[star]:
				if star.color == neighbor.color:
					ally_neighbors.append(neighbor)
				elif star.power > neighbor.power + 5:
					weak_neighbors.append(neighbor)
			var target 
			if not weak_neighbors.is_empty():
				attacks.append([star, weak_neighbors.pick_random()])
			elif not ally_neighbors.is_empty():
				repositions.append([star, ally_neighbors.pick_random()])
	if not attacks.is_empty():
		return attacks.pick_random()
	elif not repositions.is_empty():
		return repositions.pick_random()
	else:
		return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
