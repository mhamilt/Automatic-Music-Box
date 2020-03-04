import java.util.ArrayList;
import java.util.List;
//---------------------------------------------------------------------------------------------------------
class MusicBoxScore
{
  //---------------------------------------------------------------------------
  int xWriteOffset = 150;
  int writeHeadX = xWriteOffset;
  //---------------------------------------------------------------------------
  // mm measurements
  float keySpacing = 1.97;
  int pixelsPerMm;
  int dpi = 226;
  float scoreHeight = 70.0;
  float margin = 6.44;
  float minNoteDist = 6.5;
  float noteRadius = 2.1;
  float mmPerBeat = 8.0;
  float scaling = 10; // mm to pixel scaling factor 5.4 matches to this screen
  float pixelsPerBeat = mmPerBeat * scaling;
  float minRepeatDur = minNoteDist / mmPerBeat;
  //---------------------------------------------------------------------------
  float bpm;
  //---------------------------------------------------------------------------
  int maxNote = 88;
  int minNote = 48;
  int[] midiKeys =    {48,50, 55, 57, 59, 60, 62, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83,84, 86, 88};
  String noteString = "C, D,  G,  A,  B,  C1, D1, E1, F1, F#1, G1,G#1,A1,A#1, B1, C2,C#2, D2, D#2,E2, F2, F#2,G2,G#2,A2, A#2,B2,C3,D3,E3";
  List<String> noteList;
  int minDelta = 20;
  int smallestDelta = 200;
  float shortestDuration = 1.0;
  //---------------------------------------------------------------------------
  ArrayList<MusicBoxNote> score;
  ArrayList<ArrayList<MidiNote>> midiScore;
  IntList midiNotePallet;
  int missedNotes = 0;
  int transpose = 0;
  float rhythmSqueeze = 1.0;
  PGraphics svg;
  float svg_scale = 2.85;
  float pixelsSvgPerBeat = mmPerBeat * svg_scale;
  //---------------------------------------------------------------------------

