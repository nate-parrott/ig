import webapp2
import util

class HelpHandler(webapp2.RequestHandler):
	def get(self):
		self.response.write(util.templ8("help.html"))
