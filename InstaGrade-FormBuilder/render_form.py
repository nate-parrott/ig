from reportlab.pdfgen import canvas
from StringIO import StringIO
from reportlab.lib.units import inch
from reportlab.lib.pagesizes import letter
from reportlab.lib.utils import ImageReader
import re
from reportlab.lib.colors import yellow, red, black, white, gray
import math

NO_LAYOUT_BOUNDS = 9999999

# decorator for layout functions that automatically adds things like margins
def respects_margin(func):
	def func_respecting_margin(self, canvas, frame, draw):
		(left, top, right, bottom) = frame
		ml, mt, mr, mb = (0,)*4
		if hasattr(self, 'margin'):
			if type(self.margin) == tuple:
				ml, mt, mr, mb = self.margin
			else:
				ml, mt, mr, mb = (self.margin,)*4
			left += ml
			right -= mr
			top += mt
			bottom -= mb
		
		if draw and self.on_render:
			self.on_render((left,top,right,bottom))
		
		thickness = 0
		if hasattr(self, 'border'):
			color, thickness = self.border
			if draw:
				canvas.setStrokeColor(color)
				canvas.setLineWidth(thickness)
				canvas.rect(left-thickness/2.0, top-thickness/2.0, right-left+thickness/2.0, bottom-top+thickness/2.0, stroke=1)
		
		pl, pt, pr, pb = (0,)*4
		if hasattr(self, 'padding'):
			pl, pt, pr, pb = self.padding if type(self.padding)==tuple else (self.padding,) * 4
			left += pl
			right -= pr
			top += pt
			bottom -= pb
		
		qx, qy = (0,0)
		if hasattr(self, 'quantum'):
			quantum = self.quantum
			w = (right-left)
			h = (top-bottom)
			wq = math.floor(w/quantum)*quantum
			hq = math.floor(h/quantum)*quantum
			qx = (w-wq)/2.0
			qy = (h-hq)/2.0
			top += qy
			left += qx
			right -= qx
			bottom -= qy
		
		w,h = func(self, canvas, (left, top, right, bottom), draw)
		return (w+ml+mr+pl+pr+(qx)*2, h+mt+mb+pt+pb+(qy)*2)
	return func_respecting_margin

def frame_json(frame):
	pagew, pageh = (PAGE_LAYOUTER.width*1.0, PAGE_LAYOUTER.height*1.0)
	page_n = PAGE_LAYOUTER.page_number
	left, top, right, bottom = frame
	left -= PAGE_LAYOUTER.margin
	top -= PAGE_LAYOUTER.margin
	right -= PAGE_LAYOUTER.margin
	bottom -= PAGE_LAYOUTER.margin
	pagew -= PAGE_LAYOUTER.margin*2
	pageh -= PAGE_LAYOUTER.margin*2
	return [page_n, left/pagew, top/pageh, right/pagew, bottom/pageh]

class Layout(object):
	horizontal_expansion = 1
	vertical_expansion = 1
	on_render = None
	def layout(self, canvas, frame, draw):
		"""
		Should draw on the canvas only if draw=True,
		and should return a tuple of (width, height) of the drawn object,
		which does not need to fill the frame
		a "frame" is a tuple (left, top, right, bottom)
		"""
		return (0,0)

class Container(Layout):
	def __init__(self):
		self.items = []
		self.items_not_fit = []

class Vertical(Container):
	@respects_margin
	def layout(self, canvas, frame, draw):
		left, top, right, bottom = frame
		max_width = 0
		y = top
		self.items_not_fit = []
		items_to_draw = []
		heights = []
		widths = []
		for item, i in zip(self.items, xrange(len(self.items))):
			item_width, item_height = item.layout(canvas, (left, y, right, bottom), draw=False)
			if y + item_height > bottom:
				self.items_not_fit = self.items[i:]
				break
			else:
				y += item_height
				items_to_draw.append(item)
				widths.append(item_width)
				heights.append(item_height)
				max_width = max(max_width, item_width)
		if draw:
			y = top
			for item, width, height in zip(items_to_draw, widths, heights):
				item_right = right if item.horizontal_expansion else left + width
				item_width, item_height = item.layout(canvas, (left, y, item_right, y + height), draw=True)
				y += item_height
		return (max_width, y-top)

