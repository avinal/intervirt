package main

import "github.com/avinal/intervirt/backend/pkg/api"

func main() {

	r := api.Router()
	r.Run(":8089")
}
