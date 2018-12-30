//package logging
package main

 import (
    "fmt"
    "os"
    "log"
    "path/filepath"
    "strings"
    "time"
 )

 type Message struct {
    _type    [1]string
    message  string
 }

 type File struct {
    name, _path    string
 }

 const log_suffix string = ".log"
 var f *File = &File{}

// func init() {
 func main() {
    f.set_file()
    fmt.Printf("f.name: %s f._path: %s\n", f.name, f._path)
    Save("i", f.name +" | "+ f._path)

    Save("33", "rrr")
    Save("f", "fff")
    Save("e", "err")
    Save("w", "www")
    Save("i", "iii")
    Save("d", "ddd")
    Save("t", "tt")
 }

 func (f *File) set_file() {
    f.name = os.Args[0] // get command line first parameter
    f._path = filepath.Dir(f.name)
    f._path, _ = filepath.Abs(f._path)
    f.name = filepath.Base(f.name)
    var ext string = filepath.Ext(f.name)
    f.name = strings.TrimSuffix(f.name, ext)
//    fmt.Printf("f.name: %s f._path: %s\n", f.name, f._path)
 }

 func get_type(t string) string {
    var _type string
    switch {
        case t == "f" :
            _type = "FATAL"
        case t == "e" :
            _type = "ERROR"
        case t == "w" :
            _type = "WARN"
        case t == "i" :
            _type = "INFO"
        case t == "d" :
            _type = "DEBUG"
        case t == "t" :
            _type = "TRACE"
        default :
            _type = "INFO"
    }
    return fmt.Sprintf("%-5s", _type)
 }

 func Save (_type, _message string) {
    var msg string
    msg = fmt.Sprintf("%s%s%s%s%s\n", time.Now().Format("2006-01-02 15:04:05.000"),
                                      "  ", get_type(_type), "  ", _message)
    // If the file doesn't exist, create it, or append to the file
    f, err := os.OpenFile(f.name+log_suffix, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Fatal(err)
    }

    if _, err := f.Write([]byte(msg)); err != nil {
        log.Fatal(err)
    }
    if err := f.Close(); err != nil {
        log.Fatal(err)
    }
 }
