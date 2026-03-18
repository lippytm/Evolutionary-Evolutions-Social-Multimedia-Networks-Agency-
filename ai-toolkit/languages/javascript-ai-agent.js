/**
 * AI Agent Template — JavaScript (Node.js)
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements:
 *   npm install openai readline
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... node javascript-ai-agent.js
 */

"use strict";

const readline = require("readline");
const OpenAI = require("openai").default || require("openai");

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || "";
const MODEL = process.env.OPENAI_MODEL || "gpt-4o";
const SYSTEM_PROMPT =
  "You are an AI agent in the lippytm ecosystem. " +
  "You help users learn programming, blockchain development, and build AI applications. " +
  "Be concise, educational, and practical.";

// ---------------------------------------------------------------------------
// Agent
// ---------------------------------------------------------------------------
class AIAgent {
  constructor(apiKey, model = MODEL) {
    if (!apiKey) throw new Error("OPENAI_API_KEY environment variable is not set.");
    this.client = new OpenAI({ apiKey });
    this.model = model;
    this.history = [{ role: "system", content: SYSTEM_PROMPT }];
  }

  async chat(userMessage) {
    this.history.push({ role: "user", content: userMessage });
    const response = await this.client.chat.completions.create({
      model: this.model,
      messages: this.history,
    });
    const reply = response.choices[0].message.content || "";
    this.history.push({ role: "assistant", content: reply });
    return reply;
  }

  reset() {
    this.history = [{ role: "system", content: SYSTEM_PROMPT }];
  }
}

// ---------------------------------------------------------------------------
// Main — interactive REPL
// ---------------------------------------------------------------------------
async function main() {
  const agent = new AIAgent(OPENAI_API_KEY);
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const prompt = () =>
    rl.question("You: ", async (input) => {
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

  console.log("lippytm AI Agent (JavaScript) — type 'quit' to exit, 'reset' to clear history\n");
  prompt();
}

main().catch(console.error);
