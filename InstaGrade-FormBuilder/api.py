import webapp2
import login
from form import Form
import json
import msgpack

class FormDetail(webapp2.RequestHandler):
	def get(self, index):
		if login.current_user(self):
			item = Form.all().ancestor(login.current_user(self)).filter('index =', int(index)).get()
			if item:
				form_json = json.loads(item.json)
				self.response.write(json.dumps({"json": form_json, "title": item.title}))
			else:
				print "No item"
		else:
			print "No user for token {0}".format(self.request.get('token'))

class UploadQuizInstances(webapp2.RequestHandler):
	def post(self):
		user = login.current_user(self)
		data = msgpack.unpackb(self.request.body)
		# TODO: save
		for instance in data['quizInstances']:
			print 'received quiz with score {0}/{1}'.format(instance['earnedScore'], instance['maximumScore'])
