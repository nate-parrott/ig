import webapp2
from util import templ8

class HowItWorks(webapp2.RequestHandler):
	def get(self):
		self.response.write(templ8("how-it-works.html"))
