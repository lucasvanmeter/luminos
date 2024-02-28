extends Node2D

@export var star_scene: PackedScene
@export var number_of_stars = 5

var star_selected = false
var source
var target

var color_dict = {
	"white": Color.WHITE,
	"black": Color.BLACK,
	"red" : Color.RED,
	"green" : Color.GREEN,
	"blue" : Color.BLUE
}

const size = 800
const min_distance = 100
var number_of_points = 20

func gen_points():
	var points = []
	for i in number_of_points:
		points.append(rand_coords(points))
	return points
		
func rand_coords(points):
	var x = randf() * size + 100
	var y = randf() * size + 100
	var pos = Vector2(x,y)
	if is_valid_coords(pos, points):
		return pos
	else:
		return rand_coords(points)
		
func is_valid_coords(pos, points):
	for p in points:
		if p.distance_to(pos) < min_distance:
			return false
	return true
	
func make_graph():
	var points = gen_points()
	var delaunay_points = Geometry2D.triangulate_delaunay(points)
	var edges = []
	for triangle_index in len(delaunay_points) / 3:
		for n in 3:
			var i = delaunay_points[(triangle_index *3) + n]
			var j = delaunay_points[(triangle_index *3) + ((n + 1) % 3)]
			edges.append([points[i],points[j]])
	return [points, edges]

var graph = make_graph()

func make_neighbor_dict(graph):
	var dict = {}
	for p in graph[0]:
		dict[p] = []
	for edge in graph[1]:
		dict[edge[0]].append(edge[1])
		dict[edge[1]].append(edge[0])
	return dict
	
var neighbor_dict = make_neighbor_dict(graph)

# Called when the node enters the scene tree for the first time.
func _ready():
	for p in graph[0]:
		var rand_color = color_dict.keys().pick_random()
		make_star(p, 10, rand_color, null)
		
func _draw():
	for edge in graph[1]:
		draw_line(edge[0], edge[1], Color.WHITE, 2.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func make_star(pos, power, color, parent):
	var star = star_scene.instantiate()
	star.position = pos
	star.power = power
	star.color = color
	star.clicked.connect(_on_star_clicked)
	star.parent = parent
	add_child(star)

func launch_star(source,target):
	source.set_target(target.position)
	source.stop_growth()
	star_selected = false
	source.hide_selected()
	make_star(source.position, 0, source.color, source)

func is_valid_target(source, target):
	if neighbor_dict[source.position].has(target.position):
		return true
	else:
		return false

func _on_star_clicked(who):
	if star_selected == false and who.position == who.target:
		star_selected = true
		who.show_selected()
		source = who
	elif star_selected == true:
		if who == source:
			star_selected = false
			who.hide_selected()
		else:
			target = who
			if is_valid_target(source, target):
				launch_star(source, target)
			
			
			
