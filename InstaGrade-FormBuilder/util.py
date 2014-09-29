import jinja2, os
from google.appengine.api import users

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

def templ8(filename, vals={}):
	vals = dict(vals.items())
	if users.get_current_user():
		vals['global_logout_url'] = users.create_logout_url('/')
		vals['global_email'] = users.get_current_user().email()
	return JINJA_ENVIRONMENT.get_template(filename).render(vals)

HOST = "instagradeformbuilder.appspot.com"
