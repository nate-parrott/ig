import json

def generate_quiz():
	n_cols = 2
	n_rows = 10
	n_options = 4
	padding = 40
	option_size = 30
	header_height = 100
	footer_height = 50
	question_label_width = 40
	col_width = question_label_width + n_options*option_size + 20
	row_height = option_size + 20
	d = {
		"width": padding*2 + n_cols*col_width,
		"height": padding*2 + header_height + n_rows*row_height + footer_height,
		"questions": [],
		"markups": [],
		"fields": {}
	}
	# d['markups'].append({"x": d['width']-padding-300, "y": padding+10, "w": 300, "h": 16, "markup": "<div class='label' style='font-size: 16; text-align: right'>Basic 20 0.1</div>"})
	
	d['markups'].append({"x": padding+question_label_width, "y": padding+10, "w": 300, "h": 16, "markup": "<div class='label' style='font-size: 16'>Name</div>"})
	d['fields']['name'] = {"x": padding+question_label_width, "y": padding+30, "w": 300, "h": 50}
	for col in xrange(n_cols):
		for row in xrange(n_rows):
			d['questions'].append({"x": padding+col_width*col+question_label_width, "y": padding+header_height+row_height*row, "w": option_size*n_options, "h": option_size, "options": n_options})
			d['markups'].append({"x": padding+col_width*col, "y": padding+header_height+row_height*row+option_size*0.2, "w": question_label_width, "h": option_size, "markup": "<div class='label' style='text-align: right; font-size: %f; white-space: pre'>%i </div>"%(option_size*0.6, len(d['questions']))})
	
	logo_width = 150
	logo_height = 50
	d['markups'].append({"x": padding+10, "y": d['height']-padding-logo_height, "w": logo_width, "h": logo_height, "markup": "<img src='logo.png' style='width: 100%; height: 100%'/>"})
	return d

json.dump(generate_quiz(), open('quiz.json', 'w'))
