import webapp2
import login
from form import Form
import json
import msgpack
from google.appengine.ext import db
import quiz_instance
import datetime
import file_storage
from util import templ8
from send_mail import send_mail

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
		
		to_save = []
		
		added_quizzes_to_indices = set()
		for instance in data['quizInstances']:
			rec = quiz_instance.QuizInstance(
				parent = user, 
				points = instance['earnedScore'], 
				max_points = instance['maximumScore'], 
				json=json.dumps(instance['responseItems']), 
				quiz_index = instance['quizIndex'], 
				date = datetime.datetime.fromtimestamp(instance['timestamp']), 
				name_image_url = file_storage.upload_file_and_get_url(instance['nameImage'], mimetype='image/jpeg'))
			to_save.append(rec)
			added_quizzes_to_indices.add(rec.quiz_index)
		
		# send emails:
		for index in added_quizzes_to_indices:
			quiz = Form.all().ancestor(user).filter('index =', index).get()
			if quiz != None and quiz.viewed_results_since_last_email_sent:
				quiz.viewed_results_since_last_email_sent = False
				to_save.append(quiz)
				
				subject = "We've graded some copies of your quiz, '{0}'".format(quiz.title)
				html = templ8("graded_email.html", {"quiz": quiz})
				send_mail(quiz.parent().email, subject, html)
		
		db.put(to_save)
		
		self.response.write("okay")
		print 'received quiz with score {0}/{1}'.format(instance['earnedScore'], instance['maximumScore'])
