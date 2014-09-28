from google.appengine.ext import db

class QuizInstance(db.Model):
	points = db.FloatProperty()
	max_points = db.FloatProperty()
	name_image_url = db.StringProperty()
	quiz_index = db.IntegerProperty()
	json = db.TextProperty()
	date = db.DateTimeProperty()
