import webapp2
import util
from google.appengine.api import users
import urllib
from google.appengine.ext import db
import base64
import os

class User(db.Model):
	email = db.StringProperty()

class LoginToken(db.Model):
	secret = db.StringProperty()

def create_token_for_current_user():
	user = current_user()
	if user:
		token = LoginToken(parent=user.key(), secret=base64.urlsafe_b64encode(os.urandom(64)))
		token.put()
		return "{0}..{1}".format(user.key().name(), token.secret)

def current_user(handler=None):
	username = None
	if handler != None and handler.request.get("token", None) != None:
		uid, secret = handler.request.get("token").split("..", 1)
		token = LoginToken.all().ancestor(User(key_name=uid)).filter("secret =", secret).get()
		if token != None:
			username = uid
	elif users.get_current_user():
		username = users.get_current_user().nickname()
	
	if username:
		return User.get_or_insert(username, email=username)
	else:
		return None

class GetToken(webapp2.RequestHandler):
	def get(self):
		if users.get_current_user():
			# create and vend token:
			token = urllib.quote_plus(create_token_for_current_user())
			email = urllib.quote_plus(current_user().email)
			print 'instagrade-login-token://x?token={0}&email={1}'.format(token, email)
			self.redirect('instagrade-login-token://x?token={0}&email={1}'.format(token, email))
		else:
			self.redirect(users.create_login_url('/get_token'))
