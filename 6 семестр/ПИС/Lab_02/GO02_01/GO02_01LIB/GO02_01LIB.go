package GO02_01LIB

import (
	"fmt"
	"net/http"
)

func F3(w http.ResponseWriter) {
	const c02 float64 = 2.718282
	fmt.Fprintf(w, "c03 = %e\n", c02)
}
