from google.appengine.ext import db
import webapp2
import json
import render_form
import StringIO
from google.appengine.api import users
from google.appengine.api import mail
from html2text import html2text
import util
from util import templ8
import render_form
import login

class Form(db.Model):
	title = db.StringProperty()
	json = db.TextProperty()
	viewed_results_since_last_email_sent = db.BooleanProperty(default=False)
	created = db.DateTimeProperty(auto_now_add=True)
	index = db.IntegerProperty()
	
	def new_model_attached_to_user(self, user):
		models_for_user = Form.all().ancestor(user)
		max_index = render_form.num_available_barcode_indices()
		self.index = (models_for_user.count() + hash(user.email)) % max_index # mandate unique ids per email, try to avoid global id collision as much as possible
		form_json = json.loads(self.json)
		form_json['index'] = self.index
		self.json = json.dumps(form_json)
		all_keys = 'title json viewed_results_since_last_email_sent created index'.split(' ')
		key_dict = dict([(key, getattr(self, key)) for key in all_keys])
		new_model = Form(parent=user, **key_dict)
		new_model.put()
		
		try:
			self.delete()
		except db.NotSavedError:
			pass
		
		# send the email:
		sender = "InstaGrade Robot <robot@instagradeapp.com>"
		recipient = new_model.parent().email
		subject = "Your quiz, \"%s\", is ready to scan" % (new_model.title)
		html = templ8("created_email.html", {"form": new_model, "id": new_model.key().id(), "HOST": util.HOST})
		body = html2text(html)
		print "BODY: ", body
		mail.send_mail(sender, recipient, subject, body, html=html)
		
		return new_model
	
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
			index = model.new_model_attached_to_user(login.current_user(self)).index
			self.redirect('/{0}/created'.format(model.index))
		else:
			model.put()
			self.redirect(users.create_login_url('/auth_and_save?id={0}'.format(model.key().id())))

class AuthAndSave(webapp2.RequestHandler):
	def get(self):
		form = Form.get_by_id(int(self.request.get('id')))
		form.new_model_attached_to_user(login.current_user(self))
		self.redirect('/{0}/created'.format(form.index))

class GetFormJSON(webapp2.RequestHandler):
	def get(self, token):
		form = Form.FromToken(token)
		if not form:
			self.error(404)
			return
		self.response.headers['Content-Type'] = 'application/json'
		self.response.write(form.json)
