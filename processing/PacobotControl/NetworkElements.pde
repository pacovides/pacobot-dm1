//Simple structure to represent a message in this chat
class NetworkMessage {
  
  //Define the possible message types
  final static String LOGIN = "HELLO",  LOGOUT = "BYE", COMMAND="SIMONSAYS", UNKNOWN = "GARBAGE";
  
 
  
  String messageType = UNKNOWN;
  String clientId = null;
  String body = null;
  String serializedMsg;
  
  NetworkMessage(String messageType, String clientId, String body){
    
    //If this is not one of the 3 recognized message types we leave as unknown (in java enum would be used).
    if(messageType.equals(LOGIN) || messageType.equals(LOGOUT) || messageType.equals(COMMAND)){
       this.messageType = messageType;
    }
   
    this.clientId = clientId;
    this.body = body;
    
    this.serializedMsg =  clientId + ":"+ messageType + ":" + body;
    
   
  }
  
  NetworkMessage(String serializedMsg){
    this.serializedMsg = serializedMsg;
    if(serializedMsg!=null && serializedMsg.length()>0){
      String[] tokens = split(serializedMsg, ':');
      
      if(tokens.length == 3){
        this.clientId = tokens[0];
        this.messageType = tokens[1];
        this.body = tokens[2];
      }
      else{
        //If token size does not match we leave the message as unknown and put the whole content in the body
        this.body = serializedMsg;
      }
      
    }
    
  }
  
}

class PacobotClient {
   //Define the possible client types
  final static String ROBOT = "robot",  CONTROLLER = "ctrl";
  
  String clientType = null;
  String clientId = null;
  String clientIp = null;
  boolean active = true;
  
  PImage robotClientImg, ctrlClientImg;  // Images for presenting clients
  
  //Default constructor
  PacobotClient(){
    robotClientImg = null;
    ctrlClientImg = null; 
  
  }
  
  //Constructor with images to be displayed
  PacobotClient(PImage robotClientImg, PImage ctrlClientImg){
    this.robotClientImg = robotClientImg;
    this.ctrlClientImg = ctrlClientImg; 
  }
  
  //A client can be rendered at the specified pos
  void display(int x, int y, int size){
    if(ROBOT.equals(clientType)){
      if(robotClientImg != null){
        image(robotClientImg, x,y, size, size);
      }else{
        text("robot", x, y);
      }
    }else if(CONTROLLER.equals(clientType)){
      if(ctrlClientImg != null){
        image(ctrlClientImg, x,y, size, size);
      }else{
        text("controller", x, y);
      }
    }else{
       println("unknown type:" + clientType);
       text("???", x, y);
    }
    
    textAlign(LEFT);
    text("id:" + clientId, x, y + size + 5);
    text("ip:" + clientIp, x, y + size + 15);
        
  }
}
