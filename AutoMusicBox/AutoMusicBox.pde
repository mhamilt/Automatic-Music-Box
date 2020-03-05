import processing.svg.*;

MidiFile midiFile;
MusicBoxScore musicBoxScore;
float division = 1024;
String filename = "midi/blackbird";
String directory = "data/svg/";

void setup()
{   
  size(1000, 697); 

  getDisplayDim(133);

  midiFile = new MidiFile();
  midiFile.loadFile(filename);

  musicBoxScore = new MusicBoxScore(midiFile.getAllNotes());
  background(50);    
  musicBoxScore.drawToSvg(directory + filename);
  musicBoxScore.draw();
  noLoop();
}

void draw()
{
  musicBoxScore.drawToSvg(directory+filename);
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
      //pageforward;
      musicBoxScore.transpose-=12;
      break;
    case RIGHT:
    //pagebackward;
      musicBoxScore.transpose+=12;
      break;
    }
  }
  redraw();
}
