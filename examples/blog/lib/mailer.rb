require 'rubygems'
require 'net/smtp'
require 'mailfactory'

#Connect to SMTP Server
smtp = Net::SMTP.new('mail.host.com', 25)
smtp.start('mydomain.com')

#Construct Mail Message
mail = MailFactory.new()
mail.to = 'foo@monkey.com'
mail.from = 'jason@dzone.com'
mail.subject = 'An email from Ruby'
mail.add_attachment('/path/to/file')
mail.html = "<h1>Hello From Ruby!</h1><p>Mailfactory is nice</p>"

#Construct SMTP Message
smtp.send_message mail.construct, 'foo@monkey.com', 'jason@dzone.com'

#Send this (and all other) message
smtp.finish()