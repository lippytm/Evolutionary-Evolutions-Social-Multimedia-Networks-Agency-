// AI Agent Template — Rust
// Part of the lippytm AI Full-Stack Toolkit
// https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
//
// Requirements (Cargo.toml):
//   [dependencies]
//   async-openai = "0.23"
//   tokio = { version = "1", features = ["full"] }
//
// Usage:
//   OPENAI_API_KEY=sk-... cargo run

use std::io::{self, BufRead, Write};

use async_openai::{
    config::OpenAIConfig,
    types::{
        ChatCompletionRequestMessage, ChatCompletionRequestSystemMessageArgs,
        ChatCompletionRequestUserMessageArgs, CreateChatCompletionRequestArgs,
    },
    Client,
};

const DEFAULT_MODEL: &str = "gpt-4o";
const SYSTEM_PROMPT: &str = "You are an AI agent in the lippytm ecosystem. \
    You help users learn programming, blockchain development, and build AI applications. \
    Be concise, educational, and practical.";

struct AIAgent {
    client: Client<OpenAIConfig>,
    model: String,
    history: Vec<ChatCompletionRequestMessage>,
}

impl AIAgent {
    fn new(model: &str) -> Self {
        let system_msg = ChatCompletionRequestSystemMessageArgs::default()
            .content(SYSTEM_PROMPT)
            .build()
            .expect("Failed to build system message");

        AIAgent {
            client: Client::new(),
            model: model.to_string(),
            history: vec![ChatCompletionRequestMessage::System(system_msg)],
        }
    }

    async fn chat(&mut self, user_message: &str) -> Result<String, Box<dyn std::error::Error>> {
        let user_msg = ChatCompletionRequestUserMessageArgs::default()
            .content(user_message)
            .build()?;
        self.history.push(ChatCompletionRequestMessage::User(user_msg));

        let request = CreateChatCompletionRequestArgs::default()
            .model(&self.model)
            .messages(self.history.clone())
            .build()?;

        let response = self.client.chat().create(request).await?;
        let reply = response
            .choices
            .first()
            .and_then(|c| c.message.content.clone())
            .unwrap_or_default();

        let assistant_msg = async_openai::types::ChatCompletionRequestAssistantMessageArgs::default()
            .content(reply.as_str())
            .build()?;
        self.history
            .push(ChatCompletionRequestMessage::Assistant(assistant_msg));

        Ok(reply)
    }

    fn reset(&mut self) {
        let system_msg = ChatCompletionRequestSystemMessageArgs::default()
            .content(SYSTEM_PROMPT)
            .build()
            .expect("Failed to build system message");
        self.history = vec![ChatCompletionRequestMessage::System(system_msg)];
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let model = std::env::var("OPENAI_MODEL").unwrap_or_else(|_| DEFAULT_MODEL.to_string());
    let mut agent = AIAgent::new(&model);

    println!("lippytm AI Agent (Rust) — type 'quit' to exit, 'reset' to clear history\n");

    let stdin = io::stdin();
    let stdout = io::stdout();

    for line in stdin.lock().lines() {
        let text = line?.trim().to_string();
        if text.is_empty() {
            continue;
        }
        match text.to_lowercase().as_str() {
            "quit" => {
                println!("Goodbye!");
                break;
            }
            "reset" => {
                agent.reset();
                println!("Conversation history cleared.\n");
                continue;
            }
            _ => {}
        }

        match agent.chat(&text).await {
            Ok(reply) => println!("Agent: {}\n", reply),
            Err(e) => eprintln!("Error: {}", e),
        }

        print!("You: ");
        stdout.lock().flush()?;
    }

    Ok(())
}
