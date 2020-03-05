class ByteReader
{
  int curByteIndex;
  byte[] data;

  void setData(byte[] byteData)
  {
    data = byteData;
  }

  byte[] readBytes(int numBytes)
  {
    curByteIndex += numBytes;
    try 
    {
      return Arrays.copyOfRange(data, curByteIndex - numBytes, curByteIndex);
    }
    catch(Exception e) 
    {      
      print("OVERFLOW!!!");
      curByteIndex -= 20;
      printBytes(20);
      throw e;
      //return null;
    }
  }

  void printBytes(int numBytes)
  {
    byte[] printBytes = readBytes(numBytes);
    for (int i = 0; i < printBytes.length; i++)
    {
      print(hex(printBytes[i]));
    }
  }

  void readUntil(byte testValue)
  {     
    byte currentValue = readBytes(1)[0];    
    while (currentValue != testValue)
    {
      currentValue = readBytes(1)[0];
    }
  }

  int getVarLength(boolean printOut)
  {   
    ArrayList<Byte> varLength = new ArrayList<Byte>();
    while (true)
    {
      byte newByte = readBytes(1)[0]; 
      varLength.add(newByte);
      if (printOut)
      {
        print(hex(newByte));
      }
      if ((newByte & 0xff) < 0x80)
      {
        break;
      }
    }

    varLength.size();

    int var = 0; 

    for (int i = 0; i < varLength.size(); i++)
    {
      int j = (varLength.size() - 1) - i;
      var  |= (varLength.get(j) & 0x7F) << (i * 7);
    }

    return var;
  }

  boolean isInRunningStatus(int dataSize)
  {
    int numBytes = 0;
    byte nextByte = 0;
    while (true)
    { 
      nextByte = readBytes(1)[0];
      if ((nextByte & 0xff) >= 0x80)
      {    
        curByteIndex -= (numBytes + 1);
        return (numBytes > (dataSize + 1));
      }     
      numBytes++;
    }
  }

  byte[] readRunningStatus(int dataSize)
  {      
    int blockSize = dataSize + 1;
    int numBytes = 0;
    byte nextByte = 0;
    int byteCounter = 0;
    while (true)
    {     
      nextByte = readBytes(1)[0];
      byteCounter++;
      if ((nextByte & 0xff) > 0x7F)
      {                   
        curByteIndex--;
        //curByteIndex -= byteCounter;
        //numBytes--;
        break;
      }
      numBytes++;
    }         
    println("read bytes: " + str(numBytes));
    return Arrays.copyOfRange(data, curByteIndex-numBytes, curByteIndex);
  }

  void printByteArray(byte[] bytearray)
  {
    for (int i = 0; i < bytearray.length; i++)
    {
      print(hex(bytearray[i]));
    }
  }
}