class Horizontal(Container):
	@respects_margin
	def layout(self, canvas, frame, draw):
		left, top, right, bottom = frame
		height = 0
		x = left
		self.items_not_fit = []
		items_to_draw = []
		widths = []
		horizontal_expansions = []
		for item, i in zip(self.items, xrange(len(self.items))):
			item_width, item_height = item.layout(canvas, (x, top, right, bottom), draw=False)
			if x + item_width > right + 1:
				self.items_not_fit = self.items[i:]
				break
			else:
				x += item_width
				items_to_draw.append(item)
				widths.append(item_width)
				horizontal_expansions.append(item.horizontal_expansion)
				height = max(height, item_height)
		if sum(horizontal_expansions) > 0:
			growth_per_expansion_point = (right-left - sum(widths)) * 1.0 / sum(horizontal_expansions)
			for i in xrange(len(widths)):
				widths[i] += growth_per_expansion_point * horizontal_expansions[i]
		if draw:
			x = left
			for item, width in zip(items_to_draw, widths):
				item.layout(canvas, (x, top, x + width, bottom), draw=True)
				x += width
		return (sum(widths), height)

class Columns(Container):
	count = 2
	@respects_margin
	def layout(self, canvas, frame, draw):
		items = self.items
		left, top, right, bottom = frame
		col_width = (right - left) * 1.0 / self.count
		for col in xrange(self.count):
			col_left = left + col_width * col
			stack_layout = Vertical()
			stack_layout.items = items
			stack_layout.layout(canvas, (col_left, top, col_left + col_width, bottom), draw)
			items = stack_layout.items_not_fit
		self.items_not_fit = items
		return (right-left, bottom-top)

class Text(Layout):
	font_size = 11
	font_name = "Helvetica"
	text = ""
	valign = "center"
	halign = "left"
	horizontal_expansion = 1
	
	def get_lines(self, width, canvas):
		lines = []
		for broken_line in self.text.split("\n"):
			words = []
			for word in re.split("\s+", broken_line):
				if len(words) > 0 and canvas.stringWidth(" ".join(words + [word]), fontName=self.font_name, fontSize=self.font_size) > width:
					lines.append(words)
					words = [word]
					# TODO: deal with problem of single words being too long
				else:
					words.append(word)
			if len(words):
				lines.append(words)
		return [" ".join(words) for words in lines]
	
	@respects_margin
	def layout(self, canvas, frame, draw):
		left, top, right, bottom = frame
		t = canvas.beginText()
		t.setTextOrigin(left, top + self.font_size)
		t.setFont(self.font_name, self.font_size)
		max_width = 0
		for line in self.get_lines(right-left, canvas):
			max_width = max(max_width, canvas.stringWidth(line, fontName=self.font_name, fontSize=self.font_size))
			t.textLine(line)
		if draw:
			canvas.drawText(t)
		height = t.getY() - top - self.font_size
		return (max_width, height)

class PageLayouter(object):
	def __init__(self):
		self.page_decorators = []
	container_class = Vertical
	width, height = (0, 0)
	margin = 0
	border_image = None
	border_content_proportional_insets = (0,0,0,0)
	def render(self, canvas, layout_items, draw=True):
		self.page_number = 0
		while True:
			size_minus_margin = (self.width - self.margin*2, self.height - self.margin*2)
			if self.border_image:
				canvas.drawImage(self.border_image, self.margin, self.margin, size_minus_margin[0], size_minus_margin[1], mask='auto')
			content_left = self.margin + size_minus_margin[0] * self.border_content_proportional_insets[0]
			content_top = self.margin + size_minus_margin[1] * self.border_content_proportional_insets[1]
			content_right = self.width - self.margin - size_minus_margin[0] * self.border_content_proportional_insets[2]
			content_bottom = self.height - self.margin - size_minus_margin[1] * self.border_content_proportional_insets[3]
			content_frame = (content_left, content_top, content_right, content_bottom)
			
			for dec in self.page_decorators:
				if draw:
					dec.render(self, canvas, self.page_number)
			
			container = self.container_class()
			container.items = self.initial_items_for_page(self.page_number) + layout_items
			container.layout(canvas, content_frame, draw)
			if draw:
				canvas.showPage()
			layout_items = container.items_not_fit
			if len(layout_items) == 0:
				return self.page_number + 1
			else:
				self.page_number += 1
	
	def initial_items_for_page(self, page_num):
		return []

class AnswerSheetPageLayouter(PageLayouter):
	title = ""
	total_pages = 0
	page_padding_chars = 3
	def initial_items_for_page(self, page_num):
		title = Text()
		title.text = self.title
		title.font_size = 20
		v = Vertical()
		v.items = [title]
		if self.total_pages != 1:
			subtitle = Text()
			subtitle.text = "Page {0} of {1}{2}".format(page_num+1, self.total_pages, " "*(self.page_padding_chars - len(str(self.total_pages))))
			v.items.append(subtitle)
		v.margin = (0,0,0,4)
		return [v]

