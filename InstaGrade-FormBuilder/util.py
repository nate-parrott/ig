import jinja2, os
import login

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

DEBUG = True

def templ8(filename, vals={}):
	vals = dict(vals.items())
	if login.current_user():
		vals['global_logout_url'] = login.logout_url('/')
		vals['global_email'] = login.current_user().email
	vals['debug'] = DEBUG
	return JINJA_ENVIRONMENT.get_template(filename).render(vals)

HOST = "instagradeformbuilder.appspot.com"
