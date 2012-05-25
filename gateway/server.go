package main

import (
    "net"
    "fmt"
)

func handleConnection(c net.Conn) {
    for {
    d := []byte{'h','e','l','l','o'}
    var rev []byte = make([]byte, 2)
    c.Read(rev)
    if len(rev) > 0 && rev[0] == 'e' {
        c.Close()
        return
    }
    c.Write(d)
    }
}
func main() {
    ln, err := net.Listen("tcp", ":8100")
    if err != nil {
       fmt.Printf("Faild to listen on socket") 
    }
    for {
        conn, err := ln.Accept()
        if err != nil {
            continue
        }
        go handleConnection(conn)
    }
}
