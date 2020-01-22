 int IncomingDistance;
int value;
String DataIn;
import processing.serial.*; 
Serial myPort;  
float bx=200;   // inital x position of ball
float by=6;     // inital y position of ball
float bvy=0;    // y velocity of ball
float t=.25;    // Size of time steps.
float bvo;
float [] l = new float[21];  // Place holder for lines
float [] hole = new float [21];  // Place holder for holes
int x=0;               //x is used to keep track of which line you're on
int score=0;           //score is used to count how many lines you've dropped through
int h;                 //Integer version of hole location
float hr;              //Variable hloder for random hole location
PFont font;
float s=2;           //Line Speed Factor
float lastLine;        //Used when creating positions of new lines
boolean lose=false;    //Did you lose yet?
int endScore=0;        //Used on lose screen, keeps track of score position
boolean restart=false; //Should we restart?

void setup ()
{
  myPort = new Serial(this, Serial.list()[0], 9600); 
  myPort.bufferUntil(10);   //end the reception as it detects a carriage return
  size(200, 600);
  background(0);
  rectMode(CENTER);
  frameRate (120);
  stroke(255);
  randomSeed(0);
  initalLines();
  initialHoles();
  smooth();                         //Makes things look nicer
}
void serialEvent(Serial p) { 
    DataIn = p.readString(); 
    // println(DataIn);

    IncomingDistance = int(trim(DataIn)); //conversion from string to integer

    println(IncomingDistance); //checks....

    if (IncomingDistance>1  && IncomingDistance<100 ) {
        value = IncomingDistance;//save the value only if its in the range 1 to 50    }
bx=(50-value)*4;
     }
    
  }
  
void draw()
{
  if (lose)              // Check to see if you lost
  {
    lost();
  }
  else
  {
    background(0);            //Refresh background
    drawLines();              //Call the procedure to Draw all the lines with holes in them
    drawBall();
    paddle();                //Check to see if you pressed a button to move the ball
    ballLocation();          //update the ball's location for next frame
    text(score, 15, 30);          //Print value of score on the screen
  }
}


void holeCheck()
{
  if (bx<(hole[x]+5)&&bx>(hole[x]-5)&&by<590)    //On the hole? and not on the bottom of the screen
  {
    ballFall();
    x=x+1;                             //add one to the line count
    score=score+1;
    if (x==21)                          // did we pass the "last line"
    {
      x=0;                            //If yes, reset line cound and speed up
      s=s*1.2;
    }
  }
  else                               //If not on hole the set ball velocity to zero and 
  {                                  //make line "push it up" i.e. set ball y to line y
    by=l[x]-10;
    bvy=0;
    if (by<=5)                      // Was the ball pushed off the top?
    {
      by=600;
      lose=true;                   // If pushed off the top, you loose
    }
  }
}

void ballLocation()
{
  if (by<=(l[x]-10) && by<590)      //Is the ball between lines?
  {
    ballFall();             //If so make the ball fall
  }
  else                    //If it is on the line check to see if it's at the hole
  {
    holeCheck();
  }  
  if (by>595)
  {
    by=595;
  }
}

void drawLines()                    
{
  for (int p=0; p<21;p++)
  {
    if (l[p]<=0)                    //Did a line go off the top?
    {
      //If yes then create a new one at the bottom and put a new hole in it
      //The new line will be a random distance from the last line drawn 
      l[p]=int(random(lastLine+30, lastLine+50));  
      randomSeed(millis());        //Change random seed to make the hole placement more random
      hr=random(10, width-10);
      h=int(hr);
      hole[p]=h;
    }
    stroke(255);
    strokeWeight(2);
    line (0, l[p]-3, width, l[p]-3);       //Draw a line
    stroke(0);
    strokeWeight(4);
    line (hole[p]-6, l[p]-3, hole[p]+6, l[p]-3);  //Put the hole in the line
    l[p]=l[p]-1*s*t;                //Move the line up for next time
    lastLine=l[p];                  //Keep track of the location of the last line drawn
  }
}

void paddle()                      //Use arrow keys to move ball back and forth
{
  if (keyPressed && (key == CODED))
  {
    if (keyCode == RIGHT && bx<(width-5))
    {
      bx=bx+3;
    }
    else if (keyCode== LEFT && bx>(5))
    {
      bx=bx-3;
    }
  }
}

/*
In this game the ball accelerates as it falls. The weird math with variables
in this makes that happen. Basically using the constant accleration model where
x = .5at^2 + vot + xo It's all in there, you just have to look for it.

You could opt for a much easier constant motion while falling without greatly
impacting game play.
*/

void ballFall ()              //Cause ball to acelerate as it falls
{
  int a=3;
  bvo=bvy;
  bvy=bvy+a*t;              //Final velocity equals inital velocity + accel times time
  by=.5*bvy*t+bvo*t+by;
}

void drawBall()
{
  stroke(255);
  strokeWeight(1);
  ellipse (bx, by, 10, 10);      //Draw the ball
}

void initalLines()      //Randomly Spaces out the initial set of lines
{
  l[0]=600;
  for (int p=1; p<21;p++)
  {
    l[p]=int(random(l[p-1]+30, l[p-1]+50));
  }
}

void initialHoles()
{
  for (int p=0; p<21;p++)        //Randomly Generate hole locations for each line
  {
    hr=random(10, width-10);
    h=int(hr);
    hole[p]=h;                  //Save the location of each hole
  }
}

/*
What happens when you loose?

The lost() function causes the final score to slide down the screen.
Then it calls the end() function.

end() will leave the final score at the bottom of the page and print, 
"Click to restart". Clicking any button on the keyboard or mouse will
reset all the varibale to initial conditions and re-run the 
initalLines() and initialHoles() functions.

At some point it would be cool to add in a way to save High Scores.
*/

void lost()
{
  if (endScore<height-20)
  {
    //Cause the Final Score to slide down the screen
    background(0);
    text(score, width/2-10, endScore);
    endScore+=1;
  }
  else
  {
    end();
  }
}

void end()
{
  text("Click to restart", 27, height/2);
  if (keyPressed || mousePressed)
  {
    restart=true;
  }
  if (restart)
  {
    initalLines();
    initialHoles();
    bx=200;
    by=5;
    bvy=0;
    s=1.2;
    x=0;
    score=0;
    lose=false;
    endScore=0;
    restart=false;
  }
}