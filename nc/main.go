package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"time"
)

func main() {
	if len(os.Args) != 4 {
		println("No arguments")
		os.Exit(1)
	}

	from := os.Args[1]
	to := os.Args[2]
	file := os.Args[3]

	go func() {
		t := time.NewTimer(time.Second * 60)
		<-t.C
		println("Timeout")
		os.Exit(1)
	}()

	conn, err := net.DialTimeout("tcp", "localhost:10029", time.Second)
	if err != nil {
		println(err)
		os.Exit(1)
	}

	rdr := bufio.NewReader(conn)

	val, err := rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "220 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	fmt.Fprintf(conn, "HELO localhost\r\n")
	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "250 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	fmt.Fprintf(conn, "MAIL FROM:<%s>\r\n", from)
	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "250 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	fmt.Fprintf(conn, "RCPT TO:<%s>\r\n", to)
	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "250 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	fmt.Fprintf(conn, "DATA\r\n")
	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "354 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	h, err := os.Open(file)
	if err != nil {
		println("Open error", err)
		os.Exit(1)
	}

	s := bufio.NewScanner(h)
	for s.Scan() {
		fmt.Fprintf(conn, s.Text()+"\r\n")
	}

	fmt.Fprintf(conn, "\r\n")
	fmt.Fprintf(conn, ".\r\n")

	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "250 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}

	fmt.Fprintf(conn, "QUIT\r\n")
	val, err = rdr.ReadString('\n')
	if err != nil {
		println(err)
		os.Exit(1)
	}

	if !(len(val) >= 4 && val[0:4] == "221 ") {
		println("Incorrect response: ", val)
		os.Exit(1)
	}
}
