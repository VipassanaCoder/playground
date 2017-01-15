package main

import "fmt"

// Hello is a type that can alert a greeting
type Hello struct {
	Message string
}

// New constructs a new Hello object with the specified Message
func New(message string) *Hello {
	return &Hello{
		Message: message,
	}
}

// Alert prints the Hello object Message to stdout
func (h *Hello) Alert() {
	fmt.Println(h.Message)
}
