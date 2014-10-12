from google.appengine.ext import db
from form import Form
from util import templ8
import util
import webapp2
import login
import json
from quiz_instance import QuizInstance

class FormPage(webapp2.RequestHandler):
	def get(self, secret):
		form = Form.WithSecret(secret, self)
		if form:
			if not form.viewed_results_since_last_email_sent:
				form.viewed_results_since_last_email_sent = True
				form.put()
			instances = list(QuizInstance.all().ancestor(form.parent()).filter("quiz_index =", form.index).order('-date').run())
			average_points = None
			if len(instances):
				average_points = str(sum([i.points for i in instances]) * 1.0 / len(instances))
			instances_serialized = map(lambda x: x.serialize(), instances)
			self.response.write(templ8("form_page.html", {"form": form, "secret": secret, "just_created": self.request.get('created', "") != "", "instances_json": json.dumps(instances_serialized), "average_points": average_points}))

class FormInstanceDetailPage(webapp2.RequestHandler):
	def get(self):
		pass
