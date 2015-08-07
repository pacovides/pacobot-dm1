//Simple structure to represent a message in this chat
class NetworkMessage {
  
  //Define the possible message types
  final String LOGIN = "HELLO",  LOGOUT = "BYE", COMMAND="SIMONSAYS", UNKNOWN = "GARBAGE";
  
  String messageType = UNKNOWN;
  String clientId = null;
  String command = null;
  
  
  NetworkMessage(String rawMsg){
    
    
  }
  
}
