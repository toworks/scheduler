package main

 import (
    "fmt"
//    "os"
//    "path/filepath"
    l "./logging"
 )

 func main () {
//    d := logging.Lmain(false)
    d := l.Lmain(false)
//    logging.Lmain()
//    log.lmain()
    fmt.Println("ret: ", d)
 }
