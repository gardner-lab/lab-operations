This is a very simple setup that allows monitoring sensors using a raspberry PI and an Arduino.
The Arduino reads the sensors and transmitts via serial connection and the PI reads the data, logs to disk, and hosts a web server that displys the data.
This folder contains the files for a very simple example:

1. Arduino code (AviaryMonitor.ino)
2. The amcharts JavaScript library for the web page graphics (free version)
3. data file (data.csv)
4. Python's serial port library (already installed in pi's)
5. The server side html (MonitoringChart.html)
6. The PI's monitoring python code (RunArduino.py)

A folder on the PI should include items 2,3,5,6 
Than, the PI should run a web server (e.g. by opening a terminal and running "python -m SimpleHTTPServer port#" in the folder that contains these files. port# is whatever port number is available, e.g. 8000)
In another terminal window cd to the same folder and run "python RunArduino.py"

In this example, the chart is accessible at http://pi's ip:port#/MonitoringChart.html
