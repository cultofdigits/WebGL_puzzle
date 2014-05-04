part of puzzle;

class WebGLPuzzleElement extends Quad{
  WebGL.Texture texture, textureMask;
  WebGL.UniformLocation uTexMatrix, uTexMaskMatrix;
  WebGL.UniformLocation isVisibleRender, u_uniqueColor, uCurrent;
  
  Matrix4 texMatrix, texMaskMatrix;
  
  PuzzleElement element;
    
  WebGLPuzzleElement._internal (gl, shader, x, y, w, h, angle, color, this.element, this.texture, this.textureMask): super(gl, shader, x, y, w, h, angle, color){
    texMatrix = new Matrix4.identity();
    texMaskMatrix = new Matrix4.identity();

    uTexMatrix      = gl.getUniformLocation(shader.program, 'uTexMatrix');
    uTexMaskMatrix  = gl.getUniformLocation(shader.program, 'uTexMaskMatrix');
    isVisibleRender = gl.getUniformLocation(shader.program, 'isVisibleRender');
    uCurrent        = gl.getUniformLocation(shader.program, 'uCurrent');

    setTexture();
  }
  factory WebGLPuzzleElement (WebGL.RenderingContext gl, Shader shader, PuzzleElement element, texture, textureMask) {
    final e = new WebGLPuzzleElement._internal(gl, shader,
        PUZZLE_SIZE*element.x, 500-PUZZLE_SIZE*element.y,
        PUZZLE_SIZE, PUZZLE_SIZE, 
        0.0,
        new Vector4(element.x/PUZZLE_COUNT, element.y/PUZZLE_COUNT, 0.0,1.0), element, texture, textureMask);
    return e;
  }
  
  void render(){
       gl.uniformMatrix4fv(uTexMatrix    , false, texMatrix.storage);
       gl.uniformMatrix4fv(uTexMaskMatrix, false, texMaskMatrix.storage);
       super.render();
  }
  
  setTexture(){
    int aVertexTextureCoords = gl.getAttribLocation(shader.program, 'aVertexTextureCoords');
    gl.enableVertexAttribArray(aVertexTextureCoords);
    gl.vertexAttribPointer(aVertexTextureCoords, 3, WebGL.RenderingContext.FLOAT, false, 0, 0);
    
    gl.activeTexture(WebGL.TEXTURE0);
    gl.bindTexture(WebGL.TEXTURE_2D, this.texture);
    gl.activeTexture(WebGL.TEXTURE1);
    gl.bindTexture(WebGL.TEXTURE_2D, this.textureMask);    
    
    double SCALE = (1 / PUZZLE_COUNT);
    double edge = CIRCLE_SIZE * SCALE / SQUARE_SIZE;
    
    texMatrix.setIdentity();
    texMatrix.translate( SCALE*element.x - edge,  SCALE*(PUZZLE_COUNT-1-element.y) - edge);
    texMatrix.scale(SCALE + edge*2, SCALE + edge*2);
    
    texMaskMatrix.setIdentity();
    texMaskMatrix.scale(1.0/TEXTURE_MASK_SIZE, 1.0/TEXTURE_MASK_SIZE);
    texMaskMatrix.translate(1.0*(element.x * MASK_SIZE)+MASK_OFFSET*element.x, 
                            1.0* TEXTURE_MASK_SIZE-MASK_SIZE-MASK_OFFSET*element.y - (element.y * MASK_SIZE));
    texMaskMatrix.scale(1.0*MASK_SIZE, 1.0*MASK_SIZE);    
  }
  
  void setCurrent(bool iscurrent){
    if (iscurrent)
      gl.uniform1f(uCurrent, 1.0);
    else
      gl.uniform1f(uCurrent, 0.0);
  }

  void setUniqueColor(bool unique){
    if (unique)
      gl.uniform1f(isVisibleRender, 0.0);
    else
      gl.uniform1f(isVisibleRender, 1.0);
  }
  
  void setCoordinates(int x, int y){
    this.x = x;
    this.y = y;
  }
  
  void setAngle(double angle){
    this.angle = angle;
  }
}


class Quad{
  WebGL.RenderingContext gl;
  Shader shader;
  int aPosition;
  WebGL.Buffer vertexBuffer, indexBuffer;
  int x, y, w, h;
  Vector4 color;
  double angle;
  
  Quad(this.gl, this.shader, this.x, this.y, this.w, this.h, this.angle, this.color){
    gl.useProgram(shader.program);

    aPosition       = gl.getAttribLocation(shader.program, 'aPosition');
    vertexBuffer = gl.createBuffer();
    gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    gl.bufferDataTyped(WebGL.ARRAY_BUFFER, new Float32List.fromList([
                                                                     -0.0, -0.0, 0.0,
                                                                      1.0, -0.0, 0.0,
                                                                      1.0, 1.0, 0.0,
                                                                     -0.0, 1.0, 0.0
                                                                     ]), WebGL.STATIC_DRAW);
    gl.vertexAttribPointer(aPosition, 3, WebGL.RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(aPosition);
    
    indexBuffer = gl.createBuffer();
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, new Int16List.fromList([0,1,2,0,2,3]), WebGL.STATIC_DRAW);
  }
    
  render(){
    Matrix4 objectMat = new Matrix4.identity();
    //создаем матрицу вида
    objectMat.setIdentity();
    //передвиним объект на нужное расстояние
    objectMat.translate(1.0*x, 1.0*y );
    
    //повернем прямоугольник на нужный угол
    Matrix4 rotate_tmp = new Matrix4.identity();
    rotate_tmp.translate(w/2, h/2);
    objectMat.multiply(rotate_tmp);
    objectMat.rotateZ(angle * Math.PI / 180.0);
    rotate_tmp.invert();
    objectMat.multiply(rotate_tmp);

    //изменим масштаб, чтобы прямоугольник был нужного размера
    objectMat.scale(1.0*w, 1.0*h);
    //передаем матрицу в шейдер
    gl.uniformMatrix4fv(gl.getUniformLocation(shader.program, "uObjectMatrix"), false, objectMat.storage);

    //Передаем в униформ красный цвет
    gl.uniform4fv(gl.getUniformLocation(shader.program, 'uColor'), color.storage);
    gl.drawElements(WebGL.TRIANGLES, 6, WebGL.UNSIGNED_SHORT, 0);
  }  
}