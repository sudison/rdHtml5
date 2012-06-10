
#import('dart:html');
#import('dart:isolate');
#source('rdViewer.dart');
#source('RfbProtocol.dart');
#source('RfbClient.dart');
#source('utils.dart');
#source('Base64.dart');
#source('RFBStateMachine.dart');
#source('ByteStream.dart');
#source('Logging.dart');


void main() {
  RfbClient client = new RfbClient();
  rdViewer vw = new rdViewer();
  client.setViewer(vw);
  RFBClientMessage message = new RFBClientMessage();
  message.type = "initialize";
  message.data = ["localhost", '8080'];
  client.ProcessMessage(message);
} 
