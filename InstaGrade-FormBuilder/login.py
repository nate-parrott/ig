import webapp2
import util
import urllib
from google.appengine.ext import db
import base64
import os
import calendar
from gaesessions import get_current_session
import send_mail
import hashlib

def make_url(endpoint, **kwargs):
	return endpoint + '?' + urllib.urlencode(kwargs)

def create_login_url(callback='/'):
	return make_url('/login', callback=callback)

class LoginDialog(webapp2.RequestHandler):
	def get(self):
		callback = self.request.get('callback')
		self.response.write(util.templ8('login_dialog.html', {"callback": callback, "login_error": self.request.get('login_error'), "signup_error": self.request.get('signup_error'), "message": self.request.get('message')}))
	def post(self):
		action = self.request.get('action')
		callback = self.request.get('callback')
		email = self.request.get('email', '')
		if action == 'login':
			if len(email) == 0:
				return self.redirect(make_url('/login', callback=callback))
			user = User.get_by_key_name(self.request.get('email', ''))
			if user and user.pwd_hash == hash_password(self.request.get('password', '')):
				get_current_session()['email'] = email
				return self.redirect(callback)
			else:
				error = "No user with that email address was found." if user==None else "Incorrect password."
				return self.redirect(make_url('/login', callback=callback, login_error=error))
		elif action == 'sign_up':
			existing = User.get_by_key_name(email)
			if len(self.request.get("email", "")) == 0 or len(self.request.get("password", "")) == 0:
				return self.redirect(make_url('/login', callback=callback, signup_error="Please enter a password and email address."))
			if existing:
				return self.redirect(make_url('/login', callback=callback, signup_error="A user with that email already exists."))
			#if self.request.get("password") != self.request.get("password2"):
			#	return self.redirect(make_url('/login', callback=callback, signup_error="Passwords don't match."))
			user = User.get_or_insert(email, name=email)
			user.email = email
			user.pwd_hash = hash_password(self.request.get('password'))
			user.put()
			get_current_session()['email'] = email
			return self.redirect(callback)
		elif action == 'password_reset':
			user = User.get_by_key_name(email)
			if user:
				user.password_reset_token = base64.urlsafe_b64encode(os.urandom(64))
				user.put()
				send_mail.send_mail(email, "Reset your InstaGrade password", util.templ8("password_reset_email.html", {"token": user.password_reset_token}))
			return self.redirect(make_url('/login', callback=callback, message="We sent a password-reset email."))

class ChangePassword(webapp2.RequestHandler):
	def get(self):
		token = self.request.get('reset')
		users = list(User.all().filter('password_reset_token =', token).run())
		if len(users):
			user = users[-1]
			get_current_session()['email'] = user.email
			self.response.write(util.templ8('reset_password.html', {'token': token}))
		else:
			return self.redirect('/')
	def post(self):
		print "CURRENT_USER", current_user()
		u = current_user()
		if u:
			u.pwd_hash = hash_password(self.request.get("password"))
			u.password_reset_token = None
			u.put()
		return self.redirect('/')

def logout_url(callback):
	return make_url('/logout', callback=callback)

class Logout(webapp2.RequestHandler):
	def get(self):
		get_current_session().clear()
		return self.redirect(self.request.get('callback'))

def hash_password(pwd):
	h = hashlib.sha256()
	SALT = 'rgieh89gh3489gy379gx8340fh3'
	h.update(SALT)
	h.update(pwd)
	return h.hexdigest()

class User(db.Model):
	email = db.StringProperty()
	pwd_hash = db.StringProperty()
	subscription_end_date = db.DateTimeProperty()
	scans_left = db.IntegerProperty(default=100)
	password_reset_token = db.StringProperty()

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
	session = get_current_session()
	if handler != None and handler.request.get("token", None) != None:
		uid, secret = handler.request.get("token").split("..", 1)
		token = LoginToken.all().ancestor(User(key_name=uid)).filter("secret =", secret).get()
		if token != None:
			username = uid
	elif session.get('email'):
		username = session.get('email')
	if username:
		return User.get_or_insert(username, email=username)
	else:
		return None

class GetToken(webapp2.RequestHandler):
	def get(self):
		user = current_user(self)
		if user:
			# create and vend token:
			token = create_token_for_current_user()
			query_dict = {
				"token": token,
			}
			print "URL", 'instagrade-login-token://x?' + urllib.urlencode(query_dict)
			self.redirect('instagrade-login-token://x?' + urllib.urlencode(query_dict))
		else:
			self.redirect(create_login_url('/get_token'))

