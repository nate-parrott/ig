from google.appengine.ext import db
from form import Form
from util import templ8
import util
import webapp2

class Created(webapp2.RequestHandler):
	def get(self, id):
		form = Form.get_by_id(int(id))
		self.response.write(templ8("created.html", {"form": form, "id": id}))

