package main

import (
	GO02_01LIB "GO02_01/GO02_01LIB"
	"fmt"
	"log"
	"net/http"
)

func F1(w http.ResponseWriter) {
	const c01 float64 = 3.14
	fmt.Fprintf(w, "c01 = %e,\n", c01)
}

func handler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		switch r.URL.Path {
		case "/":
			F1(w)
			F2(w)
			GO02_01LIB.F3(w)
		default:
			http.NotFound(w, r)
		}
	// case "POST":
	// 	switch r.URL.Path {
	// 	case "/":
	// 		fmt.Fprintln(w, "Метод POST")
	// 	default:
	// 		http.NotFound(w, r)
	// 	}
	// case "PUT":
	// 	switch r.URL.Path {
	// 	case "/":
	// 		fmt.Fprintln(w, "Метод PUT")
	// 	default:
	// 		http.NotFound(w, r)
	// 	}
	// case "DELETE":
	// 	switch r.URL.Path {
	// 	case "/":
	// 		fmt.Fprintln(w, "Метод DELETE")
	// 	default:
	// 		http.NotFound(w, r)
	// 	}
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func main() {
	http.HandleFunc("/", handler)
	log.Println("Сервер запущен: http://localhost:3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}
