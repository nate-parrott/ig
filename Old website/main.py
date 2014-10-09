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
from google.appengine.ext.webapp import util
from google.appengine.ext import db
from google.appengine.ext.webapp import template
import os
from google.appengine.ext.webapp.mail_handlers import InboundMailHandler
from google.appengine.api import mail

def render(template_name, data=None, wrap_page=True):
  if data==None: data = {}
  data['parent'] = 'wrap.html' if wrap_page else 'nowrap.html'
  path = os.path.join(os.path.dirname(__file__), template_name)
  return template.render(path, data)

class SupportTicket(db.Model):
  body = db.TextProperty()
  email = db.StringProperty()
  product = db.StringProperty()
  added = db.DateTimeProperty(auto_now=True)
  info = db.StringProperty()

import logging
class SubmitSupportTicketHandler(webapp2.RequestHandler):
    def post(self):
      ticket = SupportTicket()
      ticket.body = self.request.get('body')
      ticket.email = self.request.get('email')
      ticket.product = self.request.get('product')
      ticket.info = self.request.get('info')
      ticket.put()
      self.redirect('/confirmSupportTicket')

itunes_url = 'http://itunes.apple.com/app/id581695531'

class DownloadHandler(webapp2.RequestHandler):
  def get(self):
    #self.redirect('/offline.html')
    self.redirect(itunes_url)

class PageHandler(webapp2.RequestHandler):
  def get(self, page_name, ext):
    if ext==None: ext = '.html'
    self.response.out.write(render(page_name+ext))

class IndexHandler(webapp2.RequestHandler):
  def get(self):
    if self.request.host.endswith('.appspot.com'):
      self.redirect('http://instagradeapp.com', permanent=True)
      return
    self.response.out.write(render('index.html'))

class ClientJsonHandler(webapp2.RequestHandler):
  def get(self, name):
    self.response.out.write(open(name+'.json').read())

class AnswerSheetHandler(webapp2.RequestHandler):
    def get(self, name):
        # {% include "answer-sheet.html" with name="24-question answer sheet" url="/static/answer-sheets/24.pdf" filename="InstaGrade 24-question answer sheet.pdf" %}
        sheets = {
            "24": {"name": "24-question answer sheet", "url": "/static/answer-sheets/24.pdf", "filename": "InstaGrade_24-question_answer_sheet.pdf"},
            "56": {"name": "56-question answer sheet", "url": "/static/answer-sheets/56.pdf", "filename": "InstaGrade_56-question_answer_sheet.pdf"},
    }
        if name in sheets:
            self.response.out.write(render("answer-sheet.html", sheets[name]))

app = webapp2.WSGIApplication([
('/submitSupportTicket', SubmitSupportTicketHandler),
('/download', DownloadHandler),
('/', IndexHandler),
('/(24|56)', AnswerSheetHandler),
('/([a-zA-Z0-9\/]+)(\.html)?', PageHandler),
('/client/(.+)', ClientJsonHandler)
], debug=True)
