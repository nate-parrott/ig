import webapp2
from form import Form
import json
import render_form
import login

def escape_for_filename(text, default="_"):
	abc = 'abcdefghijklmnopqrstuvwxyz'
	chars = abc + abc.upper() + ' _-0123456789'
	name = ''.join([c for c in text if c in chars])
	return name if name != '' else default

class PrintForm(webapp2.RequestHandler):
	def get(self, secret):
		form = Form.all().filter("secret =", secret).get()
		if not form:
			self.error(404)
			return
		form_json = json.loads(form.json)
		self.response.headers['Content-Type'] = 'application/pdf'
		self.response.headers['Content-Disposition'] = 'inline; filename={0}'.format(escape_for_filename(form.title, default="Quiz Answer Sheet"))
		render_form.render(form_json, self.response.out)
