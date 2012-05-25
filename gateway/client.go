package main
import (
    "net"
    "fmt"
)

func handleConnection(c net.Conn) {
    d := []byte{'h','e','l','l','o'}
    rev := []byte{}
    c.Read(rev)
    if len(rev) > 0 && rev[0] == 'e' {
        c.Close()
        return
    }
    c.Write(d)
}
func main() {
    conn, err := net.Dial("tcp", ":8100")
    if err != nil {
       fmt.Printf("Faild to listen on socket") 
    }
    for {
        data := []byte{'l','l'}
        conn.Write(data)
        var rev []byte = make([]byte,5)
        conn.Read(rev)
        for i := 0; i < len(rev); i++ {
            fmt.Print(string(rev[i]))
        }
    }
}
