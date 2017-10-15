# HTTPing

Test tool for httping to VMs, monitoring vm scale in/out

Use `go` to run

```
go run httping.go -w 1 -n 1000 http://8.8.8.8/host.php
```

Build source code

```
go build httping.go
```