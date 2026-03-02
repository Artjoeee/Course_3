package GO02_02LIB

import (
	"fmt"
	"net/http"
)

func F3(w http.ResponseWriter) {
	const A03 string = "hello"
	fmt.Fprintf(w, "A03 = %s\n", A03)
}
