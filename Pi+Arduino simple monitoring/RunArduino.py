import serial
import io
import time
import numpy

ser = serial.Serial('/dev/ttyACM0',9600)

while True:
	tmp = []
	timesec = time.localtime().tm_min
	time.sleep(0.1)
	while ((time.localtime().tm_min-timesec) % 60 < 10):
		time.sleep(1)
		ser.flushInput()
		a = ser.readline().strip('\0')
		if len(a) <= 5:
			try:
				tmp.append(int(a))
				
			except ValueError:
				pass
		
	
	s = time.strftime("%m/%d/%y %H:%M",time.localtime()) + ',1,' + str(numpy.max(tmp))
	print s
	fl = open('data.csv','a')
	fl.write('\n' + s)
	fl.close()

	


