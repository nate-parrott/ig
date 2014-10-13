import xlsxwriter
from quiz_instance import QuizInstance
from form import Form
import webapp2
from print_form import escape_for_filename
import StringIO
from io import BytesIO
from google.appengine.api import urlfetch
import json

PERCENTAGE_ROUNDING = 0.1

class ExcelExportHandler(webapp2.RequestHandler):
	def get(self, secret):
		form = Form.WithSecret(secret, self)
		if form:
			self.response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
			self.response.headers['Content-Transfer-Encoding'] = 'Binary'
			self.response.headers['Content-Disposition'] = 'inline; filename={0}'.format(escape_for_filename(form.title, default="Quiz Results"))
			self.response.write(create_xlsx(form, self.response))

def create_xlsx(form, output_file):
	io = StringIO.StringIO()
	workbook = xlsxwriter.Workbook(io, {'in_memory': True})
	
	instances = list(QuizInstance.all().ancestor(form.parent()).filter("quiz_index =", form.index).order('-date').run())

	# add global results sheet:
	worksheet = workbook.add_worksheet('Results') # todo: use quiz name w/ escaping if necessary?
	name_images = get_name_images(instances)
	cols = ['Name', 'Points', 'Grade', '# of answers blank']
	image_size = (23, 33)
	image_scale = 0.65
	worksheet.set_column(0, 0, image_size[0])
	for col, i in zip(cols, xrange(len(cols))):
		worksheet.write(0, i, col)
	for quiz_instance, name_image_data, i in zip(instances, name_images, xrange(len(instances))):
		row = i + 1
		worksheet.set_row(row, image_size[1])
		if name_image_data:
			worksheet.insert_image(row, 0, quiz_instance.name_image_url, {'image_data': BytesIO(name_image_data), 'positioning': 1, 'x_scale': image_scale, 'y_scale': image_scale})
		else:
			worksheet.write(row, 0, "?")
		worksheet.write(row, 1, quiz_instance.points)
		worksheet.write(row, 2, str(round(quiz_instance.points * 100.0 / quiz_instance.max_points / PERCENTAGE_ROUNDING) * PERCENTAGE_ROUNDING) + "%")
		worksheet.write(row, 3, quiz_instance.count_blanks())
		worksheet.set_row(row, image_size[1])

	for instance, name_image, i in zip(instances, name_images, xrange(len(instances))):
		worksheet = workbook.add_worksheet("Student {0}".format(i+1))
		worksheet.set_column(0, 1, image_size[0])

		title_format = workbook.add_format()
		title_format.set_bold()
		title_format.set_font_size(20)

		bold_format = workbook.add_format()
		bold_format.set_bold()

		wrapped_text_format = workbook.add_format()
		wrapped_text_format.set_align('vjustify')
		wrapped_text_format.set_text_wrap()

		worksheet.set_row(0, image_size[1])
		if name_image_data:
			worksheet.insert_image(0, 0, quiz_instance.name_image_url, {'image_data': BytesIO(name_image_data), 'positioning': 1, 'x_scale': image_scale, 'y_scale': image_scale})
		else:
			worksheet.write(0, 0, "?")
		percent = str(round(instance.points * 100.0 / instance.max_points / PERCENTAGE_ROUNDING) * PERCENTAGE_ROUNDING) + "%"
		worksheet.write(0, 1, "{0} ({1}/{2})".format(percent, instance.points, instance.max_points), title_format)

		worksheet.write(1, 0, 'Question', bold_format)
		worksheet.write(1, 1, 'Result', bold_format)
		worksheet.write(1, 1, 'Points', bold_format)
		row = 2
		for item in json.loads(instance.json):
			if 'visibleIndex' in item:
				worksheet.write(row, 0, "{0}. {1}".format(item['visibleIndex'], item.get('description', '')))
				worksheet.write(row, 1, item['gradingDescription'], wrapped_text_format) # DONOTSUBMIT
				worksheet.write(row, 2, "{0}/{1}".format(item['pointsEarned'], item['points'], wrapped_text_format))
				row += 1

	workbook.close()
	output_file.write(io.getvalue())

def get_name_images(quiz_instances):
	rpc = []
	for instance in quiz_instances:
		url = instance.name_image_url
		if url:
			rpc.append(urlfetch.create_rpc())
			urlfetch.make_fetch_call(rpc[-1], url)
		else:
			rpc.append(None)
	results = [(r.get_result() if r else None) for r in rpc]
	successful = [(r if r.status_code == 200 else None) for r in results]
	return [(result.content if result else None) for result in successful]