class PageDecorator(object):
	def render(self, page_layouter, canvas, page_number):
		pass

class BarcodeDecorator(object):
	def __init__(self, id):
		self.id = id
	
	def render(self, page_layouter, canvas, page_number):
		left, top, right, bottom = (page_layouter.margin, page_layouter.margin, page_layouter.width-page_layouter.margin, page_layouter.height-page_layouter.margin)
		w, h = (right-left, bottom-top)
		left += w * PROPORTIONAL_COMB_MARGIN
		right -= w * PROPORTIONAL_COMB_MARGIN
		top = bottom - h * PROPORTIONAL_BARCODE_HEIGHT
		total_bits = BARCODE_HORIZONTAL_BITS*BARCODE_VERTICAL_BITS
		all_bits = '01' + bits(page_number, BARCODE_BITS_FOR_PAGE_NUM) + bits(self.id, (total_bits - BARCODE_BITS_FOR_PAGE_NUM - 2))
		canvas.setFillColor(black)
		bit_matrix = map(lambda _: ["0"] * BARCODE_HORIZONTAL_BITS, range(BARCODE_VERTICAL_BITS))
		for i in xrange(total_bits):
			col = i % BARCODE_HORIZONTAL_BITS
			row = i / BARCODE_HORIZONTAL_BITS
			bit_w = (right-left) * 1.0 / BARCODE_HORIZONTAL_BITS
			bit_h = (bottom-top) * 1.0 / BARCODE_VERTICAL_BITS
			if all_bits[i] == '1':
				bit_matrix[row][col] = '1'
				canvas.rect(left + bit_w * col, top + bit_h * row, bit_w, bit_h, fill=1)
		print "id: {0}:{1}\n, BITS: {2}\nMATRIX: \n{3}".format(self.id, bits(self.id, (total_bits - BARCODE_BITS_FOR_PAGE_NUM - 2)), all_bits, "\n".join(map(lambda x: "".join(x), bit_matrix)))
		
		
def bits(num, width):
	format_string = "{0:0>"+str(width)+"b}"
	return format_string.format(num)

BARCODE_HORIZONTAL_BITS = 14
BARCODE_VERTICAL_BITS = 2
BARCODE_BITS_FOR_PAGE_NUM = 4

PROPORTIONAL_COMB_MARGIN = 0.17
PROPORTIONAL_BARCODE_HEIGHT = 0.06

def num_available_barcode_indices():
	return 2 ** (BARCODE_HORIZONTAL_BITS * BARCODE_VERTICAL_BITS - BARCODE_BITS_FOR_PAGE_NUM - 2)

class Image(object):
	image = None
	render_at_size = (100, 100)
	def layout(self, canvas, frame, draw):
		if draw:
			stringio = StringIO()
			self.image.save(stringio, 'PNG')
			stringio.seek(0)
			canvas.drawImage(ImageReader(stringio), frame[0], frame[1], min(frame[2]-frame[0], self.render_at_size[0]), min(frame[3]-frame[0], self.render_at_size[1]))
		return self.render_at_size

class Question(Layout):
	page_size = (0,0)
	
	def __init__(self, dict, visible_index=None, show_description=False):
		self.dict = dict
		self.visible_index = visible_index
		if visible_index != None:
			self.dict['visibleIndex'] = visible_index
		self.show_description = show_description
	
	@respects_margin
	def layout(self, canvas, frame, draw):
		left, top, right, bottom = frame
		if not draw:
			bottom = NO_LAYOUT_BOUNDS
		frame = (left, top, right, bottom)
		description_text = None if not self.show_description else self.dict.get('description', None)
		if description_text == '': description_text = None
		if description_text != None and self.visible_index != None:
			vertical = Vertical()
			t = Text()
			t.text = str(self.visible_index) + ". " + description_text
			t.margin = (0, 4, 0, 4)
			vertical.items = [t, self.get_item()]
			return vertical.layout(canvas, frame, draw)
		elif self.visible_index != None:
			horiz = Horizontal()
			t = Text()
			t.horizontal_expansion = 0
			t.text = str(self.visible_index) + ". "
			horiz.items = [t, self.get_item()]
			return horiz.layout(canvas, frame, draw)
		else:
			item = self.get_item()
			return item.layout(canvas, frame, draw)
	
	def get_item(self):
		return Box()

