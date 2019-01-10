
package main

import (
    "fmt"
    "time"
    l "./logging"
)

func pinger(c chan string) {
    for i := 0; ; i++ {
        var s = "ping"
                fmt.Println("1: ", s, time.Now())
                l.Save("i", "1: "+s)
        c <- s
    }
}
func printer(c chan string) {
    for {
        msg := <- c
        fmt.Println("2: ", msg)
        l.Save("i", "2: "+msg)
//        time.Sleep(time.Second * 1)
        time.Sleep(time.Millisecond * 100)
    }
}
func main() {
    var c chan string = make(chan string)

    go pinger(c)
    go printer(c)

    var input string
    fmt.Scanln(&input)
}


/*
package main

import "fmt"

var globState string = "initial"

func getState() (string, bool) {
	return "working", true
}

func ini() {
	globState, ok := getState()
	if !ok {
		fmt.Println(globState)
	}
}

func main() {
//	var ee string = ""
	ini()
	fmt.Println("Current state: ", globState)
	ee, ok := getState()
	fmt.Println("Current state: ", ee, ok)
}

/*


package main

import (
	"fmt"
)

func eq(val1 interface{}, val2 interface{}) bool {
	return val1 == val2
}

func main() {
	var i32 int32 = 0
	var i64 int64 = 0
	var in int = 0

	fmt.Println(eq(i32, i64))
	fmt.Println(eq(i32, in))
	fmt.Println(eq(in, i64))
}
*/
