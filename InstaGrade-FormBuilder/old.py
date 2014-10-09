import webapp2
import json

class iphone_3_3(webapp2.RequestHandler):
	def get(self):
		data = {
			'interstitials': [ ]
		}
		self.response.write(json.dumps(data))
