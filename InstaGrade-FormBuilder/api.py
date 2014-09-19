import webapp2
import login
from form import Form
import json

class FormDetail(webapp2.RequestHandler):
	def get(self, index):
		if login.current_user(self):
			item = Form.all().filter('user =', login.current_user(self)).filter('index =', int(index)).get()
			if item:
				form_json = json.loads(item.json)
				self.response.write(json.dumps({"json": form_json, "title": item.title}))
			else:
				print "No item"
		else:
			print "No user for token {0}".format(self.request.get('token'))
