from google.appengine.api import mail
from html2text import html2text
import pynliner

def send_mail(recipient, subject, html):
	html = pynliner.fromString(html)
	sender = "InstaGrade Robot <robot@instagradeapp.com>"
	body = html2text(html)
	try:
		mail.send_mail(sender, recipient, subject, body, html=html)
	except Exception as e:
		print "ERROR SENDING MAIL: {0}".format(e)
	print "BODY: ", body.encode('utf-8')
