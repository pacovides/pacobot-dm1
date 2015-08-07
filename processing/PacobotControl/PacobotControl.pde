//Processing code:
import processing.serial.*;       
import processing.net.*;

//yMin defines the minimum angle at which the servo motor should go.
//Since the movement is inverted the lower this number, 
//the higher the camera can look upwards. 
//If it is too low the motors will collide.
final int yMin =80;

//yMax defines the maximum angle at which the servo motor should go.
//Since the movement is inverted the higher this number, 
//the lower the camera can look down. 
//If it is too high likely the camera/mobile will collide with the body.
//around 130 it will be vertical to the floor
final int yMax =145;

//xMin defines the minimum angle at which the servo motor should go.
//Since the movement is inverted this determines how far the head can move to the right.
final int xMin =0;

//xMax defines the maximum angle at which the servo motor should go.
//Since the movement is inverted this determines how far the head can move to the left.
final int xMax =180;

//The actual dynaic variables to hold the angle of our servos.
int xAngle = 90;
int yAngle = 90;
boolean isHeartOn = false;

Serial port = null; // The serial port we will be using

// By default we attempt to connect to server at 127.0.0.1 (localhost), port 1990
final int serverPort = 1990;
String serverIp = "127.0.0.1";

// Declare a client to connect to
Client client;

//Client type specifies what type of client this is
String clientType;
final String BOT="Robot", CTRL="Remote Controller";

HScrollbar xScrollBar;  //Scrollbar in control of panning
VScrollbar yScrollBar;  //Scrollbar in control of tilting

//Pacobot avatar only supported with OpenGL friendly cards
PacobotAvatar avatar;

PushButton heartButton; //button to activate the IR led at the heart of out bot
RadioBox modeSelector; //RadioBox to select the mode (local/client/server)

final int sliderSize = 16; //The preffered scrollbar size in both its sides

PFont f;

void setup()
{
  size(600, 600, P3D);
  frameRate(100);
  
  println(Serial.list()); // List COM-ports
  //select second com-port from the list (COM3 for my device)
  // You will want to change the [1] to select the correct device
  // Remember the list starts at [0] for the first option.
  
  if(Serial.list().length>0){
    port = new Serial(this, Serial.list()[0], 19200);
  }

  //Now we create some scrollbars for easier control
  noStroke();
  xScrollBar = new HScrollbar(0, height-sliderSize/2, width-sliderSize, sliderSize, sliderSize);
  yScrollBar = new VScrollbar(width-sliderSize/2, 0, sliderSize, height-sliderSize, sliderSize);
  avatar = new PacobotAvatar(90,90);
  heartButton = new PushButton(width - 50,height- 50,20, "heartButton");
  StringList optionNames = new StringList();
  optionNames.append("local");
  optionNames.append("remote-control");
  optionNames.append("remote-bot");
  modeSelector = new RadioBox(50, height- 100, "modeSelector", optionNames);

  f = createFont("Consolas", 16);
  textFont(f);
}

void draw()
{
  background(80);
  
  //We save the previous angle and client type for later comparison
  int prevX = xAngle;
  int prevY = yAngle;
  String prevClientType = clientType;
  boolean prevHeartState = isHeartOn;
  
  modeSelector.display();
  String selectedMode = modeSelector.getSelectedOption();
  
  //We create a new client each time client mode is changed
  if(selectedMode.equals("remote-control")){
    refreshClient(CTRL, prevClientType);
  }else if(selectedMode.equals("remote-bot")){
    refreshClient(BOT, prevClientType);
  }
  
  if(selectedMode.equals("local") || selectedMode.equals("remote-control")){
     //draw the controls if applicable
    xScrollBar.display();
    yScrollBar.display();
    stroke(0);
    line(0, height-sliderSize/2, width-sliderSize, height-sliderSize/2);
    line(width-sliderSize/2, 0, width -sliderSize/2, height-sliderSize);
  
    heartButton.display();
    
    //Calculate x,y locally
    xAngle = calculateXfromSlider();
    yAngle = calculateYfromSlider();
    isHeartOn = heartButton.isOn;
  }else{
    String incomingMessage = getMessageFromCentral();
    //If there is no message, there is no point processing it.
    if(incomingMessage!=null){
      processStringMessage(incomingMessage);
    }
    
  }
  
  textAlign(CENTER);
  fill(0);
  int fontPixelSize = 5;
  text(xAngle, width/2, height - sliderSize - fontPixelSize);
  text(yAngle, width- sliderSize - 3*fontPixelSize, height/2);

  avatar.setAngularPos(xAngle,yAngle);
  avatar.display();
    
  if(selectedMode.equals("local") || selectedMode.equals("remote-bot")){
    
    if( port==null){
      fill(255,0,0);
      textAlign(LEFT);
      text("Pacobot not detected.", 20, 20);
      text("Please connect your pacobot and restart the application.", 20, 40);
    }
    
    if(xAngle!=prevX || yAngle!=prevY){
      updateBotPos(xAngle, yAngle);
    }
    
    if(isHeartOn != prevHeartState){
      updateBotHeart(isHeartOn);
    }
  }else if(selectedMode.equals("client")){
    if(xAngle!=prevX || yAngle!=prevY){
      sendPosToServer(xAngle, yAngle);
    }
    
    if(isHeartOn != prevHeartState){
      sendHeartStateToServer(isHeartOn);
    }
  }
   
}

