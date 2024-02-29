extends Node

var player_color = "blue"
var ai_color = "red"


func new_game():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$AITimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ai_timer_timeout():
	var move = $AI.suggest_random_move($Galaxy.neighbor_dict, ai_color)
	if move:
		$Galaxy.launch_star(move[0],move[1])

var star_selected = false
var source
var target

func is_neighbor(source, target):
	if $Galaxy.neighbor_dict[source].has(target):
		return true
	else:
		return false
		
func _on_galaxy_star_clicked(who):
	if star_selected == false and who.position == who.target and who.color == player_color:
		star_selected = true
		who.show_selected()
		source = who
	elif star_selected == true:
		if who == source:
			star_selected = false
			who.hide_selected()
		else:
			target = who
			if is_neighbor(source, target):
				$Galaxy.launch_star(source, target)
				star_selected = false
