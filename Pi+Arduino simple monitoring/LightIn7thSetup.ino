int SwitchPin = 13;                 // Switch connected to digital pin 13
int incomingByte = 0;
int analogPin = 0;     // Photocell connected to analog pin 2
                       // outside leads to ground and +5V
int val = 0;           // variable to store the value read

void setup()
{
  pinMode(SwitchPin, OUTPUT);      // sets the digital pin as output
  double Latitude = 42.3601;       // Degrees North
  Serial.begin(9600);
}

void loop()
{
  if (Serial.available() > 0) {
                // read the incoming byte:
                incomingByte = Serial.read();
                // say what you got:
                //Serial.print("I received: ");
                //Serial.println(incomingByte, DEC);
                if (incomingByte > 100) {
                  digitalWrite(SwitchPin, HIGH);   // sets the LED on
                  delay(100);                  // waits for a second
                }
                else {
                  digitalWrite(SwitchPin, LOW);    // sets the LED off
                  delay(100);                  // waits for a second
                }
        }
        delay(100);
        val = analogRead(analogPin);    // read the input pin
        Serial.println(val);             // debug value


}
