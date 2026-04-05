<?php
/**
 * AI Agent Template — PHP
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements:
 *   composer require openai-php/client
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... php php-ai-agent.php
 */

declare(strict_types=1);

require_once __DIR__ . '/vendor/autoload.php';

use OpenAI;

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
define('OPENAI_MODEL',  getenv('OPENAI_MODEL')  ?: 'gpt-4o');
define('SYSTEM_PROMPT',
    'You are an AI agent in the lippytm ecosystem. ' .
    'You help users learn programming, blockchain development, and build AI applications. ' .
    'Be concise, educational, and practical.'
);

// ---------------------------------------------------------------------------
// AIAgent class
// ---------------------------------------------------------------------------
class AIAgent
{
    private \OpenAI\Client $client;
    private string $model;
    private array $history = [];

    public function __construct(string $apiKey, string $model = OPENAI_MODEL)
    {
        if (empty($apiKey)) {
            throw new \InvalidArgumentException('OPENAI_API_KEY environment variable is not set.');
        }
        $this->client = OpenAI::client($apiKey);
        $this->model  = $model;
        $this->reset();
    }

    public function chat(string $userMessage): string
    {
        $this->history[] = ['role' => 'user', 'content' => $userMessage];

        $response = $this->client->chat()->create([
            'model'    => $this->model,
            'messages' => $this->history,
        ]);

        $reply = $response->choices[0]->message->content ?? '';
        $this->history[] = ['role' => 'assistant', 'content' => $reply];
        return $reply;
    }

    public function reset(): void
    {
        $this->history = [['role' => 'system', 'content' => SYSTEM_PROMPT]];
    }
}

// ---------------------------------------------------------------------------
// Main — interactive REPL (CLI only)
// ---------------------------------------------------------------------------
$apiKey = (string) (getenv('OPENAI_API_KEY') ?: '');
$agent  = new AIAgent($apiKey);

echo "lippytm AI Agent (PHP) — type 'quit' to exit, 'reset' to clear history\n\n";

while (true) {
    echo 'You: ';
    $input = trim((string) fgets(STDIN));
    if ($input === '') continue;
    if (strtolower($input) === 'quit') { echo "Goodbye!\n"; break; }
    if (strtolower($input) === 'reset') {
        $agent->reset();
        echo "Conversation history cleared.\n\n";
        continue;
    }
    $reply = $agent->chat($input);
    echo "Agent: {$reply}\n\n";
}
