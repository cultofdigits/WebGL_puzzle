part of puzzle;


class TextureMask{
  Img.Image image;
  int left, top, right, bottom;
  ImageElement imgElement;
  Puzzle puzzle;
  
  final int TEXCOLOR = Img.getColor(255, 255, 255);
  final int TRANSPARENT_COLOR = Img.getColor(0, 0, 0);
  
  void fillRange(Img.Image image, int x, int y, int color){
    image.setPixel(x, y, color);
    if (image.getPixel(x+1, y  ) != color) fillRange(image, x+1, y  ,color);
    if (image.getPixel(x-1, y  ) != color) fillRange(image, x-1, y  ,color);
    if (image.getPixel(x  , y+1) != color) fillRange(image, x  , y+1,color);
    if (image.getPixel(x  , y-1) != color) fillRange(image, x  , y-1,color);    
  }
  
  void drawFillCircle(x, y, color){
    Img.drawCircle(this.image, x, y, CIRCLE_SIZE, color);
    fillRange(this.image, x, y, color);
  }
  
  void createEdge(int x, y, type){
    if (type == 0)
      return;
 
    drawFillCircle(x, y, TRANSPARENT_COLOR);
    if (type ==1)
      drawFillCircle(x, y, TEXCOLOR);
    
  }
  
  puzzleTex(int x, y, PuzzleElement e){
    int offset = (MASK_SIZE - SQUARE_SIZE) ~/ 2;
    int xOffset = x*MASK_SIZE+MASK_OFFSET*e.x;
    int yOffset = y*MASK_SIZE+MASK_OFFSET*e.y;
    Img.fillRect(this.image, 
        xOffset + offset, 
        yOffset + offset, 
        xOffset + MASK_SIZE-offset, 
        yOffset + MASK_SIZE-offset, 
        TEXCOLOR);

    int xCenter = xOffset + (MASK_SIZE ~/ 2);
    int yCenter = yOffset + (MASK_SIZE ~/ 2);
    createEdge(xOffset + CIRCLE_SIZE, yCenter, e.left);
    createEdge(xCenter              , yOffset+CIRCLE_SIZE,  e.top);
    createEdge(xOffset + MASK_SIZE - CIRCLE_SIZE-1, yCenter, e.right);
    createEdge(xCenter              , yOffset + MASK_SIZE - CIRCLE_SIZE-1, e.bottom);
  }
  
  TextureMask(this.puzzle){
    this.image = new Img.Image(TEXTURE_MASK_SIZE, TEXTURE_MASK_SIZE );
    Img.fill(image, TRANSPARENT_COLOR);
    
    for(int y =0; y < puzzle.sizey; y++ )
      for(int x =0; x < puzzle.sizex; x++ ){
        puzzleTex(x, y, puzzle.elements[y][x]);
      }
    
    this.createImage();
  }
  
  void createImage(){
    var png = Img.encodePng(image);
    var png64 = CryptoUtils.bytesToBase64(png);
    imgElement = new ImageElement();
    imgElement.src = 'data:image/png;base64,${png64}';
  }
}