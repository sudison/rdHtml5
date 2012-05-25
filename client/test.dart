#import('dart:html');
#import('dart:isolate');
#source('rdViewer.dart');
#source('RfbProtocol.dart');
#source('RfbClient.dart');

void main() {
  RfbClient client = new RfbClient();
  rdViewer vw = new rdViewer();
  RFBClientMessage message = new RFBClientMessage();
  message.type = "initialize";
  message.data = ["localhost", '8080'];
  client.ProcessMessage(message);
}
