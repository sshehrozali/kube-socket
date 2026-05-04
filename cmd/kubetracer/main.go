package main

import (
	"log"

	"github.com/sshehrozali/kubetracer/internal/kubetracer"
)

const (
	TRAFFIC_PORT           = "TRAFFIC_PORT"
	NODE_NETWORK_INTERFACE = "NODE_NETWORK_INTERFACE"
)

func main() {
	log.Print("Initialising kubetracer")

	log.Print("Retrieving env secrets...")
	tp := kubetracer.GetEnv(TRAFFIC_PORT, "80")
	if !kubetracer.IsValidPort(tp) {
		log.Fatal("Traffic port is invalid")
	}

	nic := kubetracer.GetEnv(NODE_NETWORK_INTERFACE, "any")
	if !kubetracer.IsValidNodeNic(nic) {
		log.Fatal("Invalid node network interface")
	}

	service := kubetracer.New(tp, nic)
	handle := service.Start()

	tsf := &kubetracer.TCPStreamFactory{}
	assembler := service.Assemble(handle, tsf)

	service.Stream(handle, assembler)
}
