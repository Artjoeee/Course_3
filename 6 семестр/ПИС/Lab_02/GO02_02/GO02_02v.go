package main

import (
	"fmt"
	"net/http"
)

func F2(w http.ResponseWriter) {
	var A02 bool = false
	fmt.Fprintf(w, "A02 = %t,\n", A02)
}
