
//-----------------------------------------------------------------------//

//   -- Mini CNC Plotter - 15 --
//
//   Made the icons, buttons and labels connected objects. They now know
//   each other. This made easy to set and reset color, and show the
//   effects but with the effort of painstaking initiation of objects.
//   The icons and buttons except plotter direction icons work fine.
//   Now I have to add the missing icons.
//
//   Author : Vishnu M Aiea
//   E-Mail : vishnumaiea@gmail.com
//   Web : www.vishnumaiea.in
//   Date created : 12:20 PM 27-04-2017, Thursday
//   Last modified : 5:39 PM 08-05-2017, Monday

//-----------------------------------------------------------------------//

import processing.serial.*;

Serial serialPort;

//-----------------------------------------------------------------------//

//class definitons

public class uiButton {
  int buttonWidth, buttonHeight, buttonX, buttonY;
  color buttonColor, defaultColor, backupColor, hoverColor, activeColor, pressedColor;
  boolean ifPressed, ifClicked, ifHover, ifActive, mouseStatus;
  uiLabel linkedLabel;

  uiButton (int a, int b, int c, int d, color e, color f, color g, color h) {
    buttonX = a;
    buttonY = b;
    buttonWidth = c;
    buttonHeight = d;
    buttonColor = e;
    defaultColor = buttonColor;
    backupColor = buttonColor;
    hoverColor = f;
    pressedColor = g;
    activeColor = h;
    ifHover = false;
    ifPressed = false;
    ifClicked = false;
    ifActive = false;
    mouseStatus = false;
  }
  
  void display () {
    fill(buttonColor);
    rect(buttonX, buttonY, buttonWidth, buttonHeight);
    linkedLabel.display();
  }

  boolean isHover () {
    if ((mouseX >= buttonX) && (mouseX <= (buttonX + buttonWidth)) 
      && (mouseY >= buttonY) && (mouseY <= (buttonY + buttonHeight))) {
      buttonColor = hoverColor;
      linkedLabel.labelColor = linkedLabel.hoverColor;
      ifHover = true;
      return true;
    }
    else {
      buttonColor = defaultColor;
      linkedLabel.labelColor = linkedLabel.defaultColor;
      ifHover = false;
      return false;
    }
  }

  boolean isPressed () {
    if (isHover()) {
      if (mousePressed && (mouseButton == LEFT)) {
        ifPressed = true;
        buttonColor = pressedColor;
        return true;
      }
    }
    else {
      ifPressed = false;
    }
    return false;
  }

  boolean isClicked () {
    if (isHover()) {
      if (mousePressed && (mouseButton == LEFT) && (!mouseStatus)) {
        mouseStatus = true;
      }
      if ((!mousePressed) && (mouseStatus)) {
        ifClicked = true;
        mouseStatus = false;
        return true;
      }
    }

    if ((!isHover()) && (mouseStatus)) {
      mouseStatus = false;
    }
    return false;
  }
  
  void reset() {
   defaultColor = backupColor;
  }
  
  void setColor (color a) {
    defaultColor = a;
  }
  
  void setLabelColor (color a) {
    linkedLabel.setColor(a);
  }
  
  void linkLabel (uiLabel a) {
    linkedLabel = a;
  }
  
  void setLabel (String a) {
    linkedLabel.labelName = a;
  }
} //uiButton class ends

//-----------------------------------------------------------------------//

public class uiLabel {
  
  String labelName;
  int labelX, labelY, fontSize;
  PFont labelFont;
  color labelColor, defaultColor, backupColor, hoverColor, pressedColor, activeColor;
  uiButton linkedButton;
  
  uiLabel(String a, int b, int c, PFont d, int e, color f, color g, color h, color i) {
    labelName = a;
    labelX = b;
    labelY = c;
    labelFont = d;
    fontSize = e;
    labelColor = f;
    defaultColor = labelColor;
    backupColor = labelColor;
    hoverColor = g;
    pressedColor = h;
    activeColor = i;
  }
  
  void display() {
    
    if(linkedButton.isHover()) {
      labelColor = hoverColor;
      displayLabel();
    }
    
    else {
      labelColor = defaultColor;
      displayLabel();
    }
  }
  
  void displayLabel () {
    textFont(labelFont, fontSize);
    fill(labelColor);
    text(labelName, labelX, labelY);
  }
  
  void setColor (color a) {
    defaultColor = a;
  }
  
  void reset() {
    labelColor = backupColor;
    defaultColor = backupColor;
  }
  
  void linkButton (uiButton a) {
    linkedButton = a;
    labelX += linkedButton.buttonX;
    labelY += linkedButton.buttonY;
  }
} //uiLabel class ends

//------------------------------------------------------------------------//

public class textLabel {
  String labelName;
  int labelX;
  int labelY;
  PFont labelFont;
  int fontSize;
  color primaryColor;
  color defaultColor;
  
  textLabel (String a, int b, int c, PFont d, int e, color f) {
    labelName = a;
    labelX = b;
    labelY = c;
    labelFont = d;
    fontSize = e;
    primaryColor = f;
    defaultColor = primaryColor;
  }
  
  public void display () {
    fill(primaryColor);
    textFont(labelFont, fontSize);
    text(labelName, labelX, labelY);
  }
  
  public void setColor (color a) {
    primaryColor = a;
  }
  
  public void setName (String a) {
    labelName = a;
  }
  
