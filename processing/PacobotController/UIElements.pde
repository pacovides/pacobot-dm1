
//Avatar only available for OpenGL friendly cards. Disabled for compatibility
class PacobotAvatar {
  int xAngle, yAngle;
   
  PacobotAvatar(int x0, int y0){
    xAngle = x0;
    yAngle = y0;
    
  }
  
  void setAngularPos(int x, int y){
    xAngle = x;
    yAngle = y;
  }
  
  void display(){
    fill(246, 225, 65);
    pushMatrix();
    translate(width/2, height/2);
    rotateY(radians(xAngle));
    box(50, 50, 80);
    translate(0,-80,50);
    rotateX(PI - radians(yAngle));
    box(50, 50, 80);
    popMatrix();
  }
  
}

class PacobotStatusConsole {
  int xAngle, yAngle;
  String errorMsg = "";
  
  //Absolute coordinates and size for the console
  int x,y,w,h;
   
  PacobotStatusConsole(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
  }
  
  void setAngularPos(int xAngle, int yAngle){
    this.xAngle = xAngle;
    this.yAngle = yAngle;
  }
  
    
  void display(){
    // Console main rectangle
    fill(180);
    rect(x, y, w, h);
    
    //Display pos
    fill(0);
    textSize(16);
    text("Horizontal angle: " + xAngle, x + 10, y + h - 40);
    text("Vertical angle: " + yAngle , x + 10, y + h - 20);
  
  }
  
}

//Simple round button.
class PushButton {
  
  //name of the button to be used 
  String name;
  
  //coordinates for the center of the button
  int x,y;
  //Diameter of the circle 
  int size;
  //Initial color of the button 
  color colorBase;
  
  //Color of the button when rolled over
  color colorOver;
  
  //color of the button when pressed
  color colorPressed;
     
  boolean isOn;
  
  PushButton(int x, int y, int size, String name){
    this.x = x;
    this.y = y;
    this.size = size;
    this.name = name;
    this.colorBase = color(50);
    this.colorOver = color(255,100,100);
    this.colorPressed = color(255,0,0);
    this.isOn = false;
  }
  
  void display(){
    stroke(0);
    ellipseMode(CENTER);
    
    if (mouseOver() && mousePressed) {
      fill(colorPressed);
      isOn = true;
    }
    else if (mouseOver()) {
      fill(colorOver);
      isOn = false;
    } else {
      fill(colorBase);
      isOn = false;
    }
  
    ellipse(x, y, size, size);
  }
  
  boolean mouseOver() {
    float disX = x - mouseX;
    float disY = y - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < size/2 ) {
      return true;
    } else {
      return false;
    }
  }
  
}

//Class to hold a set of mutually exclusive selections
class RadioBox {
  
  StringList optionNames;
  ArrayList<PushButton> optionButtons;
  int selectedIndex = 0;
  
  int x,y;
  String boxName;
  
  //Size of the full radio button, the push button will be a bit smaller
  final int buttonSize = 20;
    
  //We need position, a unique name for the box and the labels of the radio buttons
  RadioBox(int x, int y, String boxName, StringList optionNames){
    this.optionNames = optionNames;
    this.x = x;
    this.y = y;
    this.boxName = boxName;
    
    optionButtons = new ArrayList<PushButton>();
    
    //TODO validate not null or empty
    for(int i = 0; i < optionNames.size(); i++){
      int xBtn = x+5+buttonSize/2;
      int yBtn = y+ 5 + buttonSize/2 + buttonSize*i;
      optionButtons.add( new PushButton(xBtn,yBtn, buttonSize-6, boxName +"_opt_" + i));
    }
    
  }
  
  void display(){
    stroke(0);
    fill(255);
    textAlign(LEFT, CENTER);
    
    rect(x, y, 180, 10 + buttonSize*optionNames.size());
    for(int i = 0; i < optionNames.size(); i++){
      int xLbl = x + 10 +buttonSize;
      int yLbl = y+ 5 + buttonSize/2 + buttonSize*i;
      
      if(optionButtons.get(i).isOn){
        selectedIndex = i;
      }
      
      //If selected we draw a highlight behind the button
      if(selectedIndex == i){
        stroke(0);
        ellipseMode(CENTER);
        fill(120,10,10);
        ellipse(optionButtons.get(i).x, optionButtons.get(i).y, buttonSize, buttonSize);
      }
      optionButtons.get(i).display();
      
      fill(0);
      text(optionNames.get(i), xLbl, yLbl);
      
    }
  }
  
  String getSelectedOption(){
    return optionNames.get(selectedIndex);
  }
  
}

//Generic class to paint scrollbars
class Scrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x or y position of slider for horizontal or vertical scrollbars respectively
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

 Scrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    loose = l; 
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = getNewsPos();
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }
  
  float getNewsPos(){
    //To be overriden by child
    return 0.0;
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

//This over event works for both sliders but takes the whole slider as a rollover.
  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    update();
    stroke(0);
    fill(150);
    rect(xpos, ypos, swidth, sheight);
    noStroke();
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    paintSlider();
  }
  
  void paintSlider(){
    //To ve overriden by child
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  
}

class HScrollbar extends Scrollbar {
  
  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    //Do some basic initialization in parent class
    super(xp,yp,sw,sh,l);
    
    //Initialize particulars for horizontal scrollbar
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
  }

  //Updates the slider position
  float getNewsPos(){
    return constrain(mouseX-sheight/2, sposMin, sposMax);
  }
  
  //Gives back the relative position 
  float getRelPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos - xpos)* ratio;
  }
  
  //Paints the slider
  void paintSlider(){
    rect(spos, ypos, sheight, sheight);
  }
  
  //Over event is overriten to make it sensitive only to slider area
  boolean overEvent() {
    if (mouseX > spos && mouseX < spos+sheight &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

}

class VScrollbar extends Scrollbar{
   VScrollbar (float xp, float yp, int sw, int sh, int l) {
    //Do some basic initialization in parent class
    super(xp,yp,sw,sh,l);
    
    //Initialize particulars for horizontal scrollbar
    int heighttowidth = sh - sw;
    ratio = (float)sh / (float)heighttowidth;
    xpos = xp-swidth/2;
    ypos = yp;
    spos = ypos + sheight/2 - swidth/2;
    newspos = spos;
    sposMin = ypos;
    sposMax = ypos + sheight - swidth;
  }

  //Updates the slider position
  float getNewsPos(){
    return constrain(mouseY-swidth/2, sposMin, sposMax);
  }
  
  //Gives back the relative position 
  float getRelPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos - ypos)* ratio;
  }
  
  //Paints the slider
  void paintSlider(){
    rect(xpos, spos, swidth, swidth);
  }
  
  //Over event is overriten to make it sensitive only to slider area
  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > spos && mouseY < spos+swidth) {
      return true;
    } else {
      return false;
    }
  }
}
