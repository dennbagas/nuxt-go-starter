package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	app.Static("/", "../dist", fiber.Static{
		Compress: true,
	})
	app.Get("/*", func(ctx *fiber.Ctx) error {
		return ctx.SendFile("../dist/index.html", true)
	})

	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(dir)

	addr := flag.String("addr", ":8080", "http service address")
	flag.Parse()
	log.Fatal(app.Listen(*addr))
}