  MusicBoxScore(ArrayList<ArrayList<MidiNote>> midiTracks)
  {
    noteList = Arrays.asList(noteString.split("\\s*,\\s*"));
    score = new ArrayList<MusicBoxNote>();
    midiScore = midiTracks;
  }
  //---------------------------------------------------------------------------
  void setMidiNotePallet()
  {
    //for (MidiNote n : midiScore)
    //{
    //  if (!midiNotePallet.hasValue(n.note))
    //  {
    //    midiNotePallet.append(n.note);
    //  }
    //}
  }
  //---------------------------------------------------------------------------
  float getShortestSuccessiveRhythm()
  {
    for (int i : midiNotePallet)
    {
      //  float beatCounter = 0.0;
      //  boolean firstTime = true;
      //  boolean shouldCount = false;
      //  for (MidiNote n : midiScore)
      //  {
      //    if (n.note == i)
      //    {
      //      if (!firstTime)
      //      {
      //        if (beatCounter > 0.0)
      //        {
      //          if (beatCounter < shortestDuration)
      //          {
      //            shortestDuration = n.beats;
      //          }
      //        }
      //        beatCounter = 0.0;
      //      } else if (shouldCount)
      //      {
      //        if (beatCounter > 0.0)
      //        {
      //          shortestDuration = beatCounter;
      //          firstTime = false;
      //        }
      //        beatCounter = 0.0;
      //      } else
      //      {
      //        shouldCount = true;
      //      }
      //    }
      //    if (shouldCount)
      //    {
      //      beatCounter += n.beats;
      //    }
      //  }
    }
    shortestDuration = (shortestDuration < minRepeatDur) ? minRepeatDur : shortestDuration;
    println("Shortest Successive Beats: ", shortestDuration);
    return shortestDuration;
  }
  //---------------------------------------------------------------------------
  void getShortestRhythm()
  {
    //float prevBeatDur = 0;
    //for (MidiNote n : midiScore)
    //{
    //  if (n.beats > 0.0)
    //  {
    //    if (n.beats < shortestDuration)
    //    {
    //      shortestDuration = n.beats;
    //    }
    //  }
    //}
    //println("shortest Duration: ", shortestDuration);
  }
  //---------------------------------------------------------------------------
  void normaliseRhythm()
  {
    //float shortestRhythm = getShortestSuccessiveRhythm();
    //float beatNormalise = minRepeatDur/shortestDuration;
    //for (int i = 0; i < midiScore.size(); i++)
    //{
    //  MidiNote n = midiScore.get(i);
    //  n.beats *= beatNormalise;
    //  midiScore.set(i, n);
    //}
  }
  //---------------------------------------------------------------------------
  int wrapNote(int note)
  {
    if (note < minNote)
    {
      return wrapNote(note + 12);
    } else if (note > maxNote)
    {
      return wrapNote(note - 12);
    }
    return note;
  }
  //---------------------------------------------------------------------------
  void addToScore(MusicBoxNote note)
  {
    //score.add();
  }
  //---------------------------------------------------------------------------
  int deltaToPixels()
  {
    return 0;
  }
  //---------------------------------------------------------------------------
  void midiToMusicBox()
  {
    missedNotes = 0;
    ellipseMode(CENTER);

    for (ArrayList<MidiNote> t : midiScore)
    {
      writeHeadX = xWriteOffset;
      for (MidiNote n : t)
      {
        int ypos = noteToYpos(n.note + transpose, scaling);
        if (ypos != -1 )
        {
          if (n.velocity != 0)
          {
            int xpos = writeHeadX;
            int rad =  int(noteRadius * scaling);
            ellipse(xpos, ypos, rad, rad);
          }
        } else
        {
          missedNotes++;
        }
        writeHeadX += pixelsPerBeat * (n.beats * rhythmSqueeze);
      }
    }
  }
  //---------------------------------------------------------------------------
  int noteToYpos(int note, float scale)
  {
    int j = findNote(note);
    if (j == -1)
    {
      return -1;
    }
    int i = midiKeys.length - j - 1;
    return int((margin + ((float)i * keySpacing)) * scale);
  }
  //---------------------------------------------------------------------------
  int findNote(int note)
  {
    int testNote = wrapNote(note);
    for (int i = 0; i < midiKeys.length; i++)
      if (testNote == midiKeys[i])
        return i;

    return -1;
  }
  //---------------------------------------------------------------------------
  void draw()
  {
    background(50);
    textSize(18);
    textAlign(CENTER, CENTER);
    stroke(255);
    fill(255);
    for (int i = 0; i < midiKeys.length; i++)
    {
      int ypos = int(scaling * ((float(i) * keySpacing) + margin));
      line(xWriteOffset, ypos, width, ypos);
      text(noteList.get(midiKeys.length - 1 - i), xWriteOffset/2, ypos - 2);
    }

    int typos = int(scaling*margin);
    int bypos = int(scaling * ((float(midiKeys.length-1) * keySpacing) + margin));
    for (int i = 0; i < width/pixelsPerBeat; ++i)
    {
      int xpos = int(float(i) * pixelsPerBeat) + xWriteOffset;
      line(xpos, typos, xpos, bypos);
    }

    midiToMusicBox();
    textAlign(LEFT, CENTER);
    text("Missed Notes: " + str(missedNotes), 10, 10);

    text("Squeeze: " + str(rhythmSqueeze), 200, 10);
  }
  //---------------------------------------------------------------------------
  void drawToSvg(String filename)
  {
    //noFill();
    //stroke(0.01);
    //beginRecord(SVG, filename + ".svg");
    //midiToMusicBox();
    //rect(0, 0, 6000, height);
    //endRecord();
    midiToMusicBoxSvg(filename);
  }

  void midiToMusicBoxSvg(String filename)
  {
    svg = createGraphics(int(980 * svg_scale), int(69.7 * svg_scale), SVG, filename + ".svg");
    ellipseMode(CENTER);
    svg.beginDraw();
    svg.noFill();
    svg.stroke(0.0001);

    for (ArrayList<MidiNote> t : midiScore)
    {
      writeHeadX = int(10*svg_scale);
      for (MidiNote n : t)
      {
        int ypos = noteToYpos(n.note + transpose, svg_scale);
        if (ypos != -1 )
        {
          if (n.velocity != 0)
          {
            int xpos = writeHeadX;
            int rad =  int(noteRadius * svg_scale);
            svg.ellipse(xpos, ypos, rad, rad);
          }
        } else
        {
          missedNotes++;
        }
        writeHeadX += pixelsSvgPerBeat * (n.beats * rhythmSqueeze);
        if(writeHeadX > svg.width)
        {
          break;
        }
      }
    }
    svg.rect(0, 0, svg.width, svg.height);
    svg.dispose();
    svg.endDraw();
  }
  //---------------------------------------------------------------------------
  void setTranspose(int t)
  {
    transpose = t;
  }
}

class MusicBoxNote
{
  int x;
  int y;
  int w;
  int h;
}
