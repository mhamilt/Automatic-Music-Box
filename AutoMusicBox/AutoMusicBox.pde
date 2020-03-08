import processing.svg.*;

MidiFile midiFile;
MusicBoxScore musicBoxScore;
float division = 1024;
String midiDirectory = "midi/"; 
String filename = "mellon_collie";
String svgDirectory = "data/svg/";

void setup()
{   
  size(1000, 697); 

  getDisplayDim(133);

  midiFile = new MidiFile();
  midiFile.loadFile(midiDirectory + filename);

  musicBoxScore = new MusicBoxScore(midiFile.getAllNotes());
  background(50);    
  musicBoxScore.drawToSvg(svgDirectory + filename);
  musicBoxScore.draw();
  noLoop();
}

void draw()
{
  musicBoxScore.drawToSvg(svgDirectory + filename);
  musicBoxScore.draw();
}

void keyPressed() 
{

  switch (key)
  {
  case 'a':
    musicBoxScore.rhythmSqueeze += 0.01;
    break;
  case 's':
    musicBoxScore.rhythmSqueeze -= 0.01;
    break;
  }
  if (key == CODED)
  {
    switch(keyCode)
    {
    case UP:
      musicBoxScore.transpose++;
      break;
    case DOWN:
      musicBoxScore.transpose--;
      break;
    case LEFT:      
      musicBoxScore.incPage(true);
      break;
    case RIGHT:    
      musicBoxScore.incPage(false);
      break;
    }
  }
  redraw();
}
