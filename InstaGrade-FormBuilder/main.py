#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import util
import json
import form
import form_page
import print_form
from google.appengine.api import users
import login
import api
import email_list
import info

class MainHandler(webapp2.RequestHandler):
    def get(self):
    	form_json = None
    	existing_form_secret = self.request.get('f', None)
    	if existing_form_secret:
    		form_json = form.Form.WithSecret(existing_form_secret).json

        self.response.write(util.templ8('form.html', 
				{"user": login.current_user(self), "logout_url": users.create_logout_url('/'), "form_json": form_json}))

class DownloadScanner(webapp2.RequestHandler):
	def get(self):
		args = {"token": self.request.get('token', None)}
		self.response.write(util.templ8("download_scanner.html", args))

app = webapp2.WSGIApplication([
    ('/', MainHandler),
		('/submit', form.Submit),
		('/get_token', login.GetToken),
		('/download_scanner', DownloadScanner),
		('/auth_and_save', form.AuthAndSave),
		('/(.+)/print', print_form.PrintForm),
		('/(.+)/print/(.+)', print_form.PrintForm),
		('/(.+)/details', api.FormDetail),
		('/upload_quiz_instances', api.UploadQuizInstances),
		('/add_to_email_list', email_list.Add),
		('/how-it-works', info.HowItWorks),
		('/user_data', api.UserData),
		('/(.+)', form_page.FormPage)
], debug=True)