class MultipleChoice(Question):
	def get_item(self):
		horiz = Horizontal()
		horiz.border = (gray, 1)
		horiz.items = []
		
		options = ['True', 'False'] if self.dict['type'] == 'true-false' else 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[:int(self.dict['options'])]
		
		def on_render(frame):
			self.dict['frames'] = []
		horiz.on_render = on_render
		
		for op, i in zip(options, xrange(len(options))):
			item = Text()
			item.text = op
			item.border = (gray, 1)
			item.padding = 6
			item.horizontal_expansion = 0
			horiz.items.append(item)
			def on_item_render(frame):
				self.dict['frames'].append(frame_json(frame))
			item.on_render = on_item_render
			
		horiz.horizontal_expansion = 0
		return horiz

class FreeResponse(Question):
	def get_item(self):
		b = Box()
		b.size = (1, float(self.dict['height'])*50)
		b.border = (gray, 1)
		b.horizontal_expansion = 1
		def on_render(frame):
			self.dict['frame'] = frame_json(frame)
		b.on_render = on_render
		return b

class NameField(Question):
	def get_item(self):
		t = Text()
		t.text = "Name:"
		t.margin = (0,0,0,4)
		
		b = Box()
		b.size = (1, 40)
		b.horizontal_expansion = 1
		b.border = (gray, 1)
		def on_render(frame):
			self.dict['frame'] = frame_json(frame)
		b.on_render = on_render
		
		v = Vertical()
		v.items = [t, b]
		v.horizontal_expansion = 1
		v.margin = (0,0,0,4)
		return v

class Box(Layout):
	size = (100, 100)
	@respects_margin
	def layout(self, canvas, frame, draw):
		return self.size

def find_title(form_json):
	for item in form_json['items']:
		if item['type'] == 'title':
			return item['text']
	return ""

PAGE_LAYOUTER = None

def render(form_json, output_file):
	global PAGE_LAYOUTER
	cvs = canvas.Canvas(output_file, pagesize=letter, pageCompression=1, bottomup=0)
	PAGE_LAYOUTER = AnswerSheetPageLayouter()
	PAGE_LAYOUTER.margin = inch
	PAGE_LAYOUTER.container_class = Columns
	PAGE_LAYOUTER.width, PAGE_LAYOUTER.height = letter
	PAGE_LAYOUTER.border_image = "comb.png"
	PAGE_LAYOUTER.border_content_proportional_insets = (PROPORTIONAL_COMB_MARGIN, 0, PROPORTIONAL_COMB_MARGIN, PROPORTIONAL_BARCODE_HEIGHT)
	PAGE_LAYOUTER.page_decorators.append(BarcodeDecorator(form_json['index']))
	
	separate_questions = form_json.get('separateAnswerSheetsFromQuestions', False)
	question_bodies = []
	
	items = []
	i = 1
	for dict in form_json['items']:
		type = dict['type']
		if type in ('true-false', 'multiple-choice'):
			item = MultipleChoice(dict, i, not separate_questions)
			question_bodies.append(dict.get('description', ''))
			i += 1
		elif type == 'free-response':
			item = FreeResponse(dict, i, not separate_questions)
			question_bodies.append(dict.get('description', ''))
			i += 1
		elif type == 'name-field':
			item = NameField(dict)
		else:
			item = None
		if item:
			items.append(item)
	
	if separate_questions:
		question_layouter = AnswerSheetPageLayouter()
		question_layouter.width, question_layouter.height = letter
		question_layouter.container_class = Columns
		question_layouter.title = find_title(form_json) + " Questions"
		question_items = []
		for q, i in zip(question_bodies, xrange(len(question_bodies))):
			t = Text()
			t.text = str(i) + ". " + q
			t.margin = (0,0,0,4)
			question_items.append(t)
		question_layouter.total_pages = question_layouter.render(cvs, question_items, draw=False)
		question_layouter.render(cvs, question_items, draw=True)
		
		PAGE_LAYOUTER.title = find_title(form_json) + " Answer Sheet"
	else:
		PAGE_LAYOUTER.title = find_title(form_json)
	
	num_pages = PAGE_LAYOUTER.render(cvs, items, draw=False)
	PAGE_LAYOUTER.total_pages = num_pages
	PAGE_LAYOUTER.render(cvs, items, draw=True)
	cvs.save()
	
	form_json['pageCount'] = num_pages
	
	print form_json
	return form_json
