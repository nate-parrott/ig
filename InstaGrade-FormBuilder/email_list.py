import webapp2
from google.appengine.ext import db

class EmailListEntry(db.Model):
	email = db.StringProperty()
	added = db.DateTimeProperty(auto_now_add=True)

class Add(webapp2.RequestHandler):
	def post(self):
		email = self.request.get('email')
		entry = EmailListEntry(email = email)
		entry.put()
		self.redirect('/#subscribed')