//If needed will create a new client and assign it a new unique id. And then attempt a connection to the central server.
void refreshClient(String newType, String prevType){
   clientType = newType;
    if(client==null || !clientType.equals(prevType) ){
      // Create the Client, connect to server at provided ip and port
      client = new Client(this,serverIp, serverPort);
      if(client.active()){
        println("client connected as " + clientType + " to  " + serverIp +":"+ serverPort);
      }else{
        println("unnable to connect to  " + serverIp +":"+ serverPort);
      }
        
    }
}

int calculateXfromSlider(){
  // Get the position of the xScrollBar scrollbar
  float xsbPos = xScrollBar.getPos();
  // and convert to a value that maps to the horizontal angle
  int calculatedX = floor(xsbPos*(xMax+1-xMin)/(width-sliderSize)) + xMin;
  return calculatedX;
}

int calculateYfromSlider(){
   // Get the position of the yScrollBar scrollbar
  float ysbPos = yScrollBar.getPos();
  // and convert to a value that maps to the vertical angle
  int calculatedY = floor(ysbPos*(yMax+1-yMin)/(height-sliderSize)) + yMin;
  return calculatedY;
}

String getMessageFromCentral(){
  
  // If there is information available to read from the Server
  if (client.available() > 0) {
    // Read message as a String, all messages from server are expected to end with an asterix
    String in = client.readStringUntil('*');
    // Print message received
    println( "Central sent:" + in);
    return in;
  }
  
  return null;
}

//Updates the values of x,y,led based on the incoming message
void processStringMessage(String incomingMsg){
  
  String error = null;
  
  if(incomingMsg==null || incomingMsg.isEmpty()){
    println("incoming message cannot be empty");
    return;
  }
  
  String[] coordinates = split(incomingMsg, ',');
  if(coordinates.length != 2){
    println("expected 2 values but got " +  coordinates.length);
    return;
  }
  
  if("heartLedOn".equals(coordinates[0])){
    
    if("true".equals(coordinates[1])){
      isHeartOn = true;
    }else if("false".equals(coordinates[1])){
      isHeartOn = false;
    }else{
      println("invalid value for heartLedOn " +  coordinates[1]);
      return;
    }
    
       
  }else{
    int xRead = int(coordinates[0]);
    int yRead = int(coordinates[1]);
    
    if(xRead<=xMax && xRead>=xMin){
      xAngle = xRead;
    }else{
      println("x value out of bounds " +  xRead);
      return;
    }
    
    if(yRead<=xMax && yRead>=xMin){
      yAngle = yRead;
    }else{
      println("y value out of bounds " +  xRead);
      return;
    }
    
  }
  
}

void updateBotPos(int x, int y)
{
  if(port!=null){
     //Output the servo position 
    port.write(x+"x");
    port.write(y+"y");
  }
  
  //useful for debugging
  println("("+x+"x,"+y+"y)");
  
}

void updateBotHeart(boolean lightIt)
{
  if(port!=null){
      if(lightIt){
      port.write("q");
    }else{
      port.write("w");
    }
  }
  
  println("heart lit? : " + lightIt);
}

void sendPosToServer(int x, int y)
{
  client.write(x+","+y);
}

void sendHeartStateToServer(boolean lightIt)
{
  String lightItStringValue;
  if(lightIt){
    lightItStringValue = "true";
  }else{
    lightItStringValue = "false";
  }
  
  client.write("heartLedOn,"+lightItStringValue);
}


