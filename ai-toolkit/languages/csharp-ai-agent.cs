/**
 * AI Agent Template — C# (.NET)
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements:
 *   dotnet add package Azure.AI.OpenAI
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... dotnet run
 */

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Azure;
using Azure.AI.OpenAI;

public class AIAgent
{
    private const string DefaultModel = "gpt-4o";
    private const string SystemPrompt =
        "You are an AI agent in the lippytm ecosystem. " +
        "You help users learn programming, blockchain development, and build AI applications. " +
        "Be concise, educational, and practical.";

    private readonly OpenAIClient _client;
    private readonly string _model;
    private readonly List<ChatRequestMessage> _history = new();

    public AIAgent(string apiKey, string model = DefaultModel)
    {
        if (string.IsNullOrWhiteSpace(apiKey))
            throw new ArgumentException("OPENAI_API_KEY environment variable is not set.");

        _client = new OpenAIClient(apiKey);
        _model = model;
        Reset();
    }

    public async Task<string> ChatAsync(string userMessage)
    {
        _history.Add(new ChatRequestUserMessage(userMessage));

        var options = new ChatCompletionsOptions(_model, _history);
        Response<ChatCompletions> response = await _client.GetChatCompletionsAsync(options);
        string reply = response.Value.Choices[0].Message.Content;

        _history.Add(new ChatRequestAssistantMessage(reply));
        return reply;
    }

    public void Reset()
    {
        _history.Clear();
        _history.Add(new ChatRequestSystemMessage(SystemPrompt));
    }

    public static async Task Main(string[] args)
    {
        string? apiKey = Environment.GetEnvironmentVariable("OPENAI_API_KEY");
        string model = Environment.GetEnvironmentVariable("OPENAI_MODEL") ?? DefaultModel;

        var agent = new AIAgent(apiKey ?? "", model);

        Console.WriteLine("lippytm AI Agent (C#) — type 'quit' to exit, 'reset' to clear history\n");

        while (true)
        {
            Console.Write("You: ");
            string? input = Console.ReadLine()?.Trim();
            if (string.IsNullOrEmpty(input)) continue;

            if (input.Equals("quit", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("Goodbye!");
                break;
            }
            if (input.Equals("reset", StringComparison.OrdinalIgnoreCase))
            {
                agent.Reset();
                Console.WriteLine("Conversation history cleared.\n");
                continue;
            }

            string reply = await agent.ChatAsync(input);
            Console.WriteLine($"Agent: {reply}\n");
        }
    }
}
