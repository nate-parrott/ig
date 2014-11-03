import webapp2

class iphone_3_3(webapp2.RequestHandler):
	def get(self):
		self.response.write(open('iphone_3_3.json').read())
