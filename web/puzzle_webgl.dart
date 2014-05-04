part of puzzle;
final int PUZZLE_SIZE = 100;
final int TEXTURE_MASK_SIZE = 2048;
final int MASK_SIZE = 99;
final int SQUARE_SIZE = 69;
final int CIRCLE_SIZE = 14;
final int MASK_OFFSET = 1;


class WebGLPuzzle{
  CanvasElement canvas;
  WebGL.RenderingContext gl;
  Window canvasWindow;
  Shader quadShader;
  Puzzle puzzle;
  WebGL.Texture texture, textureMask;
  int moveSartX, moveSartY, elemenMoveX, elemenMoveY;
  double elementMoveAngle;
  bool isRotate, isMove;
  int currentElement;
  
  List<int> move = new List<int>();
  
  Matrix4 cameraMatrix = new Matrix4.identity();
  List<WebGLPuzzleElement> quads= new List<WebGLPuzzleElement>();
  WebGL.Framebuffer framebuffer;
  
  void createQuadArray(){
    for(int y =0; y < puzzle.sizey; y++ )
      for(int x =0; x < puzzle.sizex; x++ ){
        WebGLPuzzleElement q = new WebGLPuzzleElement(gl, quadShader, puzzle.elements[y][x], texture, textureMask);
        int tx = new Math.Random().nextInt(canvas.width  - (PUZZLE_SIZE*1.5).floor() );
        int ty = new Math.Random().nextInt(canvas.height - (PUZZLE_SIZE*1.5).floor() );
        q.setCoordinates(tx, ty);
        q.setAngle(new Math.Random().nextDouble()*360);
        quads.add(q);
      }    
  }
  