  public void reset () {
    primaryColor = defaultColor;
  }
}

//-----------------------------------------------------------------------//


String [] serialStatusList= {"Error : Could not find the port specified !", 
  "Error : Device disconnected !",
  "Serial ended !",
  "No ports available !"};

int serialStatus = -1;

final int frameWidth = 800;
final int frameHeight = 650;

int imageHeight;
int imageWidth;

int imageBoxWidth = 337;
int imageBoxHeight = 260;
int imageBoxX = 437;
int imageBoxY= 120;

int infoBoxWidth = 386;
int infoBoxHeight = 260;
int infoBoxX = 25;
int infoBoxY= imageBoxY;

int controlBoxWidth = infoBoxWidth;
int controlBoxHeight = 210;
int controlBoxX = infoBoxX;
int controlBoxY= 425;

int consoleBoxWidth = imageBoxWidth;
int consoleBoxHeight = controlBoxHeight;
int consoleBoxX = imageBoxX;
int consoleBoxY= controlBoxY;

int boxTitleHeight = 25;
int boxTitleFontSize = 13;

int lineCount = 0;

int pixelLocation = 0;
int pixelRed;
int pixelGreen;
int pixelBlue;

int runCount = 0;

boolean pixelColor = false;
boolean prevPixelColor = true;

PImage imageSelected;

String imageFilePath;

int lineCountLimit = 5;
int [][][] lineCords = new int [2] [2] [lineCountLimit];

int globalI, globalJ, globalK;

String serialPortStatus;
String serialComStatus;

boolean isMainWindowStarted = false;
boolean isInitialWindowStarted = false;
boolean startMonitorSerial = false;
boolean startMainWindow = false;
boolean portSelectError;

boolean isImageLoaded = false;
boolean isImageSelected = false;
boolean isFilePromptOpen = false;
boolean imageLoadError = false;
boolean ifLoadimage = false;
boolean isPlottingStarted = false;
boolean isPlottingPaused = false;
boolean isPlotterActive = false;
boolean isPlottingFinished = false;

boolean ifCalibratePlotter = false;
boolean ifStartPlotter = false;
boolean ifPausePlotter = false;
boolean ifResumePlotter = false;
boolean ifStopPlotter = false;

boolean isSerialActive = false;
boolean ifCloseMainWindow = false;
boolean isUpPressed = false;
boolean isDownPressed = false;
boolean isleftPressed = false;
boolean isRightPressed = false;
boolean isPenDown = false;
boolean ifLines = false;
boolean ifPoints = false;
boolean ifFreehand = false;

int selectPortValue = -1; //virtual com port value
int portCount = 0;
int prevPortCount = 0;
int portIndexLimit = -1;
int activePortValue = -1;
int mouseStatusTemp = 0;
int tempInt; //int variable for testing
int comStatusCounter; //to check is the OBU is on and transmitting

String versionNumber = "3.2.45";

boolean startPressed = false; //for start button
boolean quitPressed = false; //for quit button
boolean aboutPressed = false;
boolean serialSuccess = false; //check if com port opening was successful
boolean isPortError = false; //port error status
boolean serialDisconnected = false;

String selectPortName = "NONE"; //name of port selected
String activePortName = "NONE";
String serialBuffer; //string that holds read serial data
String tempString; //string variable for testing
String comStatus = "Disconnected";

color colorWhite = #FFFFFF;
color colorBlue = #006699;
color colorRed = #c55757;
color colorGreen = #47B938;
color colorOrange = #F07A3F;
color colorLightGrey = 220;
color colorMediumGrey = 200;
color colorDarkGrey = 170;
color colorBlack = #000000;
color colorMediumBlack = 80;
color colorTextField = 240;
color colorDefaultButton = 235;

PFont robotoFont, poppinsFont, segoeFont, h4Font, h5Font, h6Font, fontAwesome;


uiButton  startMainButton;
uiButton  quitAppButton;
uiButton  startAboutButton;
uiButton  portDecButton;
uiButton  portIncButton;
uiButton  quitMainButton;

uiButton  plotterUpButton;
uiButton  plotterDownButton;
uiButton  plotterLeftButton;
uiButton  plotterRightButton;
uiButton  plotterPenButton;

uiButton  loadImageButton;
uiButton  linesButton;
uiButton  pointsButton;
uiButton  freehandButton;

uiButton  plotterStartButton;
uiButton  plotterPauseButton;
uiButton  plotterStopButton;
uiButton  plotterCalibrateButton;


uiLabel plotterStartButtonLabel;
uiLabel plotterPauseButtonLabel;
uiLabel plotterResumeButtonLabel;
uiLabel plotterStopButtonLabel;
uiLabel plotterCalibrateButtonLabel;

uiLabel plotterUpArrow;
uiLabel plotterDownArrow;
uiLabel plotterLeftArrow;
uiLabel plotterRightArrow;
uiLabel plotterPenArrow;
uiLabel plotterPenCircle;

uiLabel plotterStartIcon;
uiLabel plotterPauseIcon;
uiLabel plotterResumeIcon;
uiLabel plotterStopIcon;

uiLabel startMainButtonLabel;
uiLabel quitAppButtonLabel;
uiLabel aboutButtonLabel;

uiLabel loadImageButtonLabel;
uiLabel linesButtonLabel;
uiLabel pointsButtonLabel;
uiLabel freehandButtonLabel;

