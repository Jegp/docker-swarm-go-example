package main

import (
	"context"
	"fmt"
	"html/template"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

func ping(res http.ResponseWriter, req *http.Request) {
	const tpl = `
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Served from {{.From}}</title>
	</head>
	<body>
		This page is served from: {{.From}} <br>
		The server container will die at {{.DieTime}}
	</body>
</html>`

	check := func(err error) {
		if err != nil {
			log.Fatal(err)
		}
	}
	t, err := template.New("webpage").Parse(tpl)
	check(err)

	data := struct {
		From    string
		DieTime time.Time
	}{
		From:    hostName,
		DieTime: dieTime,
	}

	err = t.Execute(res, data)
	check(err)
}

// I will die in a random time some minutes from now on...
var dieTDiff = time.Duration(1) * time.Second
var dieTime = time.Now().Add(dieTDiff)
var hostName, _ = os.Hostname()
var myPid = os.Getpid()

func main() {
	rand.Seed(time.Now().UnixNano())
	dieTDiff = time.Duration(rand.Intn(20)) * time.Second

	log.Println(myPid)
	log.Println(hostName)

	log.Printf("I will die at %s", dieTime)
	// http.HandleFunc("/", )
	http.HandleFunc("/status", ping)

	// The following calls the keepBusy func every so and so many seconds
	// see: https://stackoverflow.com/questions/43002163/run-function-only-once-for-specific-time-golang
	fmt.Println(dieTDiff)
	ticker := time.NewTicker(dieTDiff)
	go func(ticker *time.Ticker) {
		for {
			select {
			case <-ticker.C:
				syscall.Kill(syscall.Getpid(), syscall.SIGINT)
			}
		}
	}(ticker)

	// Create a new server and set timeout values.
	server := http.Server{
		Addr: ":8080",
	}

	// We want to report the listener is closed.
	var wg sync.WaitGroup
	wg.Add(1)

	// Start the listener.
	go func() {
		log.Println("listener: Listening on localhost:8080")
		log.Println("listener:", server.ListenAndServe())
		wg.Done()
	}()

	// Listen for an interrupt signal from the OS. Use a buffered
	// channel because of how the signal package is implemented.
	osSignals := make(chan os.Signal, 1)
	signal.Notify(osSignals, os.Interrupt)

	// Wait for a signal to shutdown.
	<-osSignals

	// Create a context to attempt a graceful 5 second shutdown.
	const timeout = 5 * time.Second
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	// Attempt the graceful shutdown by closing the listener and
	// completing all inflight requests.
	if err := server.Shutdown(ctx); err != nil {
		log.Printf("Shutdown: Graceful shutdown did not complete in %v : %v", timeout, err)

		// Looks like we timedout on the graceful shutdown. Kill it hard.
		if err := server.Close(); err != nil {
			log.Printf("Shutdown: Error killing server : %v", err)
		}
	}

	// Wait for the listener to report it is closed.
	wg.Wait()
	log.Println("Main: Completed")
}