  WebGLPuzzle(this.puzzle , this.canvas, this.canvasWindow){
    isRotate = false;
    isMove = false;

    gl = canvas.getContext('webgl');
    if (gl == null)
      gl = canvas.getContext("experimental-webgl");
    quadShader = new Shader(this.gl);   
    
    gl.pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 1);
    gl.enable(WebGL.BLEND);
    gl.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
    
    
    loadTextures();
    createFrameBuffer();
    setCamera();
    createQuadArray();
    this.canvas.onMouseDown.listen(onDown);
    this.canvas.onMouseMove.listen(onMove);
    this.canvas.onMouseUp.listen(onUp);
    this.canvas.onContextMenu.listen((MouseEvent e) => e.preventDefault());
    canvasWindow.requestAnimationFrame(render);
  }
  
  void render(double time){
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0.1, 0.1, 0.1, 1.0);
    gl.clear(WebGL.COLOR_BUFFER_BIT);
    
    for(int i=0; i<quads.length; i++){
      quads[i].setUniqueColor(false);
      quads[i].setCurrent(i == this.currentElement);
      quads[i].render();
    };    
    
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, framebuffer);
    gl.clearColor(0.0, 0.0, 0.0, 0.0);
    gl.clear(WebGL.COLOR_BUFFER_BIT);
    for(int i=0; i<quads.length; i++){
      quads[i].setUniqueColor(true);
      quads[i].render();
    };
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, null);
    canvasWindow.requestAnimationFrame(render);
    
    
  }
  
  void setCamera(){
    cameraMatrix.setIdentity();
    cameraMatrix.translate(-1.0, -1.0);
    cameraMatrix.scale(2.0/ canvas.width, 2.0 / canvas.height);
    gl.uniformMatrix4fv(gl.getUniformLocation(quadShader.program, "uCameraMatrix"), false, cameraMatrix.storage);
  }
  
  int getCurrentElement(int x, y){
    Uint8List pixels = new Uint8List(4);
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, framebuffer);
    gl.readPixels(x, y, 1, 1, WebGL.RGBA, WebGL.UNSIGNED_BYTE, pixels);
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, null);
    
    if (pixels[3] == 255)
      return (pixels[0]/(255/PUZZLE_COUNT)).round()+((pixels[1]/(255/PUZZLE_COUNT)).round()*PUZZLE_COUNT);
    else
      return -1;
  }
  
  void onUp(e){
    if (isMove){
      this.move.forEach((c){
        Quad current = quads[c];
        double delta = PUZZLE_SIZE*7/100;
        double cy = current.y + PUZZLE_SIZE/2;
        double puzzleSize = (SQUARE_SIZE+1)*PUZZLE_SIZE/MASK_SIZE;
        [1, -1].forEach((i){
          if(c+i >= 0 && c+i<quads.length){
            var tmpx = (quads[c+i].x - current.x).abs() - puzzleSize;
            if ( (tmpx).abs() < delta && (quads[c+i].y - current.y).abs() < delta){
              current.x = quads[c+i].x - puzzleSize*i~/1 ;
              current.y = quads[c+i].y;
            }
          }
          int y = c+(i* PUZZLE_COUNT);
          if( y >= 0 && y<quads.length){
            var tmpy = (quads[y].y - current.y).abs() - puzzleSize;
            if ( (tmpy).abs() < delta && (quads[y].x - current.x).abs() < delta){
              current.y = quads[y].y + puzzleSize*i~/1 ;
              current.x = quads[y].x;
            }
          }
        });
      });
      this.move.clear();
      isMove = false;
    }
    if (isRotate){
      this.move.clear();
      isRotate = false;
    }      
  }  
  
  void onDown(e){
    moveSartX = e.client.x - canvas.offsetLeft;
    moveSartY = canvas.height - e.client.y + canvas.offsetTop;
    var index = getCurrentElement(moveSartX, moveSartY);
    if (index >= 0)
    {
      switch (e.button){
        case 0:
          isMove = true;
          this.move.clear();
          this.move.add(index);
          elemenMoveX = quads[index].x;
          elemenMoveY = quads[index].y;
          break;
        case 2:
          this.move.clear();
          this.move.add(index);
          elemenMoveX = quads[index].x;
          elemenMoveY = quads[index].y;
          elementMoveAngle = quads[index].angle;
          isRotate = true;
      }
    }
  }

  
  void onMove(e){
    int index = getCurrentElement(e.client.x - canvas.offsetLeft, canvas.height - e.client.y + canvas.offsetTop);
    if (index >=0)
      this.currentElement = index;
    else
      this.currentElement = -1;
    
    if (!isMove&&!isRotate)
      return;
    int x = this.moveSartX - e.client.x + canvas.offsetLeft;
    int y = this.moveSartY - (canvas.height - e.client.y + canvas.offsetTop);
    if (isMove){
      isRotate = false;
      this.move.forEach((i){
        this.quads[i].x = elemenMoveX - x;
        this.quads[i].y = elemenMoveY - y;
      });
    }
    if (isRotate){
      isMove = false;
      this.move.forEach((i){
        double angle = (elementMoveAngle - (y -x)/2) % 360;
        [0.0,90.0,180.0,270.0].forEach((a){
          if ((a - angle).abs() < 5.0) angle = a;
        });
        this.quads[i].angle = angle;
      });
    }
  }  
  
  void loadTextures(){
    this.texture = gl.createTexture();
    gl.bindTexture(WebGL.TEXTURE_2D, this.texture);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
    gl.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, querySelector('#texture'));
    gl.uniform1i(gl.getUniformLocation(quadShader.program, 'uSampler'), 0);

    this.textureMask = gl.createTexture();
    gl.bindTexture(WebGL.TEXTURE_2D, this.textureMask);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.LINEAR);
    gl.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, puzzle.mask.imgElement);
    gl.uniform1i(gl.getUniformLocation(quadShader.program, 'uPuzzleMask'), 1);
  }
  
  void createFrameBuffer(){
    framebuffer = gl.createFramebuffer();
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, framebuffer);    
    
    var rttTexture = gl.createTexture();
    gl.bindTexture(WebGL.TEXTURE_2D, rttTexture);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MAG_FILTER, WebGL.NEAREST);
    gl.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.NEAREST);
    gl.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, canvas.width, canvas.height, 0, WebGL.RGBA, WebGL.UNSIGNED_BYTE, null);

    var renderbuffer = gl.createRenderbuffer();
    gl.bindRenderbuffer(WebGL.RENDERBUFFER, renderbuffer);
    gl.renderbufferStorage(WebGL.RENDERBUFFER, WebGL.DEPTH_COMPONENT16, canvas.width, canvas.height);

    gl.framebufferTexture2D(WebGL.FRAMEBUFFER, WebGL.COLOR_ATTACHMENT0, WebGL.TEXTURE_2D, rttTexture, 0);
    gl.framebufferRenderbuffer(WebGL.FRAMEBUFFER, WebGL.DEPTH_ATTACHMENT, WebGL.RENDERBUFFER, renderbuffer);

    gl.bindTexture(WebGL.TEXTURE_2D, null);
    gl.bindRenderbuffer(WebGL.RENDERBUFFER, null);
    gl.bindFramebuffer(WebGL.FRAMEBUFFER, null);        
  }
}