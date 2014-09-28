import webapp2
from form import Form
import json
import render_form
import login

class PrintForm(webapp2.RequestHandler):
	def get(self, secret):
		form = Form.all().filter("secret =", secret).get()
		if not form:
			self.error(404)
			return
		form_json = json.loads(form.json)
		self.response.headers['Content-Type'] = 'application/pdf'
		render_form.render(form_json, self.response.out)
