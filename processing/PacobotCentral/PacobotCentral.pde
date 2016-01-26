import processing.net.*;

// Declare a server
Server server;

//Declare a list of clients to hold
ArrayList<PacobotClient> clients = new ArrayList<PacobotClient>();

PFont titleFont, msgFont, captionFont;

PImage robotClientImg, ctrlClientImg;  // Images for presenting clients

// By default we attempt to connect to server at 127.0.0.1 (localhost), port 1990
final int serverPort = 1990;

//Boolean to determine if there is a client present
boolean clientOnline = false;

void setup() {
  size(600,400);
  
  // Create the Server
  server = new Server(this, serverPort);

  titleFont = loadFont("ROBO-36.vlw");
  msgFont = loadFont("OratorStd-36.vlw");
  captionFont = createFont("Arial",12,true);
  
  robotClientImg = loadImage("robot.png");  
  ctrlClientImg = loadImage("remote-ctrl.png");  
}

void draw() {
  background(20);
  
  // Display rectangle
  fill(180);
  rect(10, 50, width - 20, height - 60);
  
  //Main Title
  fill(255);
  textFont(titleFont,36);
  textAlign(CENTER);
  text("Pacobot Central", width/2, 40);
  
  //Server status
  fill(0);
  textFont(msgFont,14);
  textAlign(LEFT);
  text("Server started @ " + server.ip() + ":" + serverPort, 18, height - 18);
  
  text("Data", 45, 70);
  
   if(clientOnline){
    fill(0,255,0);
   }else{
     fill(50);
   }
  ellipse(25, 65, 15, 15);
  
  textAlign(CENTER);
 
  // If a client is available, we will find out
  // If there is no client, it will be"null"
  Client client = server.available();
   // We should only proceed if the client is not null
  if (client!= null) {
    clientOnline = true;
    String incomingMessage = getMessageFromClient(client);
    //If there is a message we process it
    processMessage(incomingMessage, client);
  }else{
    clientOnline = false;
  }
    
  if(clients.size()==0){
    textFont(msgFont,28);
    fill(0);
    text("No clients connected yet :(",width/2,height/2);
  } else{
    textFont(captionFont,12);
    fill(0);
    displayClients();
  }
  
 
}

String getMessageFromClient(Client client){
  // Receive the message
  // The message is read using readString().
  String incomingMessage = client.readString(); 
  if(incomingMessage != null){
    // The trim() function is used to remove the extra line break that comes in with the message.
    incomingMessage = incomingMessage.trim();
    // Print to Processing message window
    println( "Client sent:" + incomingMessage);
    return incomingMessage;
  }
  
  return null;
  
}

void processMessage(String incomingMessage, Client client){
  if(incomingMessage!=null){
    NetworkMessage message = new NetworkMessage(incomingMessage);
      
    if(message.messageType.equals(NetworkMessage.LOGIN)){
      PacobotClient pacobotClient = new PacobotClient(robotClientImg, ctrlClientImg);
      //We assign the id to match the position in the list of clients.
      pacobotClient.clientId = str(clients.size());
      pacobotClient.clientIp = client.ip();
      //We expect the client type to be specified in the body
      pacobotClient.clientType = message.body.trim();
      clients.add(pacobotClient);
      
      NetworkMessage reply = new NetworkMessage(NetworkMessage.LOGIN, pacobotClient.clientId, message.body);
      server.write(reply.serializedMsg);
      println("Server replied:"+ reply.serializedMsg);
      
    }else if(message.messageType.equals(NetworkMessage.LOGOUT)){
      //TODO
      
    }else if(message.messageType.equals(NetworkMessage.COMMAND)){
      
      //We simply echo back incoming command messages so all clients read them
      server.write(incomingMessage);
      
    }
    
  }
}

void displayClients(){
    int clientNum = 0;
    for (PacobotClient pClient : clients) {
      //TODO smarter split logic for more than 2 clients...
      int x,y;
      y = height/2 - 50;
      if(clients.size()==1){
        x = width/2 - 50;
      } else if(clients.size()==2){
        x = width/4 - 50 +  clientNum*width/2;
      }else{
        x = 10 +  clientNum*100;
      }
      
      pClient.display(x, y, 90);
      clientNum++;
    }
}

// The serverEvent function is called whenever a new client connects.
void serverEvent(Server server, Client client) {
  println("A new client has connected:" + client.ip());
}

void disconnectEvent(Client client) {
  println("A client has disconnected:" + client.ip());
}
