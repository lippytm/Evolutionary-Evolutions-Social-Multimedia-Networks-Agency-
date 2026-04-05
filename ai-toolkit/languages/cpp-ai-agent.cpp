/**
 * AI Agent Template — C++
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Requirements:
 *   sudo apt install libcurl4-openssl-dev nlohmann-json3-dev
 *   (or vcpkg install curl nlohmann-json)
 *
 * Compile:
 *   g++ -std=c++17 -o ai-agent cpp-ai-agent.cpp -lcurl
 *
 * Usage:
 *   OPENAI_API_KEY=sk-... ./ai-agent
 */

#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstdlib>
#include <curl/curl.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// ---------------------------------------------------------------------------
// CURL write callback
// ---------------------------------------------------------------------------
static size_t writeCallback(void* contents, size_t size, size_t nmemb, std::string* s) {
    size_t newLen = size * nmemb;
    s->append(static_cast<char*>(contents), newLen);
    return newLen;
}

// ---------------------------------------------------------------------------
// AIAgent
// ---------------------------------------------------------------------------
class AIAgent {
public:
    explicit AIAgent(const std::string& apiKey,
                     const std::string& model = "gpt-4o")
        : apiKey_(apiKey), model_(model) {
        if (apiKey_.empty()) {
            throw std::runtime_error("OPENAI_API_KEY environment variable is not set.");
        }
        reset();
    }

    std::string chat(const std::string& userMessage) {
        history_.push_back({{"role", "user"}, {"content", userMessage}});

        json requestBody = {
            {"model", model_},
            {"messages", history_}
        };

        std::string responseStr = postRequest(
            "https://api.openai.com/v1/chat/completions",
            requestBody.dump()
        );

        json response = json::parse(responseStr);
        std::string reply = response["choices"][0]["message"]["content"];
        history_.push_back({{"role", "assistant"}, {"content", reply}});
        return reply;
    }

    void reset() {
        history_.clear();
        history_.push_back({
            {"role", "system"},
            {"content",
             "You are an AI agent in the lippytm ecosystem. "
             "You help users learn programming, blockchain development, and build AI applications. "
             "Be concise, educational, and practical."}
        });
    }

private:
    std::string apiKey_;
    std::string model_;
    json history_ = json::array();

    std::string postRequest(const std::string& url, const std::string& payload) {
        CURL* curl = curl_easy_init();
        std::string response;
        if (!curl) throw std::runtime_error("Failed to initialize CURL.");

        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, "Content-Type: application/json");
        std::string authHeader = "Authorization: Bearer " + apiKey_;
        headers = curl_slist_append(headers, authHeader.c_str());

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

        CURLcode res = curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);

        if (res != CURLE_OK) {
            throw std::runtime_error(std::string("CURL error: ") + curl_easy_strerror(res));
        }
        return response;
    }
};

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
int main() {
    const char* rawKey = std::getenv("OPENAI_API_KEY");
    std::string apiKey = rawKey ? rawKey : "";
    const char* rawModel = std::getenv("OPENAI_MODEL");
    std::string model = rawModel ? rawModel : "gpt-4o";

    AIAgent agent(apiKey, model);
    std::cout << "lippytm AI Agent (C++) — type 'quit' to exit, 'reset' to clear history\n\n";

    std::string input;
    while (true) {
        std::cout << "You: ";
        if (!std::getline(std::cin, input)) break;
        if (input.empty()) continue;
        if (input == "quit") { std::cout << "Goodbye!\n"; break; }
        if (input == "reset") { agent.reset(); std::cout << "Conversation history cleared.\n\n"; continue; }

        std::string reply = agent.chat(input);
        std::cout << "Agent: " << reply << "\n\n";
    }
    return 0;
}
