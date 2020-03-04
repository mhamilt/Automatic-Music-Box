// Midi Header format http://www.personal.kent.edu/~sbirch/Music_Production/MP-II/MIDI/midi_file_format.htm
//http://dogsbodynet.com/fileformats/midi.html#RUNSTATUS

import java.util.Arrays;
import java.nio.*;
//---------------------------------------------------------------------------------------------------------
class MidiChunk extends ByteReader
{
  //---------------------------------------------------------------------------
  String type;
  int length;
  byte[] chunkData;  
  MidiEventParse event;    
  //---------------------------------------------------------------------------
  MidiChunk()
  {
    event = new MidiEventParse();
  }
  //---------------------------------------------------------------------------
  void printChunk()
  {
    println(type + "\t" + str(length));
    for (int i = 0; i < length; i++)
    {
      print(hex(data[i]));
      if ((i % 4) == 0)
      {
        print(" ");
      }
    }
    println();
    println("============================================================");
  }
  //---------------------------------------------------------------------------
  void parseEvents()
  {
    event.setEvent(chunkData);
  }
  //---------------------------------------------------------------------------
  ArrayList<MidiNote> parseEventsForNotes()
  {
    event.setEvent(chunkData);
    return event.midiNotes;
  }
}

//---------------------------------------------------------------------------------------------------------

class MidiEventParse extends ByteReader
{
  //---------------------------------------------------------------------------
  byte type;
  int deltaTime;  
  int length;
  int tempo = 500000;
  ArrayList<MidiNote> midiNotes;  
  boolean runningStatus = false;
  byte currentEventType;
  //---------------------------------------------------------------------------
  MidiEventParse()
  {
    midiNotes = new ArrayList<MidiNote>();
  }
  //---------------------------------------------------------------------------
  void setEvent(byte[] eventData)
  {
    data = eventData;        
    while (curByteIndex < data.length)
    {          
      if (!runningStatus)
      {
        deltaTime = getVarLength(false);            
        currentEventType = readBytes(1)[0]; 
        parseEventType(currentEventType);
      } else
      {         
        parseMidiRunning(currentEventType);
      }
    }
  }
  //---------------------------------------------------------------------------
  void parseEventType(byte event_type)
  {            
    int et = event_type & 0xff;    
    if (et == 0xF0 || et ==  0xF7)
    {      
      parseSysEx();
    } else if (et == 0xff)
    {     
      parseMeta();
    } else if (et >= 0x80)
    {            
      parseMidi(event_type);
    } else
    {
      print("Unknown: ");
      print(hex(event_type));
      printUntilNextEvent();
      println();
    }
  }
  //---------------------------------------------------------------------------

