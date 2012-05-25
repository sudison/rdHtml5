package main
import (
    "net"
    "code.google.com/p/go.net/websocket"
    "log"
    "flag"
	"net/http"
	"text/template"
)

type webSocketConn struct {
    conn *websocket.Conn
}
func (ws *webSocketConn) readMessage() []byte {
   var message string
   err := websocket.Message.Receive(ws.conn, &message)
   if err != nil {
        log.Print("Failed to read message", err)
        return nil
   }
   return []byte(message) 
}

func (ws *webSocketConn) writeMessage(data []byte) bool {
    err := websocket.Message.Send(ws.conn, string(data))  
    if err != nil {
        log.Print("Failed to write message", err)
        return false
    }
    return true
}

type netConn struct {
    conn net.Conn
}

func (nc *netConn) readMessage() []byte {
   data :=make([]byte, 100)
   len, err := nc.conn.Read(data) 
   if err != nil {
    log.Print("Failed to read data from backend", err)
    return nil
    }

    return data[:len]
}

func (nc *netConn) writeMessage(data []byte) bool {
    lenth, err := nc.conn.Write(data)
    if err != nil {
        log.Print("Failed to write data to backend", err)
        return false
    }
    if lenth != len(data) {
        log.Print("Failed to write data to backend")
        return false
    }
    return true
}

type connWrapper interface {
    readMessage() []byte
    writeMessage([]byte) bool
}
type gateway struct {
    frontend *webSocketConn
    backend *netConn
    send chan []byte
    recv chan []byte
}

func (gw *gateway) read(conn connWrapper, snd chan []byte) {
    for {
        data := conn.readMessage() 
        if data == nil {
            break;
        }
        snd <-data
    }
}

func (gw *gateway) handleDataExchange() {
    for {
        select {
            case sendMsgToFront := <- gw.send:
                msg := []byte("hello ")
                msg1 := append(msg,sendMsgToFront...)
                gw.frontend.writeMessage(msg1)
            case sendMsgToBack := <- gw.recv:
                gw.backend.writeMessage(sendMsgToBack)
        }
    }
}
func start(c *websocket.Conn) {
    backend, err := net.Dial("tcp", ":8100")
    if err != nil {
        log.Fatal("Failed to connect to backend", err)
    }

    gw := new(gateway)
    front := new(webSocketConn)
    front.conn = c
    gw.frontend = front
    back := new(netConn)
    back.conn = backend
    gw.backend = back
    gw.send = make(chan []byte)
    gw.recv = make(chan []byte)

    go gw.read(gw.backend, gw.recv)
    go gw.handleDataExchange()
    gw.read(gw.frontend, gw.send)
}

var addr = flag.String("addr", ":8080", "http service address")
var homeTempl = template.Must(template.ParseFiles("home.html"))

func homeHandler(c http.ResponseWriter, req *http.Request) {
	homeTempl.Execute(c, req.Host)
}

func main() {
    flag.Parse()
    http.HandleFunc("/", homeHandler)
    http.Handle("/ws", websocket.Handler(start))
    if err := http.ListenAndServe(*addr, nil); err != nil {
        log.Fatal("ListenAndServe:", err)
    }

}
