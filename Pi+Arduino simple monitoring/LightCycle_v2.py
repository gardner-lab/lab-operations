import serial
import math
# from datetime import date
import datetime
import astral
import time
import numpy
# This version sends emails
import smtplib
fromaddr = 'canaryaviary502@gmail.com'
toaddrs = 'yardenc@bu.edu'
username = 'canaryaviary502@gmail.com'
password = 'Canaries502'




flagstart = 0
ser = serial.Serial('/dev/ttyACM0',9600)
ser.close()
ser.open()
time.sleep(1)
ser.write('a')
a = astral.Astral()
city = a['Boston']
sun = city.sun(date=datetime.date.today(), local=True)
t = datetime.datetime.now().time()
print t
if (sun['sunrise'].time()<t) & (sun['sunset'].time()>t):
	ser.write('f')
	CurrentSwitch = 1
	print 'on'
else:
	ser.write('a')
	CurrentSwitch = 0
	print 'off'
# report the initial state of the system
date4mail = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
if (CurrentSwitch == 1):
	subj = 'Light cycle monitoring initialized ON at {}'.format(date4mail)
	msg_text = subj
	msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( fromaddr, toaddrs, subj, date4mail, msg_text )
else:
	subj = 'Light cycle monitoring initialized OFF at {}'.format(date4mail)
	msg_text = subj
	msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( fromaddr, toaddrs, subj, date4mail, msg_text )
server = smtplib.SMTP('smtp.gmail.com:587')
server.ehlo()
server.starttls()
server.login(username,password)
server.sendmail(fromaddr, toaddrs, msg)
server.quit()
# end report

tmp = []
time.sleep(1)
ser.write('f')
timesec = time.localtime().tm_min
timesec1 = time.localtime().tm_min
while True:
	time.sleep(0.1)
	if (time.localtime().tm_min != timesec1):
		timesec1 = time.localtime().tm_min
		sun = city.sun(date=datetime.date.today(), local=True)
		t = datetime.datetime.now().time()
		if (sun['sunrise'].time()<t) & (sun['sunset'].time()>t):
			ser.write('a')
			if CurrentSwitch == 0:
				print str(datetime.datetime.now().date()) + ' light ON at: ' + str(datetime.datetime.now().time())
				CurrentSwitch = 1
				# report the light switch to ON
				date4mail = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
				subj = 'Light switched to ON at {}'.format(date4mail)
				msg_text = subj
				msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( fromaddr, toaddrs, subj, date4mail, msg_text )
				server = smtplib.SMTP('smtp.gmail.com:587')
				server.ehlo()
				server.starttls()
				server.login(username,password)
				server.sendmail(fromaddr, toaddrs, msg)
				server.quit()
				# end report
		else:
			ser.write('f')
			if CurrentSwitch == 1:
				print str(datetime.datetime.now().date()) + ' light OFF at: ' + str(datetime.datetime.now().time())
				CurrentSwitch = 0
				# report the light switch to OFF
				date4mail = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
				subj = 'Light switched to OFF at {}'.format(date4mail)
				msg_text = subj
				msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( fromaddr, toaddrs, subj, date4mail, msg_text )
				server = smtplib.SMTP('smtp.gmail.com:587')
				server.ehlo()
				server.starttls()
				server.login(username,password)
				server.sendmail(fromaddr, toaddrs, msg)
				server.quit()
				# end report
	if ((time.localtime().tm_min-timesec) % 60 < 10):
		time.sleep(0.1)
		ser.flushInput()
		#print '*'
		ainp = ser.readline().strip('\0')
		if len(ainp) <= 5:
			try:
				tmp.append(int(ainp))
				#print int(ainp)

			except ValueError:
				pass
	else:
			s = time.strftime("%m/%d/%y %H:%M",time.localtime()) + ',1,' + str(numpy.max(tmp))
			print s
			fl = open('data.csv','a')
			if flagstart == 1:
				fl.write(s)
			else:
				fl.write('\n' + s)
				flagstart = 0
			fl.close()
			tmp=[]
			timesec = time.localtime().tm_min
