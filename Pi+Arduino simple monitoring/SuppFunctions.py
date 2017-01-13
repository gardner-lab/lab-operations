import os
import smtplib
import datetime

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
    username = 'canaryaviary502@gmail.com'
    fromaddr = username
    password = 'Canaries502'
    server = smtplib.SMTP('smtp.gmail.com:587')
    server.ehlo()
    server.starttls()
    server.login(username,password)
    server.sendmail(fromaddr, toaddrs, msg)
    server.quit()
