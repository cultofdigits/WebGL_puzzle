library puzzle;

import 'dart:html';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as Img;
import 'dart:math' as Math;
import 'dart:web_gl' as WebGL;
import "dart:typed_data";
import "package:vector_math/vector_math.dart";

part 'mask_texture.dart';
part 'webgl_shader.dart';
part 'puzzle_webgl.dart';
part 'webgl_quad.dart';

final int PUZZLE_COUNT = 5;

class PuzzleElement{
  int x, y;
  int left, top, bottom, right;
  PuzzleElement(this.x, this.y, this.left, this.top, this.right, this.bottom){}
}

class Puzzle{
  int sizex, sizey;
  List<List<PuzzleElement>> elements;
  TextureMask mask;

  int randEdge(){
    Math.Random random = new Math.Random();
    return random.nextBool()?1:-1;
  }
  int reverseEdge(edge){
    return edge <0?1:-1;
  }
  
  Puzzle(this.sizex, this.sizey){
    elements = new List<List<PuzzleElement>>();
    for (int y = 0; y < this.sizey; y++){
      elements.add(new List<PuzzleElement>());
      for (int x = 0; x < this.sizex; x++){
        int left   = x==0 ?0:reverseEdge(elements[y][x-1].right);
        int top    = y==0 ?0:reverseEdge(elements[y-1][x].bottom);
        int right  = x==this.sizex-1 ?0:randEdge();
        int bottom = y==this.sizey-1 ?0:randEdge();
        elements[y].add(new PuzzleElement(x, y, left,top,right, bottom));
      }
    }
    mask = new TextureMask(this);
  }
}

void main() {
  Puzzle puzzle = new Puzzle(PUZZLE_COUNT,PUZZLE_COUNT);
  CanvasElement canvas = querySelector('#puzzle-canvas');
  WebGLPuzzle p1 = new WebGLPuzzle(puzzle, canvas, window);
}