  void parseMidiRunning(byte eventType)
  {
    byte eventByte = eventType;
    while (runningStatus)
    {      
      if ((eventByte & 0xff) == 0xFF)
      {
        curByteIndex-=2;
        runningStatus = false;
        println("end Running");
        break;
      }

      int channel = eventByte & 0xf;
      int dataSize = 2;
      byte[] notes;
      switch((eventByte >> 4) & 0xF)
      {      
      case 0x9://"Note on");       
        notes = readRunningStatus(dataSize);        
        try
        {
          for (int i = 0; i < notes.length; i+=3)
          {           
            int midi_note = notes[i+1];
            int velocity = notes[i+2];
            int delta = notes[i];
            runningDelta += delta;
            midiNotes.add(new MidiNote(channel, midi_note, velocity, delta, runningDelta));
            //println("Channel: " + str(channel) + " note: " + str(midi_note) + " velocity: " + str(velocity) + " time: " + str(delta) +  " ");
          }
        }
        catch(Exception e) 
        {
          printByteArray(notes);
          throw e;
        }
      case 0x8://"Note off");   
        notes = readRunningStatus(dataSize);        
        try
        {
          for (int i = 0; i < notes.length; i+=3)
          {           
            int midi_note = notes[i+1];
            int velocity = 0;
            int delta = notes[i];
            runningDelta += delta;
            midiNotes.add(new MidiNote(channel, midi_note, velocity, delta, runningDelta));
            //println("Channel: " + str(channel) + " note: " + str(midi_note) + " velocity: " + str(velocity) + " time: " + str(delta) +  " ");
          }
        }
        catch(Exception e) 
        {
          printByteArray(notes);
          //throw e;
        }
      case 0xA://"Polyphonic Key Pressure");
      case 0xB://"Control Change");
      case 0xE://"Pitch Bend");
        readRunningStatus(dataSize);
        break;
      case 0xC://"Program Change");
      case 0xD://"Channel Key Pressure");
        dataSize = 1;
        readRunningStatus(dataSize);
      }
      eventByte = readBytes(1)[0];
    }
  }
  void parseMidi(byte event_type)
  {    
    int channel = event_type & 0xf;
    int dataSize = 2;
    byte[] notes;
    switch((event_type >> 4) & 0xF)
    {         

    case 0x9:// Note on                 
      if (isInRunningStatus(dataSize))
      {
        runningStatus = true;
        print(" in running status mode! ");
      }
      notes =  readBytes(dataSize);      
      runningDelta += deltaTime;
      midiNotes.add(new MidiNote(channel, notes[0], notes[1], deltaTime, runningDelta));
      break; 
    case 0x8:// Note off
      if (isInRunningStatus(dataSize))
      {
        runningStatus = true;
        print(" in running status mode! ");
      }      
      notes =  readBytes(dataSize);      
      runningDelta += deltaTime;
      midiNotes.add(new MidiNote(channel, notes[0], 0, deltaTime, runningDelta));
      break;
    default:      
      switch((event_type >> 4) & 0xF)
      {
      case 0xC:// Program Change            
      case 0xD:// Channel Key Pressure
        dataSize = 1;
        break;
      }

      if (isInRunningStatus(dataSize))
      {
        runningStatus = true;
        print(" in running status mode! ");
      } else
      {
        readBytes(dataSize);
      }
      break;
    }
  }
  //---------------------------------------------------------------------------
  void parseSysEx()
  {    
    length = getVarLength(false);
    readBytes(length);
  }
  //---------------------------------------------------------------------------
  void parseMeta()
  {
    type = readBytes(1)[0];    
    length = getVarLength(false);  

    switch(type & 0xFF)
    {
    case 0x01: // Free Text
    case 0x02: // Copyright
    case 0x03: // Track Name
    case 0x04: // Instrument
    case 0x05: // Lyric Text
    case 0x06: // Marker
    case 0x07: // Cue Text
    case 0x09: // Device Name
    case 0x7F: // Sequencer-Specific Meta-event
      println(new String(readBytes(length)));
      break;
    case 0x51: // Set Tempo: microseconds per quarter note.
      curByteIndex--;
      tempo = (ByteBuffer.wrap(readBytes(4)).getInt() & 0xFFFFFF);            
      break;
    case 0x00: // sequence number
    case 0x20: // Channel Prefix
    case 0x2F: // End of Track
    case 0x54: // SMTPE Offset
    case 0x58: // Time sig
    case 0x59: // key sig
    default:      
      readBytes(length);
      break;
    }
  }
  //---------------------------------------------------------------------------
  void printEvent()
  {
    for (int i = 0; i < data.length; i++)
    {
      print(hex(data[i]));
    }
  }
  //---------------------------------------------------------------------------
  void printMidiEventType(int eventByte)
  {
    switch((eventByte >> 4) & 0xF)
    {
    case 0x8:
      print("Note off");
      break;
    case 0x9:
      print("Note on");
      break;
    case 0xA:
      print("Polyphonic Key Pressure");
      break;
    case 0xB:
      print("Control Change");
      break;
    case 0xC:
      print("Program Change");
      break;
    case 0xD:
      print("Channel Key Pressure");
      break;
    case 0xE:
      print("Pitch Bend");
      break;
    }
  }
  //---------------------------------------------------------------------------
  void printUntilNextEvent()
  {
    while (true)
    {       
      try
      {
        byte midiByte = readBytes(1)[0];
        if ((midiByte & 0xff) >= 0x80)
        {
          curByteIndex-=2;
          break;
        }
        print(hex(midiByte));
      }
      catch(Exception e) 
      {
        println("ERROR: EOF");
        break;
      }
    }
  }
  //---------------------------------------------------------------------------
  void printMetaEventType(int eventByte)
  {
    switch(eventByte)
    {
    case 0x00:
      print("sequence number");
      break;
    case 0x01:
      print("Free Text");
      break;
    case 0x02:
      print("Copyright");
      break;
    case 0x03:
      print("Track Name");
      break;
    case 0x04:
      print("Instrument");
      break;
    case 0x05:
      print("Lyric Text");
      break;
    case 0x06:
      print("Marker");
      break;
    case 0x07:
      print("Cue Text");
      break;
    case 0x09:
      print("Device Name");
      break;
    case 0x20:
      print("Channel Prefix");
      break;
    case 0x2F:
      print("End of Track");
      break;
    case 0x51:
      print("Set Tempo");
      break;
    case 0x54:
      print("SMTPE Offset");
      break;
    case 0x58:
      print("Time sig");
      break;
    case 0x59:
      print("key sig");
      break;
    case 0x7F:
      print("Sequencer-Specific Meta-event");
      break;
    }
  }
  //---------------------------------------------------------------------------
  void readUntilNextEvent()
  {
    while (true)
    {       
      byte newByte = readBytes(1)[0];
      if ((newByte & 0xff) >= 0x80)
      {
        curByteIndex--;
        break;
      } else if ((newByte & 0xff) == 0x00)
      {
        break;
      }
    }
  }
  //---------------------------------------------------------------------------
  MidiNote getLastMidiNote()
  {
    return midiNotes.get(midiNotes.size()-1);
  }

