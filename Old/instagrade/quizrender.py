import sys
import json

markup = """
<style>
body {
	font-family: "Helvetica", sans-serif;
}
.quiz {
	margin: 60px auto;
	position: relative;
	border: 20px solid black;
}
.quiz > * {
	position: absolute;
}
.select {
	border: 1px solid #ccc;
	border-spacing: 0px;
}
.select td {
	border: 1px solid #ccc;
	color: #ddd;
	text-align: center;
	vertical-align: middle;
}
.markup > div {
	width: 100%;
	height: 100%;
}
.field {
	border: 1px solid gray;
}
.label {
	color: gray;
	font-weight: bold;
	text-transform: uppercase;
}
</style>
"""

layout = json.load(open(sys.argv[1]))
markup += "<div class='quiz' style='width: %f; height: %f'>"%(layout['width'], layout['height'])

for element in layout['questions']:
	w = element['w']
	h = element['h']
	x = element['x']
	y = element['y']
	markup += "<table class='select' style='left: %f; top: %f; width: %f; height: %f'> <tr>" % (x, y, w, h)
	letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	for i in xrange(element['options']):
		markup += "<td>"+letters[i]+"</td>"
	markup += "</tr> </table>"

for element in layout['markups']:
	w = element['w']
	h = element['h']
	x = element['x']
	y = element['y']
	markup += "<div class='markup' style='left: %f; top: %f; width: %f; height: %f'>%s</div>"%(x, y, w, h, element['markup'])

for key, element in layout['fields'].iteritems():
	w = element['w']
	h = element['h']
	x = element['x']
	y = element['y']
	markup += "<div class='field' style='left: %f; top: %f; width: %f; height: %f''></div>"%(x, y, w, h)

markup += "</div>"

print markup
