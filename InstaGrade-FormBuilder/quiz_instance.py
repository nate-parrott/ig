from google.appengine.ext import db
from google.appengine.ext import blobstore

class QuizInstance(db.Model):
	points = db.FloatProperty()
	max_points = db.FloatProperty()
	name_image = blobstore.BlobReferenceProperty()
	quiz_index = db.IntegerProperty()
	date = db.DateTimeProperty()
