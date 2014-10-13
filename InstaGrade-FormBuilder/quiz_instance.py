from google.appengine.ext import db
import json

class QuizInstance(db.Model):
	points = db.FloatProperty()
	max_points = db.FloatProperty()
	name_image_url = db.StringProperty()
	quiz_index = db.IntegerProperty()
	json = db.TextProperty()
	date = db.DateTimeProperty()
	uuid = db.StringProperty()

	def serialize(self):
		return {
			"id": self.uuid,
			"points": self.points,
			"maxPoints": self.max_points,
			"date": str(self.date),
			"items": json.loads(self.json),
			"nameImageUrl": self.name_image_url
		}

	def count_blanks(self):
		blanks = 0
		for item in json.loads(self.json):
			if 'visibleIndex' in item and item['response'] == None:
				blanks += 1
		return blanks
