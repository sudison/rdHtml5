
class rdViewer {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  rdViewer() {
    canvas = document.query("#canvas");
    ctx = canvas.getContext("2d");
   }
  
  initializeScreen(int width, int height) {
    canvas.width = width;
    canvas.height = height;
    ctx.clearRect(0, 0, width, height);
  }
  
  drawFrame(List<int> updatedRect, int x, int y, int width, int height) {
    ctx.clearRect(0, 0, width, height);
    ctx.beginPath();
    ImageData data = ctx.createImageData(width, height);
    
    var rawPixels = data.data;
    for (int i=0; i< updatedRect.length;) {
      rawPixels[i] = updatedRect[i];
      i++;
      rawPixels[i] = updatedRect[i];
      i++;
      rawPixels[i] = updatedRect[i];
      i++;
      rawPixels[i] = updatedRect[i];
      i++;
    }
    ctx.putImageData(data, x, y);
    ctx.closePath();
  }
  
}