package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"

	openai "github.com/sashabaranov/go-openai"
)

func main() {
	defer func() {
		if r := recover(); r != nil {
			debf(fmt.Sprintf("SOMETHING GOT FUCKED UP %v", r))
		}
	}()

	client := openai.NewClient(os.Getenv("OPENAI_API_KEY"))
	rawMessageCap := os.Getenv("MESSAGE_CAP")
	geppetoDebug := os.Getenv("GEPPETO_DEBUG")
	debug := strings.Contains(geppetoDebug, "yes")

	if rawMessageCap == "" {
		rawMessageCap = "50"
	}

	messageCap, err := strconv.Atoi(rawMessageCap)
	if err != nil {
		log.Fatal("Failed to parse message cap:", err)
	}
	req := openai.ChatCompletionRequest{
		Stream: true,
		Model:  openai.GPT5,
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: "you are a helpful chatbot",
			},
		},
	}
	infifo := os.Args[1]
	outfifo := os.Args[2]

	inputFile, err := os.OpenFile(infifo, os.O_RDWR, os.ModeNamedPipe)
	if err != nil {
		log.Fatal("Failed to open input FIFO:", err)
	}
	defer inputFile.Close()

	outputFile, err := os.OpenFile(outfifo, os.O_RDWR, os.ModeNamedPipe)
	if err != nil {
		log.Fatal("Failed to open output FIFO:", err)
	}
	defer outputFile.Close()

	s := bufio.NewScanner(inputFile)
	for s.Scan() {
		req.Messages = append(req.Messages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleUser,
			Content: s.Text(),
		})
		stream, err := client.CreateChatCompletionStream(context.Background(), req)
		if err != nil {
			msg := fmt.Sprintf("ChatCompletion error: %v", err)
			if debug {
				outputFile.WriteString(msg)
				outputFile.WriteString("\n")
			}
			fmt.Printf("%s\n", msg)
			continue
		}

		msg := openai.ChatCompletionMessage{Role: openai.ChatMessageRoleAssistant}

	BUFFERING:
		for {
			resp, err := stream.Recv()
			if err != nil {
				if err == io.EOF {
					outputFile.WriteString("\n")
					break BUFFERING
				}
				msg := fmt.Sprintf("ChatCompletion error: %v", err)
				if debug {
					outputFile.WriteString(msg)
					outputFile.WriteString("\n")
				}
				fmt.Printf("%s\n", msg)
			}
			outputFile.WriteString(fmt.Sprintf("%s", resp.Choices[0].Delta.Content))
			msg.Content = msg.Content + resp.Choices[0].Delta.Content
		}

		req.Messages = append(req.Messages, msg)

		ran := len(req.Messages) - messageCap
		if ran < 0 {
			ran = 0
		}

		req.Messages = req.Messages[ran:]
	}
}

var dbgf *os.File

func init() {
	var err error
	dbgf, err = os.CreateTemp(os.TempDir(), "gepeto_debugardo")
	if err != nil {
		panic(err)
	}
	debf("DEBUG INIT OK")
}

func debf(v string) {
	dbgf.WriteString(fmt.Sprintf("%s\n", v))
}
