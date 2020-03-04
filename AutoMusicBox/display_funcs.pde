void getDisplayDim(float screenDiameter)
{
  float c =  (float)sqrt((displayWidth*displayWidth) + (displayHeight*displayHeight));
  float scale = (c)/screenDiameter;
  println(scale);
  println("display size (mm):", displayWidth/scale, "x", displayHeight/scale);
}
