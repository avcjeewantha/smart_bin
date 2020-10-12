#include <SoftwareSerial.h>
SoftwareSerial SIM900(3, 2); //  TX,RX

String latitude;
String longitude;
String old_status;
String new_status;
const int trigPin = 8;
const int echoPin = 7;
long duration;
int distance = 0;
int maxDistance=15;


void ShowSerialData()
{
 while(SIM900.available()!=0)
   Serial.write(SIM900.read());
}

void setup()
{
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  Serial.begin(9600);
  SIM900.begin(9600);
  initConnection();
}
void loop() {
  delay(10000);
   getDistance();     // get distance from sensor data
   if (distance < maxDistance){
      new_status = "full";
    }
   else {
      new_status = "empty";
    }

   if (new_status != old_status) {
      old_status = new_status;
      sendData();
    }
    
//  abortConnection();
}

void initConnection(){
  Serial.println("HTTP post method :");
  SIM900.println("AT+GMR"); /* Check Communication */
  delay(2000);
  SIM900.println("AT+CSQ"); /* Check Communication */
  delay(2000);
  SIM900.println("AT+CGATT =1"); // to attach GPRS./
  delay(2000);
  ShowSerialData();  /* Print response on the serial monitor */
  delay(2000);
  /* Configure bearer profile 1 */
  SIM900.println("AT+SAPBR=3,1,\"CONTYPE\",\"GPRS\"");  /* Connection type GPRS */
  delay(2000);
  ShowSerialData();
  delay(2000);
 // SIM900.println("AT+SAPBR=3,1,\"APN\",\"dialogbb\"");  /* APN of the provider */
  SIM900.println("AT+SAPBR=3,1,\"APN\",\"mobitel\"");
  delay(2000);
  ShowSerialData();
  delay(2000);
  SIM900.println("AT+SAPBR=1,1"); /* Open GPRS context */
  delay(2000);
  ShowSerialData();
  delay(5000);
  SIM900.println("AT+SAPBR=2,1"); /* Query the GPRS context */
  delay(2000);
  ShowSerialData();
  delay(5000);
  SIM900.println("AT+HTTPINIT");  /* Initialize HTTP service */
  delay(2000); 
  ShowSerialData();
}

void sendData(){
//  SIM900.println("AT+CDNSCFG=\"169.254.169.253\"");  /* Set parameters for HTTP session */
//  delay(5000);
//  SIM900.println("AT+HTTPPARA=\"PROPORT\",\"80\"");  /* Set parameters for HTTP session */
//  delay(5000);
  SIM900.println("AT+HTTPPARA=\"CID\",1");  /* Set parameters for HTTP session */
  delay(5000);
  ShowSerialData();
  SIM900.println("AT+HTTPPARA=\"URL\",\"http://18.188.53.186/smartbin/update\"");  /* Set parameters for HTTP session */
  delay(5000);
  ShowSerialData();
  delay(5000);
  SIM900.println("AT+HTTPPARA=\"CONTENT\",\"application/json\"");
  delay(5000);
  ShowSerialData();
  SIM900.println("AT+HTTPDATA=500,10000"); /* POST data of size 33 Bytes with maximum latency time of 10seconds for inputting the data*/ 
  delay(8000);
  ShowSerialData();
  /* Data to be sent */
 
  SIM900.print("{\"id\":\"bin2\",\"status\":\"");
  SIM900.print(new_status);
  SIM900.print("\"}");
  delay(5000);
  ShowSerialData();
  SIM900.println("AT+HTTPACTION=1");  /* Start POST session */
  delay(5000);
  ShowSerialData();
}

void abortConnection(){
  delay(2000);
  SIM900.println("AT+HTTPTERM");  /* Terminate HTTP service */
  delay(2000);
  ShowSerialData();
  delay(5000);
  SIM900.println("AT+SAPBR=0,1"); /* Close GPRS context */
  delay(2000);
  ShowSerialData();
  delay(2000);
}

void getDistance(){
  
  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  // Calculating the distance
  distance= duration*0.034/2;
  // Prints the distance on the Serial Monitor
  Serial.print("Distance: ");
  Serial.println(distance);
//  delay(22000);
}
