import os
import smtplib
import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def readEmailingList(filename):
    BaseDir = os.getcwd()
    listfile = open(BaseDir + '/' + filename,'r')
    txtline = listfile.readline()
    EmailingList = txtline[:-1]
    while True:
        txtline = listfile.readline()
        if (txtline == ""):
            break
        else:
            EmailingList = EmailingList + ',' + txtline[:-1]
    return EmailingList

def sendEmails(toaddrs,msg):
    username = 'canary.imaging.setup@gmail.com'
    fromaddr = username
    password = 'Canariessetup'
    server = smtplib.SMTP('smtp.gmail.com:587')
    server.ehlo()
    server.starttls()
    server.login(username,password)
    server.sendmail(fromaddr, toaddrs, msg)
    server.quit()

def EmailData(toaddrs,subj,msg_text):
    username = 'canary.imaging.setup@gmail.com'
    fromaddr = username
    password = 'Canariessetup'
    datafile = 'analogdata.csv'
# Create the container (outer) email message.
    fp = open(datafile, 'rb')
    msg = MIMEText(fp.read())
    fp.close()
    msg['Subject'] = subj
# me == the sender's email address
# family = the list of all recipients' email addresses
    msg['From'] = 'canary.imaging.setup@gmail.com'
    msg['To'] = toaddrs





# Send the email via our own SMTP server.
    server = smtplib.SMTP('smtp.gmail.com:587')
    server.ehlo()
    server.starttls()
    server.login(username,password)
    server.sendmail(fromaddr, toaddrs, msg.as_string())
    server.quit()
