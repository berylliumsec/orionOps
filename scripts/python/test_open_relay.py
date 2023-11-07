import smtplib
import logging
import argparse

logging.basicConfig(filename='open_relay.log',level=logging.INFO)
parser = argparse.ArgumentParser(description="Configure proxy")
parser.add_argument(
    "--mail_server",
    type=str,
    help="fqdn of the target mail server"
)
parser.add_argument(
    "--recipient",
    type=str,
    help="recipient email"
)
parser.add_argument(
    "--sender",
    type=str,
    help="sender email"
)
args = parser.parse_args()
# Set the server variable to the address of the SMTP server

# Set the port variable to the port of the SMTP server
port = 25

# Create an SMTP object
smtp_obj = smtplib.SMTP(args.mail_server, port)

# Check the connection to the server
try:
    smtp_obj.helo()
    print('The connection to the SMTP server is successful.')
except smtplib.SMTPHeloError:
    print('The connection to the SMTP server has failed.')

# Check if the server is an open relay
try:
    smtp_obj.sendmail(args.sender, args.recipient, '')
    print('The server is an open relay.')
except smtplib.SMTPRecipientsRefused:
    print('The server is not an open relay.')

# Close the SMTP connection
smtp_obj.quit()