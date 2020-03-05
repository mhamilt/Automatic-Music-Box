class MidiNote 
{
  int channel;
  int note;
  int velocity;
  int delta_time;  
  float beats;
  
  MidiNote(int c, int n, int v, int t) 
  {
    channel = c;
    note = n;
    velocity = v;
    delta_time = t;    
  }

  MidiNote(int n, int v, float b) 
  {    
    note = n;
    velocity = v;
    beats = b;
  }
  void update() 
  {
  }
}
