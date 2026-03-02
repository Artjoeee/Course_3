package main

import (
	"GO02_02/GO02_02LIB"
	"fmt"
	"log"
	"net/http"
)

func F1(w http.ResponseWriter) {
	var A01 int64 = 3
	fmt.Fprintf(w, "A01 = %d,\n", A01)
}

func handler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		switch r.URL.Path {
		case "/":
			F1(w)
			F2(w)
			GO02_02LIB.F3(w)
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
	log.Println("Сервер запущен: http://localhost:4000")
	log.Fatal(http.ListenAndServe(":4000", nil))
}
