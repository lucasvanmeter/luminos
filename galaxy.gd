extends Node2D

signal star_clicked(who)

var star_scene = preload("res://star.tscn")

var color_dict = {
	"white": Color.WHITE,
	"red" : Color.RED,
	"blue" : Color.BLUE
}

# Code for generating position graph
var width = 800
var height = 800
var min_distance = 100
var number_of_points = 20

func rand_coords(height, width, points, attempts):
	if attempts == 0:
		print("Error, could not gen random points.")
		return false
	var x = randf() * width + 100
	var y = randf() * height + 100
	var pos = Vector2(x,y)
	if is_valid_coords(pos, points):
		return pos
	else:
		return rand_coords(height, width, points, attempts-1)
		
func gen_points(height, width):
	var points = []
	for i in number_of_points:
		points.append(rand_coords(height, width, points, 20))
	return points
		
func is_valid_coords(pos, points):
	for p in points:
		if p.distance_to(pos) < min_distance:
			return false
	return true
	
func make_position_graph(height, width):
	var points = gen_points(height, width)
	var delaunay_points = Geometry2D.triangulate_delaunay(points)
	var edges = []
	for triangle_index in len(delaunay_points) / 3:
		for n in 3:
			var i = delaunay_points[(triangle_index *3) + n]
			var j = delaunay_points[(triangle_index *3) + ((n + 1) % 3)]
			edges.append([points[i],points[j]])
	return [points, edges]

func new_star(pos, power, color, parent):
	var star = star_scene.instantiate()
	star.position = pos
	star.power = power
	star.color = color
	star.clicked.connect(_on_star_clicked)
	star.parent = parent
	return star
	
func make_star_graph(pos_graph):
	var dict = {}
	var points = []
	for n in len(pos_graph[0]):
		var loc = pos_graph[0][n]
		var color
		var power
		if n <= 7:
			color = "blue"
			power = 10
		elif n <= 14:
			color = "red"
			power = 10
		else:
			color = "white"
			power = 5
		#var rand_color = color_dict.keys().pick_random()
		var star = new_star(loc, power, color, null)
		dict[loc] = star
		points.append(star)
	var edges = []
	for edge in pos_graph[1]:
		edges.append([dict[edge[0]], dict[edge[1]]])
	return [points, edges]
	
func make_neighbor_dict(graph):
	var dict = {}
	for p in graph[0]:
		dict[p] = []
	for edge in graph[1]:
		dict[edge[0]].append(edge[1])
		dict[edge[1]].append(edge[0])
	return dict
	
var position_graph = make_position_graph(800, 800)
var star_graph = make_star_graph(position_graph)
var neighbor_dict = make_neighbor_dict(star_graph)

# Called when the node enters the scene tree for the first time.
func _ready():
	for star in star_graph[0]:
		add_child(star)
		
func _draw():
	for edge in position_graph[1]:
		draw_line(edge[0], edge[1], Color.WHITE, 1.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func launch_star(source,target):
	var new_star = new_star(source.position, source.power, source.color, source)
	add_child(new_star)
	new_star.target = (target.position)
	new_star.stop_growth()
	
	source.update_power(0)
	
	source.hide_selected()

func _on_star_clicked(who):
	star_clicked.emit(who)

			
			
			
