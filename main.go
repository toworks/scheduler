package main

import (
	"fmt"
	//    "os"
	//    "path/filepath"
	//	c "./config"
	l "./logging"
)

var log = l.New()

func main() {
	Tew()
	//    d := logging.Lmain(false)
	//    d := l.Save("t", "test")
	//	conf := new(l)
	//lo := l.Test()
//	lo := l.new("uuuu") //l.New("rrrr")
//	lo := f.Save()
	log.Save("w", "u========="+log.Path())
	//l.Save("t", "test")
	//l.Save("i", "test")
	//fmt.Println("ret: ", log.Test())
	fmt.Println("ret2: ", log.Name())
	//    logging.Lmain()
	//    log.lmain()
	//    fmt.Println("ret: ", d)
}
