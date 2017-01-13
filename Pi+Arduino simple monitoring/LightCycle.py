import serial
import math
# from datetime import date
import datetime
import astral
import time
import numpy
flagstart = 1
ser = serial.Serial('/dev/cu.usbmodem1471',9600)
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
			ser.write('f')
			if CurrentSwitch == 0:
				print str(datetime.datetime.now().date()) + ' light ON at: ' + str(datetime.datetime.now().time())
				CurrentSwitch = 1
		else:
			ser.write('a')
			if CurrentSwitch == 1:
				print str(datetime.datetime.now().date()) + ' light OFF at: ' + str(datetime.datetime.now().time())
				CurrentSwitch = 0
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
