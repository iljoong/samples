/*
 * test tool for http ping to VMs
 *	- scale in/out
 *
 * httping -w 1 -n 100 http://xxx.xxx.com/host.php
 */

package main

import (
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	"golang.org/x/net/context"
)

type result struct {
	time   int
	output string
}

func httping(ctx context.Context, url string, i int) (result, error) {

	c := make(chan result)
	start := time.Now()

	// default http.Get seems caching content(?)
	client := &http.Client{
		Transport: &http.Transport{
			DisableKeepAlives: true,
		},
	}
	go func(string, int) {

		//resp, err := http.Get(url)
		resp, err := client.Get(url)

		if err != nil {
			//panic(err)
			log.Printf("%d : http.get err %s", i, err.Error())
			c <- result{time: -1, output: "http.get err"}
		} else {

			data, err := ioutil.ReadAll(resp.Body)
			defer resp.Body.Close()

			if err != nil {
				panic(err)
			}

			elapsed := time.Since(start)

			c <- result{time: int(elapsed / 1000000), output: string(data)}
		}
	}(url, i)

	select {
	case <-ctx.Done():
		elapsed := time.Since(start)
		return result{time: int(elapsed / 1000000), output: ""}, errors.New("Deadline")
	case r := <-c:
		if r.time < 0 {
			return r, errors.New(r.output)
		}
		return r, nil
	}

}

func main() {

	var (
		wait  = flag.Int("w", 2, "wait time between httping in seconds")
		count = flag.Int("n", 10, "number of httping")
		show  = flag.Bool("s", false, "show body content")
	)

	flag.Parse()

	args := flag.Args()

	if len(args) < 1 {
		log.Fatal("httping [option] urlpath")
	}

	for i := 0; i < *count; i++ {
		ctx, cancel := context.WithTimeout(context.Background(), time.Duration(*wait*1000)*time.Millisecond)
		defer cancel()

		res, err := httping(ctx, args[0], i)
		if err != nil {
			//panic(err)
			fmt.Printf("%d: Error: %d msec, %s\n", i, res.time, err.Error())
		} else {
			if *show {
				fmt.Printf("%d: %d msec - %s\n", i, res.time, res.output)
			} else {
				fmt.Printf("%d: %d msec\n", i, res.time)
			}

		}

		time.Sleep(time.Duration(*wait*1000-res.time) * time.Millisecond)
	}

}
