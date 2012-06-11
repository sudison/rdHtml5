
class rdViewer {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  var _logger;
  rdViewer() {
    _logger = Logging.getLogger("viewer");
    canvas = document.query("#canvas");
    ctx = canvas.getContext("2d");
   }
  
  initializeScreen(int width, int height) {
    canvas.width = width;
    canvas.height = height;
    ctx.clearRect(0, 0, width, height);
  }
  
  drawFrame(List<int> updatedRect, int x, int y, int width, int height) {
    
    _logger.Debug("start draw frame:");
    ImageData data = ctx.getImageData(x, y, width, height);
    
    var rawPixels = data.data;
    var u32Data = new Uint32Array.fromBuffer(rawPixels.buffer);
    for (int i=0; i< (updatedRect.length~/4);i++) {
      u32Data[i] = updatedRect[i*4] + ((updatedRect[i*4+1] << 8)) + 
          ((updatedRect[i*4 + 2] << 16)) + ((updatedRect[i*4 +3] << 24));
    }
    ctx.putImageData(data, x,y);
    _logger.Debug("finished draw frame" + " x: " + x + ";y:" +y + ";width:" + width +";h:" + height);
  }
  
}