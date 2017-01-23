import serial
import math
import datetime
import time
import numpy
import os
from SuppFunctions import *
datafile = 'analogdata.csv'
fromaddr = 'canaryaviary502@gmail.com'
toaddrs = 'yardenc@bu.edu'
ser = serial.Serial('/dev/cu.usbmodem1421',9600)

if (os.path.exists(datafile)):
    date4mail = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
    subj = 'Sensors monitoring report for {}'.format(date4mail)
    msg_text = "Canary setup 7th floor"
    EmailData(toaddrs,subj,msg_text)
fp = open(datafile,'w')
date4header = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
fp.write('Analog inputs logger for Canary 7th floor setup. Starting: ' + date4header + '\n')
fp.close()
daynum = int(datetime.datetime.now().strftime( "%d"))
while True:
    tempnum = int(datetime.datetime.now().strftime( "%d"))
    if (tempnum != daynum):
        daynum = tempnum
        date4mail = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
        subj = 'Sensors monitoring report for {}'.format(date4mail)
        msg_text = "Canary setup 7th floor"
        EmailData(toaddrs,subj,msg_text)
        fp = open(datafile,'w')
        date4header = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
        fp.write('Analog inputs logger for Canary 7th floor setup. Starting: ' + date4header + '\n')
        fp.close()
    time.sleep(60)
    fp = open(datafile,'a')
    date4csv = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
    fp.write(date4csv + ': ' + ser.readline().strip('\0')[15:-3] + '\n')
    fp.close()
