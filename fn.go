package main

 import (
    "fmt"
//    "log"
    "os"
    "path/filepath"
    "strings"
 )

 func main () {

    filename := os.Args[0] // get command line first parameter

    filedirectory := filepath.Dir(filename)

    thepath, err := filepath.Abs(filedirectory)

    if err != nil {
//       log.Fatal(err)
       fmt.Println(err)
    }

    fmt.Printf("path: %s, fname: %s, len: %d\n", thepath, strings.SplitN(os.Args[0], "/", len(os.Args[0])-1), len(os.Args[0]))
 }

