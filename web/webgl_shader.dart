part of puzzle;

class Shader{
  
  String vertexShaderCode, fragmentShaderCode;
  WebGL.Shader vertexShader, fragmentShader;
  WebGL.Program program;
  WebGL.RenderingContext gl;
  
  
  Shader(this.gl){
    vertexShaderCode = """
            precision highp float;

            uniform mat4 uTexMatrix;
            uniform mat4 uTexMaskMatrix;
            uniform mat4 uCameraMatrix;
            uniform mat4 uObjectMatrix;

            attribute vec3 aPosition;
            attribute vec2 aVertexTextureCoords;
            varying vec2 vTextureCoord;
            varying vec2 vTextureMaskCoord;

            uniform vec4 u_uniqueColor;
            varying vec4 v_uniqueColor;



            void main() 
            {
                v_uniqueColor = u_uniqueColor;

                vTextureCoord     = (uTexMatrix    *vec4(aVertexTextureCoords, 1.0, 1.0)).xy;
                vTextureMaskCoord = (uTexMaskMatrix*vec4(aVertexTextureCoords, 1.0, 1.0)).xy;
                gl_Position = uCameraMatrix*uObjectMatrix*vec4(aPosition, 1);
            }
        """;
    fragmentShaderCode = """
          precision highp float;
            uniform vec4 uColor;
            vec4 ColorTexture;
            vec4 ColorMask;
            varying vec2 vTextureCoord;
            varying vec2 vTextureMaskCoord;
            uniform sampler2D uSampler;
            uniform sampler2D uPuzzleMask;
            uniform float isVisibleRender;
            uniform float uCurrent;

            void main() {
                ColorMask  = texture2D(uPuzzleMask, vTextureMaskCoord);
                if (isVisibleRender == 1.0){
                    ColorTexture = texture2D(uSampler, vTextureCoord);
                    if (uCurrent == 1.0)
                      gl_FragColor = vec4(ColorTexture.rgb, ColorMask.r * 0.9);
                    else
                      gl_FragColor = vec4(ColorTexture.rgb, ColorMask.r );
                }
                else
                  gl_FragColor = vec4(uColor.rgb, ColorMask.r);
            }
        """; 
    compile();
  }
  
  void compile(){
    vertexShader = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vertexShader, vertexShaderCode);
    gl.compileShader(vertexShader);
    if (!gl.getShaderParameter(vertexShader, WebGL.COMPILE_STATUS)){
      throw gl.getShaderInfoLog(vertexShader);
    }
    
    fragmentShader = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, fragmentShaderCode);
    gl.compileShader(fragmentShader);
    if (!gl.getShaderParameter(fragmentShader, WebGL.COMPILE_STATUS)){
      throw gl.getShaderInfoLog(fragmentShader);
    }
    
    program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    gl.useProgram(program);
    if (!gl.getProgramParameter(program, WebGL.LINK_STATUS)){
      throw gl.getProgramInfoLog(program);
    }
  }
}