uiLabel portDecButtonLabel;
uiLabel portIncButtonLabel;
uiLabel quitMainButtonLabel;


textLabel fileName;

//-----------------------------------------------------------------------//

void setup() {
  size(800, 655);
  background(colorDarkGrey);

  surface.setTitle("Processing PNG Image");

  poppinsFont = createFont("Poppins Medium", 20); //font for about
  segoeFont = createFont("Segoe UI SemiBold", 20);
  fontAwesome = createFont("FontAwesome", 20);

  imageHeight = 327;
  imageWidth = 250;
  
  //instantiating labels
  //name, X, Y, font, fontSize, labelColor, hoverColor, pressedColor, activeColor, button
  plotterUpArrow = new uiLabel ("",113, 492, fontAwesome, 40, colorMediumGrey, colorBlue, colorOrange, colorOrange);
  plotterDownArrow = new uiLabel ("", 113, 592, fontAwesome, 40, colorMediumGrey, colorBlue, colorOrange, colorOrange);
  plotterLeftArrow = new uiLabel ("", 63, 542, fontAwesome, 40, colorMediumGrey, colorBlue, colorOrange, colorOrange);
  plotterRightArrow = new uiLabel ("", 163, 542, fontAwesome, 40, colorMediumGrey, colorBlue, colorOrange, colorOrange);
  plotterPenArrow = new uiLabel ("", 122, 538, fontAwesome, 27, colorWhite, colorBlue, colorOrange, colorOrange);
  plotterPenCircle = new uiLabel ("", 112, 543, fontAwesome, 42, colorMediumGrey, colorBlue, colorOrange, colorOrange);
  
  plotterStartIcon = new uiLabel ("", 15, 22, fontAwesome, 16, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterPauseIcon = new uiLabel ("", 15, 22, fontAwesome, 16, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterResumeIcon = new uiLabel ("", 15, 22, fontAwesome, 16, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterStopIcon = new uiLabel ("", 15, 22, fontAwesome, 16, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  
  startMainButtonLabel = new uiLabel ("START", 20, 23, segoeFont, 14, colorBlue, colorWhite, colorOrange, colorBlue);
  quitAppButtonLabel = new uiLabel ("QUIT", 22, 23, segoeFont, 14, colorBlue, colorWhite, colorOrange, colorBlue);
  aboutButtonLabel = new uiLabel ("ABOUT", 18, 23, segoeFont, 14, colorBlue, colorWhite, colorOrange, colorBlue);
  
  loadImageButtonLabel = new uiLabel ("Load Image", 16, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  linesButtonLabel = new uiLabel ("Lines", 36, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  pointsButtonLabel = new uiLabel ("Points", 32, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  freehandButtonLabel = new uiLabel ("Freehand", 24, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  
  quitMainButtonLabel = new uiLabel ("X", 600, 23, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  
  plotterStartButtonLabel = new uiLabel ("START", 52, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterPauseButtonLabel = new uiLabel ("PAUSE", 52, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterResumeButtonLabel = new uiLabel ("RESUME", 52, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterStopButtonLabel = new uiLabel ("STOP", 52, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  plotterCalibrateButtonLabel = new uiLabel ("CALIBRATE", 25, 20, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  
  portDecButtonLabel = new uiLabel ("START", 100, 23, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  portIncButtonLabel = new uiLabel ("START", 100, 23, segoeFont, boxTitleFontSize, colorMediumBlack, colorWhite, colorOrange, colorWhite);
  
  
  //instantiating buttons
  //(X, Y, W, H, Label, buttonColor, buttonHoverColor, buttonLabelColor, buttonLabelHoverColor
  startMainButton = new uiButton (220, 480, 80, 35, colorWhite, colorBlue, colorBlue, colorWhite);
  quitAppButton = new uiButton (360, 480, 80, 35, colorWhite, colorBlue, colorBlue, colorWhite);
  startAboutButton = new uiButton (500, 480, 80, 35, colorWhite, colorBlue, colorBlue, colorWhite);
  portDecButton = new uiButton (330, 270, 30, 40, colorWhite, colorBlue, colorBlue, colorWhite);
  portIncButton = new uiButton (430, 270, 30, 40, colorWhite, colorBlue, colorBlue, colorWhite);
  quitMainButton = new uiButton (748, 25, 25, 25, #018ec6, 240, 200, colorBlue);

  plotterUpButton = new uiButton (105, 455, 50, 50, colorDefaultButton, colorBlue, 50, 250);
  plotterDownButton = new uiButton (105, 555, 50, 50, colorDefaultButton, colorBlue, 50, 250);
  plotterLeftButton = new uiButton (55, 505, 50, 50, colorDefaultButton, colorBlue, 50, 250);
  plotterRightButton = new uiButton (155, 505, 50, 50, colorDefaultButton, colorBlue, 50, 250);
  plotterPenButton = new uiButton (105, 505, 50, 50, colorDefaultButton, colorBlue, 50, 250);

  loadImageButton = new uiButton (48, 182, 100, 30, colorDefaultButton, colorBlue, colorOrange, colorOrange);
  linesButton = new uiButton (48, 232, 100, 30, colorDefaultButton, colorBlue, colorOrange, colorBlue);
  pointsButton = new uiButton (48, 282, 100, 30, colorDefaultButton, colorBlue, colorOrange, colorBlue);
  freehandButton = new uiButton (48, 332, 100, 30, colorDefaultButton, colorBlue, colorOrange, colorBlue);

  plotterStartButton = new uiButton (265, 445, 115, 30, colorDefaultButton, colorBlue, colorOrange, colorWhite);
  plotterPauseButton = new uiButton (265, 490, 115, 30, colorDefaultButton, colorBlue, colorOrange, colorWhite);
  plotterStopButton = new uiButton (265, 535, 115, 30, colorDefaultButton, colorBlue, colorOrange, colorWhite);
  plotterCalibrateButton = new uiButton (265, 580, 115, 30, colorDefaultButton, colorBlue, colorOrange, colorWhite);
  
  portDecButton = new uiButton (265, 580, 115, 30, colorDefaultButton, colorBlue, colorMediumBlack, colorWhite);
  portIncButton = new uiButton (265, 580, 115, 30, colorDefaultButton, colorBlue, colorMediumBlack, colorWhite);
  
  
  startMainButton.linkLabel(startMainButtonLabel);
  quitAppButton.linkLabel(quitAppButtonLabel);
  startAboutButton.linkLabel(aboutButtonLabel);
  portDecButton.linkLabel(portDecButtonLabel);
  portIncButton.linkLabel(portIncButtonLabel);
  quitMainButton.linkLabel(quitMainButtonLabel);

  plotterUpButton.linkLabel(plotterUpArrow);
  plotterDownButton.linkLabel(plotterDownArrow);
  plotterLeftButton.linkLabel(plotterLeftArrow);
  plotterRightButton.linkLabel(plotterRightArrow);
  plotterPenButton.linkLabel(plotterPenCircle);

  loadImageButton.linkLabel(loadImageButtonLabel);
  linesButton.linkLabel(linesButtonLabel);
  pointsButton.linkLabel(pointsButtonLabel);
  freehandButton.linkLabel(freehandButtonLabel);

  plotterStartButton.linkLabel(plotterStartButtonLabel);
  plotterPauseButton.linkLabel(plotterPauseButtonLabel);
  plotterStopButton.linkLabel(plotterStopButtonLabel);
  plotterCalibrateButton.linkLabel(plotterCalibrateButtonLabel);
  
  //---------------------------------------------------------------//
  
  plotterStartButtonLabel.linkButton(plotterStartButton);
  plotterPauseButtonLabel.linkButton(plotterPauseButton);
  plotterStopButtonLabel.linkButton(plotterStopButton);
  plotterCalibrateButtonLabel.linkButton(plotterCalibrateButton);

  plotterUpArrow.linkButton(plotterUpButton);
  plotterDownArrow.linkButton(plotterDownButton);
  plotterLeftArrow.linkButton(plotterLeftButton);
  plotterRightArrow.linkButton(plotterRightButton);
  plotterPenArrow.linkButton(plotterPenButton);
  plotterPenCircle.linkButton(plotterPenButton);

  plotterStartIcon.linkButton(plotterStartButton);
  plotterPauseIcon.linkButton(plotterPauseButton);
  plotterResumeIcon.linkButton(plotterPauseButton);
  plotterStopIcon.linkButton(plotterStopButton);

  startMainButtonLabel.linkButton(startMainButton);
  quitAppButtonLabel.linkButton(quitAppButton);
  aboutButtonLabel.linkButton(startAboutButton);

  loadImageButtonLabel.linkButton(loadImageButton);
  linesButtonLabel.linkButton(linesButton);
  pointsButtonLabel.linkButton(pointsButton);
  freehandButtonLabel.linkButton(freehandButton);

  portDecButtonLabel.linkButton(portDecButton);
  portIncButtonLabel.linkButton(portIncButton);
  quitMainButtonLabel.linkButton(quitMainButton);

  
  fileName = new textLabel ("None", 125, 152, segoeFont, boxTitleFontSize, colorMediumBlack);
}

//-----------------------------------------------------------------------//

void draw() {
  if ((!startPressed) && (!aboutPressed)) {
    showInitialWindow();
  }

  if (startPressed) {
    showMainWindow();
  }

  if (aboutPressed) {
    showAboutWindow();
  }
}

//-----------------------------------------------------------------------//

void showInitialWindow() {
  showInitialStaticInfo();
  
  if(isPortError) { //check wether a port error occurred in main window
    isPortError = false;
  }
  else {
    isPortError = false;
  }
  
  startMainButton.isHover();
  quitAppButton.isHover();
  startAboutButton.isHover();

  if (quitAppButton.isClicked()) {
    exit();
  }

  if (startMainButton.isClicked()) {
    startPressed = true;
  }

  if (startAboutButton.isClicked()) {
    aboutPressed = true;
  }
  
  if (serialStatus == 0) { //could not find the port error
    textFont(segoeFont, 15);
    fill(colorRed);
    text(serialStatusList[serialStatus], 260, 410);
  } 
  
  else if (serialStatus == 1) { // device disconnected
    textFont(segoeFont, 15);
    fill(colorRed);
    text(serialStatusList[serialStatus], 300, 410);
  } 
  
  else if(serialStatus == 2){ //serial ended by user
    textFont(segoeFont, 15);
    fill(colorRed);
    text(serialStatusList[serialStatus], 350, 410);
  }
  
  else if(serialStatus == 3) { //no ports available
    textFont(segoeFont, 15);
    fill(colorRed);
    text(serialStatusList[serialStatus], 330, 410);
  }
  
  else {
    fill(colorWhite);
    rect(260, 410, 300, 20);
  }

  getSerialPortInfo();

  if (portCount != 0) { //check if there is any port

    if ((selectPortValue == -1) || (portCount < prevPortCount)) {
      selectPortValue = 0;
    }

    if (portDecButton.isPressed()) {
      if (selectPortValue > 0) {
        selectPortValue--;
        selectPortName = Serial.list()[selectPortValue];
        mouseStatusTemp = 1;
        printVerbose("Port Decrement");
      }
    } else {
      selectPortName = Serial.list()[selectPortValue];
    }

    if (portIncButton.isPressed()) {
      if ((selectPortValue < (Serial.list().length -1 )) && (selectPortValue > -1)) {
        selectPortValue++;
        selectPortName = Serial.list()[selectPortValue];
        mouseStatusTemp = 1;
        printVerbose("Port Increment");
      }
    } else {
      selectPortName = Serial.list()[selectPortValue];
    }

    textFont(segoeFont, 12);
    fill(colorBlack); //com port value color
    text(selectPortName, 375, 295); //then print it
    prevPortCount = portCount;
  }

  if (portCount == 0) {
    textFont(segoeFont, 12);
    fill(colorBlack); //com port value color
    text("NONE", 378, 295);
    selectPortName = "NONE";
    selectPortValue = -1;
    serialStatus = 3; //no ports available
  }
  
  else if(portCount >0) {
    
    if(serialStatus == 3) {
      serialStatus = -1;
    }
  }
}

//-----------------------------------------------------------------------//

//displays static titles and stuff

void showInitialStaticInfo () {
  smooth();
  noStroke();
  background(colorDarkGrey);
  fill(colorLightGrey);
  rect(125, 450, 550, 95); //third box in starting window
  
  startMainButton.display();
  startAboutButton.display();
  quitAppButton.display();
  
  fill(colorWhite);
  rect(125, 100, 550, 350); //second box in initial window

  fill(colorBlue);
  rect(125, 90, 550, 120); //first box in initial window

  textFont(poppinsFont, 26);
  fill(colorWhite);
  text("MINI CNC PLOTTER", 280, 140);

  textFont(poppinsFont, 12);
  fill(colorMediumGrey);
  text("Version", 355, 170);
  text(versionNumber, 405, 170);

  textFont(poppinsFont, 12);
  fill(colorMediumGrey);
  text("© 2017  Vishnu M Aiea", 332, 195);

  fill(colorBlue);
  textFont(segoeFont, 15);
  text("Connect the Plotter and select the COM port", 246, 375);

  rect(330, 270, 130, 40); //COM port selection
  fill(colorWhite);
  rect(360, 272, 70, 36); //small rect for port value

  textFont(fontAwesome, 27);
  fill(colorWhite);
  text("", 338, 300); //port select arrow kyes
  text("", 442, 300);
}

//-----------------------------------------------------------------------//

//gets the number of currenlty available serial COM ports

void getSerialPortInfo() {
  portCount = Serial.list().length;
  portIndexLimit = portCount - 1;
}

//-----------------------------------------------------------------------//

//prints all the variables to the console

void printVerbose(String verboseLocation) {
  println("--Start Verbose at " + verboseLocation + "--");
  println("startPressed : " + startPressed);
  println("quitPressed : " + quitPressed);
  println("aboutPressed : " + aboutPressed);
  println("serialSuccess : " + serialSuccess);
  println("isMainWindowStarted : " + isMainWindowStarted);
  println("serialDisconnected : " + serialDisconnected);
  println("isPortError : " + isPortError);
  println("portCount : " + portCount);
  println("selectPortValue : " + selectPortValue);
  println("selectPortName : " + selectPortName);
  //println("isPortAlive : " + isPortAlive());
  println("activePortValue : " + activePortValue);
  println("activePortName : " + activePortName);
  println("--End Verbose--");
  println("\n");
}

//-----------------------------------------------------------------------//

void showMainWindow() {
  
  //------------------------------------------//
  
  getSerialPortInfo();
  
  if (portCount == 0) {
    //serialPort.stop();
    serialSuccess = false;
    startPressed = false;
    startMainWindow = false;
    isPortError = true;
    serialStatus = 3; //device disconnected
    activePortName = "NONE";
    activePortValue = -1;
    selectPortName = "NONE";
    selectPortValue = -1;
    printVerbose("Zero Ports Available");
  }
  
  //------------------------------------------//
  
  if ((startPressed) && (portCount != 0) && (!isPortError)) {
    if (!serialSuccess) {
      establishSerial();
    }

    if (serialSuccess) {
      startMainWindow = true;
    } 
    
    else {
      startMainWindow = false;
      startPressed = false;
      serialSuccess = false;
    }
  }
  
  //------------------------------------------//
  
  if((serialSuccess) && (!isPortActive(activePortName))) {
    serialSuccess = false;
    startPressed = false;
    isPortError = true;
    startMainWindow = false;
    serialStatus = 1;
    activePortName = "NONE";
    activePortValue = -1;
    selectPortName = "NONE";
    selectPortValue = -1;
    printVerbose("Active Port Error");
  }
  
  //-------------------------------------------//
  
  if ((startMainWindow) && (!isPortError) && (isPortActive(activePortName))) {

    //-------------- Main Window Contents Start Here -------------//
    
    smooth();
    noStroke();
    background(colorMediumGrey);
    
    //----------- Static Title -------------------------//
    
    fill(colorBlue);
    rect(0, 0, 800, 75);
    
    textFont(poppinsFont, 25);
    fill(colorWhite);
    text("MINI CNC PLOTTER", 280, 37);

    textFont(poppinsFont, 12);
    fill(colorMediumGrey);
    text("Version", 345, 62);
    text(versionNumber, 395, 62);
    
    //----------- Static Title Ends --------------------//
    
    
    //----------------- Boxes -------------------------//
    
    fill(colorWhite);
    rect(imageBoxX, imageBoxY, imageBoxWidth, imageBoxHeight);
    
    if(isImageLoaded) {
      image(imageSelected, (imageBoxX+5), (imageBoxY+5));
    }
    else {
      fill(colorMediumBlack);
      textFont(segoeFont, 13);
      text("No Image Selected", 550, 250);
    }
    
    fill(colorBlue);
    rect(imageBoxX, imageBoxY-boxTitleHeight, imageBoxWidth, boxTitleHeight);
    fill(colorWhite);
    textFont(segoeFont, boxTitleFontSize);
    text("Progress", imageBoxX+10, imageBoxY-8);

    fill(colorWhite);
    rect(infoBoxX, infoBoxY, infoBoxWidth, infoBoxHeight);
    fill(colorBlue);
    rect(infoBoxX, infoBoxY-boxTitleHeight, infoBoxWidth, boxTitleHeight);
    fill(colorWhite);
    textFont(segoeFont, boxTitleFontSize);
    text("Info", infoBoxX+10, infoBoxY-8);

    fill(colorWhite);
    rect(controlBoxX, controlBoxY, controlBoxWidth, controlBoxHeight);
    fill(colorBlue);
    rect(controlBoxX, controlBoxY-boxTitleHeight, controlBoxWidth, boxTitleHeight);
    fill(colorWhite);
    textFont(segoeFont, boxTitleFontSize);
    text("Control", controlBoxX+10, controlBoxY-8);

    fill(colorWhite);
    rect(consoleBoxX, consoleBoxY, consoleBoxWidth, consoleBoxHeight);
    fill(colorBlue);
    rect(consoleBoxX, consoleBoxY-boxTitleHeight, consoleBoxWidth, boxTitleHeight);
    fill(colorWhite);
    textFont(segoeFont, boxTitleFontSize);
    text("Console", consoleBoxX+10, consoleBoxY-8);
    
    //----------------- Boxes Ends -------------------------//
    
    
    //----------------- Box Contents -----------------------//
    
    textFont(segoeFont, boxTitleFontSize);
    fill(colorMediumBlack);
    text("Filename", infoBoxX+20, infoBoxY+32);
    fill(colorTextField);
    rect(infoBoxX+85, infoBoxY+14, 280, boxTitleHeight);

    loadImageButton.display();
    linesButton.display();
    pointsButton.display();
    freehandButton.display();
    
    loadImageButton.isHover();
    linesButton.isHover();
    pointsButton.isHover();
    freehandButton.isHover();
    
    
    //--------- Image Selection -----------------------------//
    
    if((loadImageButton.isClicked()) && (!isFilePromptOpen)) { //if button clicked and prompt is not already open
      if(!isImageLoaded) {
        isFilePromptOpen = true; //file prompt is now open
        selectInput("Select a PNG file :", "selectImageFile");
      }
    }
    
    if((isImageSelected) && (!isImageLoaded)) {
      imageSelected = loadImage(imageFilePath, "png");
      
      if (imageSelected == null) {
        imageSelected = null;
        isImageLoaded = false;
        isImageSelected = false;
        imageFilePath = null;
        isFilePromptOpen = false;
        fileName.reset();
        fileName.labelName = "None";
      }
      
      if((imageSelected.width == -1) || (imageSelected.height == -1)) { //chedck if image is valid
        println("Incompatible file was selected.");
        fileName.setColor(colorRed);
        fileName.labelName = "Invalid File";
        isImageLoaded = false; //reset everything if not valid
        isImageSelected = false;
        imageFilePath = null;
        isFilePromptOpen = false;
        imageSelected = null;
      }
      
      else { //proceed if valid
        isImageLoaded = true;
        isFilePromptOpen = false;
        ifLines = true;
        ifPoints = false;
        ifFreehand = false;
        fileName.reset();
        fileName.labelName = getFileName(imageFilePath);
        println("Image loaded");
      }
    }
    
    fileName.display();
    loadImageButton.isPressed();
    
    //--------------Image Selection Ends ----------------------//
    
    
    //-------------- Plotting Type Selection ------------------//
    
    linesButton.display();
    pointsButton.display();
    freehandButton.display();
    
    linesButton.isHover();
    pointsButton.isHover();
    freehandButton.isHover();
    
    if((linesButton.isClicked()) || (ifLines)) {
      linesButton.setColor(colorBlue);
      linesButtonLabel.setColor(colorWhite);
      
      pointsButton.reset();
      pointsButtonLabel.reset();
      freehandButton.reset();
      freehandButtonLabel.reset();
      
      if((!isPlottingStarted) && (!ifLines)) {
        ifLines = true;
        ifPoints = false;
        ifFreehand = false;
        println("Lines Selected");
      }
    }
    
    if((pointsButton.isClicked()) || (ifPoints)) {
      pointsButton.setColor(colorBlue);
      pointsButtonLabel.setColor(colorWhite);
      
      linesButton.reset();
      linesButtonLabel.reset();
      freehandButton.reset();
      freehandButtonLabel.reset();
      
      if((!isPlottingStarted) && (!ifPoints)) {
        ifLines = false;
        ifPoints = true;
        ifFreehand = false;
        println("Points Selected");
      }
    }
    
    if((freehandButton.isClicked()) || (ifFreehand)) {
      freehandButton.setColor(colorBlue);
      freehandButtonLabel.setColor(colorWhite);
      
      linesButton.reset();
      linesButtonLabel.reset();
      pointsButton.reset();
      pointsButtonLabel.reset();
      
      if((!isPlottingStarted) && (!ifFreehand)) {
        ifLines = false;
        ifPoints = false;
        ifFreehand = true;
        println("Freehand Selected");
      }
    }
    
    //linesButton.isPressed();
    //pointsButton.isPressed();
    //freehandButton.isPressed();
    
    //-------------- Plotting Type Selection Ends ------------------//
    
    
    //-------------- Info Fields ------------------//
    
    //loadImageButtonLabel.display();
    //linesButtonLabel.display();
    //pointsButtonLabel.display();
    //freehandButtonLabel.display();

    fill(colorMediumBlack);
    text("Port", infoBoxX+160, infoBoxY+75);
    text("Serial Status", infoBoxX+160, infoBoxY+115);
    text("Plotter Status", infoBoxX+160, infoBoxY+155);
    text("Position", infoBoxX+160, infoBoxY+195);
    text("Current Task", infoBoxX+160, infoBoxY+235);

    fill(colorTextField);
    rect(infoBoxX+254, infoBoxY+57, 110, boxTitleHeight);
    rect(infoBoxX+254, infoBoxY+97, 110, boxTitleHeight);
    rect(infoBoxX+254, infoBoxY+137, 110, boxTitleHeight);
    rect(infoBoxX+254, infoBoxY+177, 110, boxTitleHeight);
    rect(infoBoxX+254, infoBoxY+217, 110, boxTitleHeight);
    
    //-------------- Info Fields Ends ------------------//
    
    
    //----------- Movement Control Buttons -----------------------//
    
    //--------------------------------//
    
    if (plotterUpButton.isHover()) {
       plotterUpArrow.setColor(colorBlue);
    } else {
      plotterUpArrow.reset();
    }
    
    if (plotterUpButton.isPressed()){
      plotterUpArrow.setColor(colorOrange);
    }
    
    plotterUpArrow.displayLabel();
    
    //-------------------------------//
    
    if (plotterLeftButton.isHover()) {
       plotterLeftArrow.setColor(colorBlue);
    } else {
      plotterLeftArrow.reset();
    }
    
    if (plotterLeftButton.isPressed()){
      plotterLeftArrow.setColor(colorOrange);
    }
    
    plotterLeftArrow.displayLabel();
    
    //-------------------------------//
    
    if (plotterPenButton.isHover()) {
       plotterPenCircle.setColor(colorBlue);
    } else {
      plotterPenCircle.reset();
    }
    
    if (plotterPenButton.isPressed()){
      plotterPenCircle.setColor(colorOrange);
    }
    
    plotterPenCircle.displayLabel();
    plotterPenArrow.displayLabel();
    
    //------------------------------//
    
    if (plotterRightButton.isHover()) {
       plotterRightArrow.setColor(colorBlue);
    } else {
      plotterRightArrow.reset();
    }
    
    if (plotterRightButton.isPressed()){
      plotterRightArrow.setColor(colorOrange);
    }
    
    plotterRightArrow.displayLabel();
    
    //------------------------------//
    
    if (plotterDownButton.isHover()) {
       plotterDownArrow.setColor(colorOrange);
    } else {
      plotterDownArrow.reset();
    }
    
    if (plotterDownButton.isPressed()){
      plotterDownArrow.setColor(colorOrange);
    }
    
    plotterDownArrow.displayLabel();
    
    //------------------------------//
    
    //----------- Movement Control Buttons Ends-----------------------//
     
     
    //----------- Control Buttons -----------------------//
    
    plotterStartButton.display();
    plotterPauseButton.display();
    plotterStopButton.display();
    plotterCalibrateButton.display(); 
    
    plotterStartButton.isHover();
    plotterPauseButton.isHover();
    plotterStopButton.isHover();
    plotterCalibrateButton.isHover();
    
    
    if(((plotterStartButton.isClicked()) && (isImageLoaded)) || ifCalibratePlotter) {
      
      ifStartPlotter = true;
      ifStopPlotter = false;
      
      plotterStartButton.setColor(colorGreen);
      plotterStartButton.setLabelColor(colorWhite);
      
      plotterStopButton.setColor(colorRed);
      plotterStopButton.setLabelColor(colorWhite);
    }
    
    if((plotterStopButton.isClicked()) && (ifStartPlotter)) {
      
      ifStartPlotter = false;
      ifStopPlotter = true;
      ifPausePlotter = false;
      ifCalibratePlotter = false;
      
      plotterStopButton.reset();
      plotterStopButtonLabel.reset();
      plotterStartButton.reset();
      plotterStartButtonLabel.reset();
      plotterCalibrateButton.reset();
    }
    
    if((plotterPauseButton.isClicked()) && (ifStartPlotter)) {
      ifPausePlotter = (ifPausePlotter ? false: true);
    }
    
    if((plotterCalibrateButton.isClicked()) && (!ifStartPlotter)) {
      ifCalibratePlotter = true;
    }
    
    if(!ifPausePlotter) {
      plotterPauseButton.isHover();
      plotterPauseButton.isPressed();
      
      plotterPauseButton.reset();
      plotterPauseButtonLabel.reset();
      plotterPauseButton.setLabel("PAUSE");
      plotterPauseIcon.display();
    }
    
    if(ifPausePlotter) {
      plotterPauseButton.setLabel("RESUME");
      plotterPauseButton.setColor(colorBlue);
      plotterPauseButton.setLabelColor(colorWhite);
      
      plotterResumeIcon.setColor(colorWhite);
      plotterResumeIcon.display();
    }
    
    plotterStartIcon.display();
    plotterStopIcon.display();
    
    plotterStartButton.isPressed();
    plotterStopButton.isPressed();
    plotterCalibrateButton.isPressed();
    plotterPauseButton.isPressed();
    
    //----------- Control Buttons Ends-----------------------//
    
    //----------------- Box Contents Ends -----------------------//
    
    
    //------------- Quit Button -----------------------//
    
    quitMainButton.display();
    quitMainButton.isHover();
    //fill(quitMainButton.labelColor);
    textFont(fontAwesome, 22);
    text("", 752, 45); //quit main window button
    
    if (quitMainButton.isClicked()) { //reset everything
      startPressed = false;
      isPortError = false;
      serialSuccess = false;
      startMainWindow = false;
      serialStatus = 2;
      activePortName = "NONE";
      activePortValue = -1;
      selectPortName = "NONE";
      selectPortValue = -1;
      
      isImageLoaded = false;
      isImageSelected = false;
      imageFilePath = null;
      isFilePromptOpen = false;
      fileName.labelName = "None";
      fileName.reset();
      
      ifStartPlotter = false;
      ifPausePlotter = false;
      ifStopPlotter = true;
      ifCalibratePlotter = false;
      plotterStartButton.reset();
      plotterStopButton.reset();
      plotterCalibrateButton.reset();
      
      
      printVerbose("Connection ended by user.");
      
      if(serialPort.active()) {
        serialPort.stop();
      }
    }
    
    //----------------Quit Button Ends -------------------//
    
    
    if ((serialPort.active()) && (activePortName != "NONE")) {
      textFont(segoeFont, boxTitleFontSize);
      fill(colorMediumBlack);
      text(activePortName, infoBoxX+290, infoBoxY+75);
    }
    //------ Main Window Contents End Here -------//
  }
}

//----------------------------------------------------------------------//

//establishes serial comuuncation through the selected COM port

void establishSerial() {
  if (!serialSuccess) {
    getSerialPortInfo();

    if ((portCount> 0) && (selectPortValue > -1) && (selectPortValue < portCount)) {
      printVerbose("establishSerial");
      activePortName = Serial.list()[selectPortValue];
      printVerbose("establishSerial-2");
      serialPort = new Serial(this, activePortName, 9600);
      activePortValue = selectPortValue;
      println("Serial Communication Established");
      println("Listing ports");
      println(Serial.list()); //list the available ports
      println();
      print("Selected Port is ");
      println(activePortName); //print selected port name
      print("portValue = ");
      println(activePortValue); //print the port value use selected
      print("Total no. of ports = ");
      println(Serial.list().length); //total no. of ports
      println();
      serialSuccess = true;
      isPortError = false;
      printVerbose("Serial Establish Success");
    } 
    
    else {
      serialStatus = 0;
      println("Error : Could not find the port specified");
      println();
      serialSuccess = false; //serial com error
      startPressed = false; //causes returning to home screen
      printVerbose("Serial Establish Error");
    }
  }
}

//----------------------------------------------------------------------//

//checks if a selected COM port is currently present/active

boolean isPortActive (String portTocheck) {
  boolean portActiveStatus = false;
  if (portCount > 0) {
    for (int i=0; i<portCount; i++) {
      if (portTocheck.equals(Serial.list()[i])) {
        //println(Serial.list()[i]);
        portActiveStatus = true;
        isPortError = false;
        break;
      }
      if ((i == (portCount-1))) {
        portActiveStatus = false;
        isPortError = true;
      }
    }
  }
  return portActiveStatus;
}

//----------------------------------------------------------------------//

//shows the about, credits, getting started tutorial etc

void showAboutWindow() {
  showInitialWindow();
}

//-----------------------------------------------------------------------//

//opens file selection prompt and let you select a file

void selectImageFile(File selectedPath) {
  if (selectedPath == null) {
    println("Window was closed or the user hit cancel.");
    imageFilePath = null; //reset image parameters
    imageSelected = null;
    isImageLoaded = false;
    isImageSelected = false;
    isFilePromptOpen = false;
  } 
  else {
    println("User selected " + selectedPath.getAbsolutePath());
    imageFilePath = selectedPath.getAbsolutePath();
    isImageSelected = true;
  }
}

//-----------------------------------------------------------------------//

//gets the filename from the absolute path

String getFileName(String filePath) {
  String [] splittedString = splitTokens(filePath, "\\");
  return splittedString[splittedString.length - 1];
}

//-----------------------------------------------------------------------//