  void replaceLastMidiNote(MidiNote newNote)
  {
    midiNotes.remove(midiNotes.size()-1);
    midiNotes.add(newNote);
  }
}

//---------------------------------------------------------------------------------------------------------

class MidiHeader extends MidiChunk
{
  String chunk_type;
  int length;
  int format;
  int ntrks;
  int division;
  //---------------------------------------------------------------------------
  void printHeader()
  {
    println("============================================================");
    println("Chunk Type: " + chunk_type + "\tLength: " + str(length) + "\tFormat: " + str(format) + "\tNtrks: " + str(ntrks) + "\tDivision: " + str(division));
    println("============================================================");
  }
  //---------------------------------------------------------------------------
  void setHeader(byte[] byteData)
  {
    setData(byteData); 
    chunk_type = new String(readBytes(4));    
    length = ByteBuffer.wrap(readBytes(4)).getInt();    
    format = ByteBuffer.wrap(readBytes(2)).getShort();
    ntrks = ByteBuffer.wrap(readBytes(2)).getShort();
    division = ByteBuffer.wrap(readBytes(2)).getShort();
    printHeader();
  }
}

//---------------------------------------------------------------------------------------------------------

class MidiFile extends ByteReader
{
  //---------------------------------------------------------------------------
  MidiHeader header;
  ArrayList<MidiNote> allNotes;
  ArrayList<ArrayList<MidiNote>> tracks;
  //---------------------------------------------------------------------------
  MidiFile()
  {
    allNotes = new ArrayList<MidiNote>();
    header = new MidiHeader();
  }
  //---------------------------------------------------------------------------
  void loadFile(String filepath)
  {
    curByteIndex = 0;
    data = loadBytes(filepath + ".mid");    
    header.setHeader(readBytes(14));
    tracks = new ArrayList<ArrayList<MidiNote>>();
    for (int i = 0; i < header.ntrks; ++i)//header.ntrks
    {
      tracks.add(new ArrayList<MidiNote>());
    }
    print("finished file load\n");
  }
  //---------------------------------------------------------------------------
  void addToScore(ArrayList<MidiNote> newNotes)
  {
  }

  //---------------------------------------------------------------------------
  ArrayList<ArrayList<MidiNote>> getAllNotes()
  {

    for (int i = 0; i < header.ntrks; ++i)//header.ntrks
    {
      tracks.get(i).addAll(readChunk().parseEventsForNotes());
    }
    //for (int i = 0; i < 2; ++i)//header.ntrks
    //{
    //  allNotes.addAll(readChunk().parseEventsForNotes());
    //}    
    //quantize(0.0125);
    setBeats();
    return tracks;
  }
  //---------------------------------------------------------------------------
  MidiChunk readChunk()
  {
    MidiChunk chunk = new MidiChunk();    
    chunk.type =  new String(readBytes(4));    
    chunk.length =  ByteBuffer.wrap(readBytes(4)).getInt();
    chunk.chunkData = readBytes(chunk.length);
    return chunk;
  }
  //---------------------------------------------------------------------------
  void printCurrentLocation()
  {
    print("Current Position: " + str(curByteIndex) + "\t");
    println("Data Length: " + data.length);
  }
  //---------------------------------------------------------------------------
  void writeToFile(ArrayList<MidiNote> noteArray)
  {
  }
  //---------------------------------------------------------------------------
  void quantize(float quantizeDuration)
  {
    quantizeDuration *= 4.0;
    for (int i = 0; i < allNotes.size(); i++)
    {
      MidiNote n = allNotes.get(i);
      n.beats = round(float(n.delta_time) / (float(header.division) * quantizeDuration)) * quantizeDuration;     
      allNotes.set(i, n);
    }
  }

  void setBeats()
  {    
    for (ArrayList<MidiNote> t : tracks)
    {
      for (MidiNote n : t)
      {
        n.beats = float(n.delta_time) / float(header.division);
      }
    }
    //for (int i = 0; i < allNotes.size(); i++)
    //{
    //  MidiNote n = allNotes.get(i);
    //  n.beats = float(n.delta_time) / float(header.division);     
    //  allNotes.set(i, n);
    //}
  }
  //---------------------------------------------------------------------------
}
//---------------------------------------------------------------------------------------------------------
