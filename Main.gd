extends Node


var text: String
var graph: Graph


func sum_array(a: Array) -> int:
	var sum = 0
	for i in a:
		sum += i
	return sum


func write(string: String):
	$Body/Output.text += "\n" + string


func read_file(path: String) -> String:
	var t: String
	var file: File = File.new()
	file.open(path, File.READ)
	t = file.get_as_text()
	file.close()
	return t

func write_file(path: String, string: String):
	var file: File = File.new()
	file.open(path, File.WRITE)
	file.store_string(string)
	file.close()


func construct_markov_chain():
	text = text.replace("]\n", ".")
	text = text.strip_escapes()
	text = text.replace("?", ".")
	text = text.replace("!", ".")
	text = text.replace(",", "")
	text = text.replace("[", "")
	text = text.replace("]", "")
	text = text.replace("\"", "")
	
	var sentences: PoolStringArray = text.rsplit(".", false)
	for s in sentences:
		s += " N/A"
		s = s.strip_edges()
		
		var words: PoolStringArray = s.rsplit(" ")
		
		for w in words:
			w = w.strip_edges()
		
		for i  in range(words.size() - 1):
			if !graph.vertices.has(words[i]):
				graph.add_vertex(words[i], {})
			if !graph.vertices.has(words[i + 1]):
				graph.add_vertex(words[i + 1], {})
			if !graph.vertices[words[i]].data.keys().has(words[i + 1]):
				graph.add_edge(words[i], words[i + 1], true);
				graph.vertices[words[i]].data[words[i + 1]] = 1
			else:
				graph.vertices[words[i]].data[words[i + 1]] += 1


func print_chain():
	var list = graph.vertices.keys()
	list.sort()
	for v in list:
		if v != "N/A":
			write(v + ":")
			for c in graph.vertices[v].connections:
				write("    " + c + " " + String(graph.vertices[v].data[c] / float(sum_array(graph.vertices[v].data.values()))))


func generate_sentence() -> String:
	var string: String = graph.vertices.keys()[rand_range(0, graph.vertices.size())]
	
	var i = 0
	var word: String = string
	while word != "N/A" and i < 1000:
		i += 1
#		var new_word: String = graph.vertices[word].connections[rand_range(0, graph.vertices[word].connections.size())]
		var new_word: String
		
		var sum = 0
		var f = randf()
		for c in graph.vertices[word].connections:
			i += 1
			if graph.vertices[word].data[c] + sum >= 0 or (sum < graph.vertices[word].data[c] and graph.vertices[word].data[c] <= f):
				new_word = c
			else:
				sum += graph.vertices[word].data[c]
			if i > 1000:
				break
		
		string = string + " " + new_word
		word = new_word
	
	string = string.replace(" N/A", ".")
	return string


func _ready():
	pass

func _on_Run_pressed():
	$Body/Output.text = ""
	text = ""
	graph = Graph.new()
	
	text = $Body/Input.text
	construct_markov_chain()
	print_chain()


func _on_Import_pressed():
	$Body/Input.text = ""
	$Body/Input.text = read_file($TopBar/LineEdit.text)


func _on_Export_pressed():
	write_file($TopBar/LineEdit.text, $Body/Output.text)


func _on_Gen_pressed():
	$BottomBar/LineEdit.text = generate_sentence()
