import jinja2, os

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

def templ8(filename, vals={}):
	return JINJA_ENVIRONMENT.get_template(filename).render(vals)

HOST = "instagradeformbuilder.appspot.com"
