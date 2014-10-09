import webapp2
from util import templ8
import send_mail

class Support(webapp2.RequestHandler):
	def get(self):
		self.response.write(templ8("support.html"))
	def post(self):
		email = self.request.get('email')
		text = self.request.get('text')
		html = """
		<p><strong>{0} says:</strong></p>
		<p><em>{1}</em></p>
		""".format(email, text)
		send_mail.send_mail("team@instagradeapp.com", "InstaGrade Feedback", html)
		self.response.write(templ8("message.html", {"message": "Thanks! We'll get back to you ASAP."}))
