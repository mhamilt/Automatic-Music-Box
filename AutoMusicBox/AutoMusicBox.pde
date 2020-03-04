import processing.svg.*;

MidiFile midiFile;
MusicBoxScore musicBoxScore;
float division = 1024;
String filename = "test_start_scale_with_B_197_spaced";
String directory = "data/svg/";

int[] midiKeys =    {48, 50, 55, 57, 59, 60, 62, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 86, 88};

ArrayList<ArrayList<MidiNote>> midiTracks;
ArrayList<MidiNote> tempScore;
ArrayList<MidiNote> bigChord;
void setup()
{   
  size(1000, 697); 

  getDisplayDim(133);

  midiFile = new MidiFile();
  midiFile.loadFile(filename);
  //bigChord = new ArrayList<MidiNote>();
  //for (int i : midiKeys)
  //{
  //  bigChord.add(new MidiNote(i, 64, (i==88)?1.0f:0.0f));
  //}
  //tempScore = new ArrayList<MidiNote>();
  //tempScore.addAll(bigChord);
  //for (int i : midiKeys)
  //{
  //  tempScore.add(new MidiNote(i, 64, 1.0f));
  //}
  //tempScore.addAll(tempScore);
  //midiTracks = new ArrayList<ArrayList<MidiNote>>();
  //midiTracks.add(new ArrayList<MidiNote>());
  //midiTracks.get(0).addAll(tempScore);
  //musicBoxScore = new MusicBoxScore(midiTracks);
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
      musicBoxScore.transpose-=12;
      break;
    case RIGHT:
      musicBoxScore.transpose+=12;
      break;
    }
  }
  redraw();
}
