"""
AI Agent Template — Python
Part of the lippytm AI Full-Stack Toolkit
https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-

Requirements:
    pip install openai python-dotenv

Usage:
    OPENAI_API_KEY=sk-... python python-ai-agent.py
"""

import os
from openai import OpenAI

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
MODEL = os.environ.get("OPENAI_MODEL", "gpt-4o")
SYSTEM_PROMPT = (
    "You are an AI agent in the lippytm ecosystem. "
    "You help users learn programming, blockchain development, and build AI applications. "
    "Be concise, educational, and practical."
)


# ---------------------------------------------------------------------------
# Agent class
# ---------------------------------------------------------------------------
class AIAgent:
    """A simple conversational AI agent backed by OpenAI."""

    def __init__(self, api_key: str, model: str = MODEL):
        if not api_key:
            raise ValueError("OPENAI_API_KEY environment variable is not set.")
        self.client = OpenAI(api_key=api_key)
        self.model = model
        self.history: list[dict] = [{"role": "system", "content": SYSTEM_PROMPT}]

    def chat(self, user_message: str) -> str:
        """Send a message and return the assistant's reply."""
        self.history.append({"role": "user", "content": user_message})
        response = self.client.chat.completions.create(
            model=self.model,
            messages=self.history,
        )
        reply = response.choices[0].message.content or ""
        self.history.append({"role": "assistant", "content": reply})
        return reply

    def reset(self) -> None:
        """Clear conversation history."""
        self.history = [{"role": "system", "content": SYSTEM_PROMPT}]


# ---------------------------------------------------------------------------
# Main — interactive REPL
# ---------------------------------------------------------------------------
def main() -> None:
    agent = AIAgent(api_key=OPENAI_API_KEY)
    print("lippytm AI Agent (Python) — type 'quit' to exit, 'reset' to clear history\n")
    while True:
        try:
            user_input = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break
        if not user_input:
            continue
        if user_input.lower() == "quit":
            print("Goodbye!")
            break
        if user_input.lower() == "reset":
            agent.reset()
            print("Conversation history cleared.\n")
            continue
        reply = agent.chat(user_input)
        print(f"Agent: {reply}\n")


if __name__ == "__main__":
    main()
