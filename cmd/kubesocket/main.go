package main

import (
	"log"

	"github.com/sshehrozali/kube-socket/internal/kubesocket"
)

const (
	TRAFFIC_PORT           = "TRAFFIC_PORT"
	NODE_NETWORK_INTERFACE = "NODE_NETWORK_INTERFACE"
)

func main() {
	log.Print("Initialising kubesocket")

	log.Print("Retrieving env secrets...")
	tp := kubesocket.GetEnv(TRAFFIC_PORT, "80")
	if !kubesocket.IsValidPort(tp) {
		log.Fatal("Traffic port is invalid")
	}

	nic := kubesocket.GetEnv(NODE_NETWORK_INTERFACE, "any")
	if !kubesocket.IsValidNodeNic(nic) {
		log.Fatal("Invalid node network interface")
	}

	service := kubesocket.New(tp, nic)
	handle := service.Start()

	tsf := &kubesocket.TCPStreamFactory{}
	assembler := service.Assemble(handle, tsf)

	service.Stream(handle, assembler)
}
