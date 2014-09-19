from google.appengine.ext import db
import webapp2
import json
import render_form
import StringIO
from google.appengine.api import memcache
from google.appengine.api import users
from google.appengine.api import mail
from html2text import html2text
import util
from util import templ8
import render_form

class Form(db.Model):
	title = db.StringProperty()
	json = db.TextProperty()
	viewed_results_since_last_email_sent = db.BooleanProperty(default=False)
	created = db.DateTimeProperty(auto_now_add=True)
	index = db.IntegerProperty()
	user = db.UserProperty()
	
	def attach_to_current_user(self):
		self.put() # so we get an id
		self.user = users.get_current_user()
		models_for_user = Form.all()
		models_for_user.filter("user =", self.user)
		max_index = render_form.num_available_barcode_indices()
		self.index = (models_for_user.count() + hash(self.user.nickname())) % max_index # mandate unique ids per email, try to avoid global id collision as much as possible
		form_json = json.loads(self.json)
		form_json['index'] = self.index
		self.json = json.dumps(form_json)
		# send the email:
		sender = "InstaGrade Robot <robot@instagradeapp.com>"
		recipient = self.user.nickname()
		subject = "Your quiz, \"%s\", is ready to scan" % (self.title)
		html = templ8("created_email.html", {"form": self, "id": self.key().id(), "HOST": util.HOST})
		body = html2text(html)
		print "BODY: ", body
		mail.send_mail(sender, recipient, subject, body, html=html)
	
class Submit(webapp2.RequestHandler):
	def post(self):
		form_json = json.loads(self.request.get('form_json'))
		
		title = ""
		for item in form_json.get('items', []):
			if item['type'] == 'title':
				title = item['text']
				break
		
		form_json['index'] = 0 # will actually be populated in form.attach_to_current_user()
		null_io = StringIO.StringIO()
		render_form.render(form_json, null_io)
		
		model = Form(title=title, json=json.dumps(form_json))
		if users.get_current_user():
			model.attach_to_current_user()
			model.put()
			self.redirect('/{0}/created'.format(model.index))
		else:
			model.put()
			self.redirect(users.create_login_url('/auth_and_save?id={0}'.format(model.key().id())))

class AuthAndSave(webapp2.RequestHandler):
	def get(self):
		form = Form.get_by_id(int(self.request.get('id')))
		if form.user == None:
			form.attach_to_current_user()
			form.put()
		self.redirect('/{0}/created'.format(form.index))

class GetFormJSON(webapp2.RequestHandler):
	def get(self, token):
		form = Form.FromToken(token)
		if not form:
			self.error(404)
			return
		self.response.headers['Content-Type'] = 'application/json'
		self.response.write(form.json)
