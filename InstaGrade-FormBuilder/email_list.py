import webapp2
from google.appengine.ext import db
from util import templ8
from send_mail import send_mail

class EmailListEntry(db.Model):
	email = db.StringProperty()
	added = db.DateTimeProperty(auto_now_add=True)

class Add(webapp2.RequestHandler):
	def get(self):
		self.response.write(templ8('signup_for_beta.html'))

	def post(self):
		email = self.request.get('email')
		entry = EmailListEntry(email = email)
		entry.put()
		send_mail("team@instagradeapp.com", "{0} wants to be a beta tester".format(email), "<p>{0} wants to be a beta tester</p>".format(email))
		self.redirect('/add_to_email_list#thanks')

