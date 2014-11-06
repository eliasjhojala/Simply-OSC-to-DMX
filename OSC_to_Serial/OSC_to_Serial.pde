//Define some setting variables
int inComingPort = 12000;
int outGoingPort = 12000;
String outGoingIp = "127.0.0.1";
int serialIndex = 0;
int serialBaud = 9600;
//Setting end


import java.net.InetAddress;

InetAddress inet;

String myIP;
void getIp() {
  try {
    inet = InetAddress.getLocalHost();
    myIP = inet.getHostAddress();
  }
  catch (Exception e) {
    e.printStackTrace();
    myIP = "couldnt get IP"; 
  }
}


//Serial------------------------------------
import processing.serial.*;
Serial myPort;  // The serial port
//Serial end--------------------------------
 
//OSCP5------------------------------------
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
//OSCP5 end--------------------------------

//Define variables-------------------------
int numberOfChannels = 24;
int[] channelValue = new int[numberOfChannels+1];
boolean[] channelValueHasChanged = new boolean[channelValue.length];
//Define variables end----------------------

void setup() {
  size(displayWidth,displayHeight);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,inComingPort); //Incoming messages
  myRemoteLocation = new NetAddress(outGoingIp,outGoingPort); //Outgoing messages
  
  String portName = Serial.list()[serialIndex];
  myPort = new Serial(this, portName, serialBaud);
   
}


void draw() { 
  background(0);
  sendValuesToDmx();
  drawRects();
  getIp();
  fill(255, 255, 255); stroke(255, 255, 255);
  text("my IP: " , 10, 15);
  text(myIP, 50, 15);
}



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  String addr = theOscMessage.addrPattern();
  int val = int(theOscMessage.get(0).floatValue());
  for(int i = 0; i <= 24; i++) {
    if(addr.equals("/1/fader" + str(i))) {
      channelValue[i] = val;
      channelValueHasChanged[i] = true;
    }
  }
}

void drawRects() {
  pushMatrix();
  for(int i = 1; i <= 12; i++) {
    stroke(255, 255, 0);
    fill(255, 255, 50);
    rect(i*100, height/2-100, 70, channelValue[i]*(-1));
    text("ch", i*100+10, height/2-50);
    text(str(i), i*100+30, height/2-50);
    text(":", i*100+45, height/2-50);
    text(str(channelValue[i]), i*100+50, height/2-50);
  }
  translate(-12*100, 255+100);
  for(int i = 13; i <= 24; i++) {
    stroke(255, 255, 0);
    fill(255, 255, 50);
    rect(i*100, height/2-100, 70, channelValue[i]*(-1));
    text("ch", i*100+10, height/2-50);
    text(str(i), i*100+30, height/2-50);
    text(":", i*100+45, height/2-50);
    text(str(channelValue[i]), i*100+50, height/2-50);
  }
  popMatrix();
}

void sendValuesToDmx() {
  for(int i = 0; i < channelValue.length; i++) {
    if(channelValueHasChanged[i]) {
      dmxSend(i, channelValue[i]);
      channelValueHasChanged[i] = false;
    }
  }
}

void dmxSend(int ch, int v) {
  myPort.write(str(ch) + "c" + str(v) + "w");
}
