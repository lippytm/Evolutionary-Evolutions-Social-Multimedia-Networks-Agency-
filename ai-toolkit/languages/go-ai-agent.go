// AI Agent Template — Go
// Part of the lippytm AI Full-Stack Toolkit
// https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
//
// Requirements:
//   go mod init ai-agent
//   go get github.com/sashabaranov/go-openai
//
// Usage:
//   OPENAI_API_KEY=sk-... go run go-ai-agent.go

package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strings"

	openai "github.com/sashabaranov/go-openai"
)

const (
	defaultModel = "gpt-4o"
	systemPrompt = "You are an AI agent in the lippytm ecosystem. " +
		"You help users learn programming, blockchain development, and build AI applications. " +
		"Be concise, educational, and practical."
)

// AIAgent holds the client and conversation history.
type AIAgent struct {
	client  *openai.Client
	model   string
	history []openai.ChatCompletionMessage
}

// NewAIAgent creates a new agent instance.
func NewAIAgent(apiKey, model string) (*AIAgent, error) {
	if apiKey == "" {
		return nil, fmt.Errorf("OPENAI_API_KEY environment variable is not set")
	}
	return &AIAgent{
		client: openai.NewClient(apiKey),
		model:  model,
		history: []openai.ChatCompletionMessage{
			{Role: openai.ChatMessageRoleSystem, Content: systemPrompt},
		},
	}, nil
}

// Chat sends a user message and returns the assistant reply.
func (a *AIAgent) Chat(ctx context.Context, userMessage string) (string, error) {
	a.history = append(a.history, openai.ChatCompletionMessage{
		Role:    openai.ChatMessageRoleUser,
		Content: userMessage,
	})

	resp, err := a.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model:    a.model,
		Messages: a.history,
	})
	if err != nil {
		return "", fmt.Errorf("OpenAI error: %w", err)
	}

	reply := resp.Choices[0].Message.Content
	a.history = append(a.history, openai.ChatCompletionMessage{
		Role:    openai.ChatMessageRoleAssistant,
		Content: reply,
	})
	return reply, nil
}

// Reset clears conversation history.
func (a *AIAgent) Reset() {
	a.history = []openai.ChatCompletionMessage{
		{Role: openai.ChatMessageRoleSystem, Content: systemPrompt},
	}
}

func main() {
	apiKey := os.Getenv("OPENAI_API_KEY")
	model := os.Getenv("OPENAI_MODEL")
	if model == "" {
		model = defaultModel
	}

	agent, err := NewAIAgent(apiKey, model)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}

	fmt.Println("lippytm AI Agent (Go) — type 'quit' to exit, 'reset' to clear history\n")

	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("You: ")
		if !scanner.Scan() {
			break
		}
		text := strings.TrimSpace(scanner.Text())
		if text == "" {
			continue
		}
		switch strings.ToLower(text) {
		case "quit":
			fmt.Println("Goodbye!")
			return
		case "reset":
			agent.Reset()
			fmt.Println("Conversation history cleared.\n")
			continue
		}

		reply, err := agent.Chat(context.Background(), text)
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error:", err)
			continue
		}
		fmt.Printf("Agent: %s\n\n", reply)
	}
}
