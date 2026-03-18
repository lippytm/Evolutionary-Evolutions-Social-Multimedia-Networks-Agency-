# AI Agent Template — Ruby
# Part of the lippytm AI Full-Stack Toolkit
# https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
#
# Requirements:
#   gem install ruby-openai
#
# Usage:
#   OPENAI_API_KEY=sk-... ruby ruby-ai-agent.rb

require "openai"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
OPENAI_API_KEY = ENV.fetch("OPENAI_API_KEY", "")
MODEL          = ENV.fetch("OPENAI_MODEL", "gpt-4o")
SYSTEM_PROMPT  = "You are an AI agent in the lippytm ecosystem. " \
                 "You help users learn programming, blockchain development, and build AI applications. " \
                 "Be concise, educational, and practical."

# ---------------------------------------------------------------------------
# AIAgent class
# ---------------------------------------------------------------------------
class AIAgent
  def initialize(api_key, model = MODEL)
    raise ArgumentError, "OPENAI_API_KEY environment variable is not set." if api_key.empty?

    @client  = OpenAI::Client.new(access_token: api_key)
    @model   = model
    reset
  end

  def chat(user_message)
    @history << { role: "user", content: user_message }

    response = @client.chat(
      parameters: {
        model:    @model,
        messages: @history
      }
    )

    reply = response.dig("choices", 0, "message", "content") || ""
    @history << { role: "assistant", content: reply }
    reply
  end

  def reset
    @history = [{ role: "system", content: SYSTEM_PROMPT }]
  end
end

# ---------------------------------------------------------------------------
# Main — interactive REPL
# ---------------------------------------------------------------------------
agent = AIAgent.new(OPENAI_API_KEY)
puts "lippytm AI Agent (Ruby) — type 'quit' to exit, 'reset' to clear history\n\n"

loop do
  print "You: "
  input = $stdin.gets&.chomp&.strip
  break if input.nil?
  next  if input.empty?

  case input.downcase
  when "quit"
    puts "Goodbye!"
    break
  when "reset"
    agent.reset
    puts "Conversation history cleared.\n\n"
  else
    reply = agent.chat(input)
    puts "Agent: #{reply}\n\n"
  end
end
