/**
 * AI Agent Template — TypeScript
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements:
 *   npm install openai tsx
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... npx tsx typescript-ai-agent.ts
 */

import OpenAI from "openai";
import * as readline from "readline";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
const OPENAI_API_KEY: string = process.env.OPENAI_API_KEY ?? "";
const MODEL: string = process.env.OPENAI_MODEL ?? "gpt-4o";
const SYSTEM_PROMPT: string =
  "You are an AI agent in the lippytm ecosystem. " +
  "You help users learn programming, blockchain development, and build AI applications. " +
  "Be concise, educational, and practical.";

type Message = { role: "system" | "user" | "assistant"; content: string };

// ---------------------------------------------------------------------------
// Agent class
// ---------------------------------------------------------------------------
class AIAgent {
  private readonly client: OpenAI;
  private readonly model: string;
  private history: Message[];

  constructor(apiKey: string, model: string = MODEL) {
    if (!apiKey) throw new Error("OPENAI_API_KEY environment variable is not set.");
    this.client = new OpenAI({ apiKey });
    this.model = model;
    this.history = [{ role: "system", content: SYSTEM_PROMPT }];
  }

  async chat(userMessage: string): Promise<string> {
    this.history.push({ role: "user", content: userMessage });
    const response = await this.client.chat.completions.create({
      model: this.model,
      messages: this.history,
    });
    const reply: string = response.choices[0].message.content ?? "";
    this.history.push({ role: "assistant", content: reply });
    return reply;
  }

  reset(): void {
    this.history = [{ role: "system", content: SYSTEM_PROMPT }];
  }
}

// ---------------------------------------------------------------------------
// Main — interactive REPL
// ---------------------------------------------------------------------------
async function main(): Promise<void> {
  const agent = new AIAgent(OPENAI_API_KEY);
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

  console.log(
    "lippytm AI Agent (TypeScript) — type 'quit' to exit, 'reset' to clear history\n"
  );

  const prompt = (): void => {
    rl.question("You: ", async (input: string) => {
      const text = input.trim();
      if (!text) return prompt();
      if (text.toLowerCase() === "quit") {
        console.log("Goodbye!");
        rl.close();
        return;
      }
      if (text.toLowerCase() === "reset") {
        agent.reset();
        console.log("Conversation history cleared.\n");
        return prompt();
      }
      const reply = await agent.chat(text);
      console.log(`Agent: ${reply}\n`);
      prompt();
    });
  };

  prompt();
}

main().catch(console.error);
