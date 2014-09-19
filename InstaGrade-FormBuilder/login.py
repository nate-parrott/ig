import webapp2
import util
from google.appengine.api import users
import urllib
from google.appengine.ext import db
import base64
import os

class LoginToken(db.Model):
	token = db.StringProperty()
	user = db.UserProperty()

def create_token_for_acting_user():
	if users.get_current_user():
		new_token = LoginToken(user = users.get_current_user(), token = base64.urlsafe_b64encode(os.urandom(64)))
		new_token.put()
		return new_token.token

def current_user(handler):
	if handler.request.get("token", None) != None:
		return LoginToken.all().filter("token =", handler.request.get('token')).get().user
	u = users.get_current_user()
	return u

class GetToken(webapp2.RequestHandler):
	def get(self):
		if users.get_current_user():
			# create and vend token:
			token = urllib.quote_plus(create_token_for_acting_user())
			email = urllib.quote_plus(users.get_current_user().nickname())
			print 'instagrade-login-token://x?token={0}&email={1}'.format(token, email)
			self.redirect('instagrade-login-token://x?token={0}&email={1}'.format(token, email))
		else:
			self.redirect(users.create_login_url('/get_token'))
