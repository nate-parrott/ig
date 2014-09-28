from google.appengine.ext import db
from form import Form
from util import templ8
import util
import webapp2
import login
from quiz_instance import QuizInstance

class FormPage(webapp2.RequestHandler):
	def get(self, secret):
		query = Form.all().filter("secret =", secret)
		user = login.current_user(self)
		if user:
			query = query.ancestor(user)
		form = query.get()
		if form:
			if not form.viewed_results_since_last_email_sent:
				form.viewed_results_since_last_email_sent = True
				form.put()
			instances = QuizInstance.all().ancestor(form.parent()).filter("quiz_index =", form.index).order('-date').run()
			self.response.write(templ8("form_page.html", {"form": form, "secret": secret, "just_created": self.request.get('created', "") != "", "instances": instances}))

