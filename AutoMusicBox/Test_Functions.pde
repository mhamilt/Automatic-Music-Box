ArrayList<ArrayList<MidiNote>> makeTestMidiTracks()
{
  int[] midiKeys =    {48, 50, 55, 57, 59, 60, 62, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 86, 88};
  ArrayList<ArrayList<MidiNote>> midiTracks;
  ArrayList<MidiNote> tempScore;
  ArrayList<MidiNote> bigChord;
  bigChord = new ArrayList<MidiNote>();
  for (int i : midiKeys)
  {
    bigChord.add(new MidiNote(i, 64, (i==88)?1.0f:0.0f));
  }
  tempScore = new ArrayList<MidiNote>();
  tempScore.addAll(bigChord);
  for (int i : midiKeys)
  {
    tempScore.add(new MidiNote(i, 64, 1.0f));
  }
  tempScore.addAll(tempScore);
  midiTracks = new ArrayList<ArrayList<MidiNote>>();
  midiTracks.add(new ArrayList<MidiNote>());
  midiTracks.get(0).addAll(tempScore);  
  return midiTracks;
}
