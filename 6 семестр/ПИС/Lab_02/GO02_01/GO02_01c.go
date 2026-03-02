package main

import (
	"fmt"
	"net/http"
)

func F2(w http.ResponseWriter) {
	const c02 float64 = 6.626070e-34
	fmt.Fprintf(w, "c02 = %e,\n", c02)
}
