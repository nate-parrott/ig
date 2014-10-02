from google.appengine.ext import db
import webapp2
import json
import render_form
import StringIO
from google.appengine.api import users
from send_mail import send_mail
import util
from util import templ8
import render_form
import login
import os
import uuid
import base64

class Form(db.Model):
	title = db.StringProperty()
	json = db.TextProperty()
	viewed_results_since_last_email_sent = db.BooleanProperty(default=True)
	created = db.DateTimeProperty(auto_now_add=True)
	index = db.IntegerProperty()
	secret = db.StringProperty()
	
	def new_model_attached_to_user(self, user):
		models_for_user = Form.all().ancestor(user)
		max_index = render_form.num_available_barcode_indices()
		self.index = (models_for_user.count() + hash(user.email)) % max_index # mandate unique ids per email, try to avoid global id collision as much as possible
		form_json = json.loads(self.json)
		form_json['index'] = self.index
		self.json = json.dumps(form_json)
		all_keys = 'title json viewed_results_since_last_email_sent created index secret'.split(' ')
		key_dict = dict([(key, getattr(self, key)) for key in all_keys])
		new_model = Form(parent=user, **key_dict)
		new_model.secret = base64.urlsafe_b64encode(os.urandom(64) + uuid.uuid4().bytes)
		new_model.put()
		
		"""try:
			self.delete()
		except db.NotSavedError:
			pass"""
		
		# send the email:
		recipient = new_model.parent().email
		subject = "Your quiz, \"%s\", is ready to scan" % (new_model.title)
		html = templ8("created_email.html", {"form": new_model, "id": new_model.key().id(), "HOST": util.HOST})
		send_mail(recipient, subject, html)
		
		return new_model

	@classmethod
	def WithSecret(cls, secret, handler=None):
		query = Form.all().filter("secret =", secret)
		user = login.current_user(handler)
		if user:
			query = query.ancestor(user)
		form = query.get()
		return form
	
class Submit(webapp2.RequestHandler):
	def post(self):
		form_json = json.loads(self.request.get('form_json'))
		
		title = ""
		for item in form_json.get('items', []):
			if item['type'] == 'title':
				title = item['text']
				break
		
		form_json['index'] = 0 # will actually be populated in form.new_model_attached_to_user()
		null_io = StringIO.StringIO()
		render_form.render(form_json, null_io)
		
		model = Form(title=title, json=json.dumps(form_json))
		if login.current_user(self):
			model = model.new_model_attached_to_user(login.current_user(self))
			self.redirect('/{0}?created=1'.format(model.secret))
		else:
			model.put()
			self.redirect(users.create_login_url('/auth_and_save?id={0}'.format(model.key().id())))

class AuthAndSave(webapp2.RequestHandler):
	def get(self):
		form = Form.get_by_id(int(self.request.get('id')))
		form = form.new_model_attached_to_user(login.current_user(self))
		self.redirect('/{0}?created=1'.format(form.secret))
