extends Node

var min_distance = 100
var number_of_points = 20

func gen_points(height, width):
	var points = []
	for i in number_of_points:
		points.append(rand_coords(height, width, points, 100))
	return points
		
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
		
func is_valid_coords(pos, points):
	for p in points:
		if p.distance_to(pos) < min_distance:
			return false
	return true
	
func make_graph(height, width):
	var points = gen_points(height, width)
	var delaunay_points = Geometry2D.triangulate_delaunay(points)
	var edges = []
	for triangle_index in len(delaunay_points) / 3:
		for n in 3:
			var i = delaunay_points[(triangle_index *3) + n]
			var j = delaunay_points[(triangle_index *3) + ((n + 1) % 3)]
			edges.append([points[i],points[j]])
	return [points, edges]
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#var pos_graph = make_graph(800, 800)
	#print(pos_graph)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
