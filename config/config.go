package config

//package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"gopkg.in/yaml.v2"
)

type Config struct {
	Foo         string
	Bar         []string
	Description string
	Fruits      map[string][]string
}

var conf Config

//func main() {
func new(l logging) {
	filename := os.Args[1]
	source, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	err = yaml.Unmarshal(source, &conf)
	if err != nil {
		panic(err)
	}
	fmt.Printf("Value: %#v\n", conf.Bar[0])

	fmt.Printf("Description: %#v\n", conf.Description)
	fmt.Printf("Fruits: %#+v\n", conf.Fruits)
	fmt.Printf("Fruits-apple: %#+v\n", conf.Fruits["apple"])
	fmt.Printf("Fruits-0000: %#+v\n", conf.Fruits["apple"])
	fmt.Printf("Fruits-last: %#+v\n", conf.Fruits["apple"][0])
}
