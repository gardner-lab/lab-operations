This is a very simple setup that allows monitoring sensors using a raspberry PI and an Arduino.
The Arduino reads the sensors and transmitts via serial connection and the PI reads the data, logs to disk, and hosts a web server that displys the data.
This folder contains the files for a very simple example:
1. Arduino code
2. The amcharts JavaScript library for the web page graphics (free version)
3. data file (data.csv)
4. Python's serial port library (already installed in pi's)