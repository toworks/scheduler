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
 const space string = "    "
// var t = File{}
// var f *File = &t
 var f *File = &File{}

// func init() {
 func main() {
//    f := File{"ffff", "eeE"}
    f.set_file()
//    var f File
/*    f.name = os.Args[0] // get command line first parameter
    f._path = filepath.Dir(f.name)
    f._path, _ = filepath.Abs(f._path)
    f.name = filepath.Base(f.name)
    var ext string = filepath.Ext(f.name)
    f.name = strings.TrimSuffix(f.name, ext)*/
//    fmt.Printf("f.name: %s f._path: %s\n", f.name, f._path)
    fmt.Printf("f.name: %s f._path: %s\n", f.name, f._path)
    get_type("2 i")
    Save("33", "rrr")
 }

 func (f *File) set_file() {
//    var f File
    f.name = os.Args[0] // get command line first parameter
    f._path = filepath.Dir(f.name)
    f._path, _ = filepath.Abs(f._path)
    f.name = filepath.Base(f.name)
    var ext string = filepath.Ext(f.name)
    f.name = strings.TrimSuffix(f.name, ext)
//    fmt.Printf("f.name: %s f._path: %s\n", f.name, f._path)
    get_type("i")

 }

 func get_type(t string) string {
    fmt.Printf("t: %s f._path: %s\n", t, t)
    fmt.Printf("2 f.name: %s 2 f._path: %s\n", f.name, f._path)
    return "Grrr"
 }

 func Save (_type, _message string) {
//    var f string = *File
//    fmt.Println(time.Now().Format("2006-01-02 15:04:05.000"))
    var msg string
    msg = fmt.Sprintf("%s%s%s%s%s\n", time.Now().Format("2006-01-02 15:04:05.000"),
                                      space, _type, space, _message)
    // If the file doesn't exist, create it, or append to the file
    f, err := os.OpenFile(f.name+log_suffix, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Fatal(err)
    }
//    if _, err := f.Write([]byte("appended some data\n")); err != nil {
    if _, err := f.Write([]byte(msg)); err != nil {
        log.Fatal(err)
    }
    if err := f.Close(); err != nil {
        log.Fatal(err)
    }
 }



/*
 func Lmain(n bool) bool {
// func lmain() {

    filename := os.Args[0] // get command line first parameter

    filedirectory := filepath.Dir(filename)

    thepath, err := filepath.Abs(filedirectory)

    if err != nil {
//       log.Fatal(err)
       fmt.Println("err: ", err)
    }

    fmt.Println("path: fname: ", thepath, os.Args[0])
    return n
 }
*/
