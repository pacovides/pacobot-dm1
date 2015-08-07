import processing.net.*;

// Declare a server
Server server;

PFont f;
String incomingMessage = "";

// By default we attempt to connect to server at 127.0.0.1 (localhost), port 1990
final int serverPort = 1990;

void setup() {
  size(400,200);
  
  // Create the Server
  server = new Server(this, serverPort);
  f = createFont("Arial",20,true);
}

void draw() {
  background(50);
  
  // Display rectangle with new message color
  fill(255);
  textFont(f);
  textAlign(LEFT);
  text("Pacobot Central", 10, 20);
  
  textAlign(CENTER);
  text(incomingMessage,width/2,height/2);
  
  // If a client is available, we will find out
  // If there is no client, it will be"null"
  Client client = server.available();
  String incomingMessage = getMessageFromClient();
  //If there is a message we process it
  if(incomingMessage!=null){
    NetworkMessage message = new NetworkMessage(incomingMessage);
    println( "Message type:" + message.messageType);
  }
 
}

String getMessageFromClient(){
   // If a client is available, we will find out
  // If there is no client, it will be"null"
  Client client = server.available();
  // We should only proceed if the client is not null
  if (client!= null) {
    // Receive the message
    // The message is read using readString().
    String incomingMessage = client.readString(); 
    // The trim() function is used to remove the extra line break that comes in with the message.
    incomingMessage = incomingMessage.trim();
    // Print to Processing message window
    println( "Client sent:" + incomingMessage);
    return incomingMessage;
  }
  
  return null;
}

// The serverEvent function is called whenever a new client connects.
void serverEvent(Server server, Client client) {
  incomingMessage = "A new client has connected:" + client.ip();
  println(incomingMessage);
}
