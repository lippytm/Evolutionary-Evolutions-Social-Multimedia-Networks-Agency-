/**
 * AI Agent Template — Java
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements (Maven pom.xml):
 *   <dependency>
 *     <groupId>com.theokanning.openai-gpt3-java</groupId>
 *     <artifactId>service</artifactId>
 *     <version>0.18.2</version>
 *   </dependency>
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... mvn exec:java -Dexec.mainClass="AIAgent"
 */

import com.theokanning.openai.completion.chat.ChatCompletionRequest;
import com.theokanning.openai.completion.chat.ChatMessage;
import com.theokanning.openai.completion.chat.ChatMessageRole;
import com.theokanning.openai.service.OpenAiService;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class AIAgent {

    private static final String DEFAULT_MODEL = "gpt-4o";
    private static final String SYSTEM_PROMPT =
            "You are an AI agent in the lippytm ecosystem. " +
            "You help users learn programming, blockchain development, and build AI applications. " +
            "Be concise, educational, and practical.";

    private final OpenAiService service;
    private final String model;
    private final List<ChatMessage> history = new ArrayList<>();

    public AIAgent(String apiKey, String model) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalArgumentException("OPENAI_API_KEY environment variable is not set.");
        }
        this.service = new OpenAiService(apiKey);
        this.model = model;
        this.history.add(new ChatMessage(ChatMessageRole.SYSTEM.value(), SYSTEM_PROMPT));
    }

    public String chat(String userMessage) {
        history.add(new ChatMessage(ChatMessageRole.USER.value(), userMessage));

        ChatCompletionRequest request = ChatCompletionRequest.builder()
                .model(model)
                .messages(history)
                .build();

        String reply = service.createChatCompletion(request)
                .getChoices().get(0)
                .getMessage().getContent();

        history.add(new ChatMessage(ChatMessageRole.ASSISTANT.value(), reply));
        return reply;
    }

    public void reset() {
        history.clear();
        history.add(new ChatMessage(ChatMessageRole.SYSTEM.value(), SYSTEM_PROMPT));
    }

    public static void main(String[] args) {
        String apiKey = System.getenv("OPENAI_API_KEY");
        String model = System.getenv().getOrDefault("OPENAI_MODEL", DEFAULT_MODEL);

        AIAgent agent = new AIAgent(apiKey, model);
        Scanner scanner = new Scanner(System.in);

        System.out.println("lippytm AI Agent (Java) — type 'quit' to exit, 'reset' to clear history\n");

        while (true) {
            System.out.print("You: ");
            if (!scanner.hasNextLine()) break;
            String input = scanner.nextLine().trim();
            if (input.isEmpty()) continue;
            if (input.equalsIgnoreCase("quit")) {
                System.out.println("Goodbye!");
                break;
            }
            if (input.equalsIgnoreCase("reset")) {
                agent.reset();
                System.out.println("Conversation history cleared.\n");
                continue;
            }
            String reply = agent.chat(input);
            System.out.println("Agent: " + reply + "\n");
        }
        scanner.close();
    }
}
