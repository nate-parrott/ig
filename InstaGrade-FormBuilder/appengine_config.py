import datetime
from gaesessions import SessionMiddleware
def webapp_add_wsgi_middleware(app):
	app = SessionMiddleware(app, cookie_key="eufhgnr 373t478fexfeif37uofhgperuighr3iufberifb9rg43", lifetime=datetime.timedelta(days=30))
	return app
