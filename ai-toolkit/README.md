# AI Full-Stack Toolkit

> **Ready-to-use AI agent templates for every major programming language and blockchain platform.**
> Part of the [lippytm Ecosystem](https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-).

---

## Overview

This toolkit gives you a working starting point to build AI-powered applications in any language. Each template:

- Connects to the OpenAI API (or any LLM)
- Follows best practices for that language
- Can be dropped into your existing project immediately
- Integrates with the lippytm cross-platform hub

---

## 🖥️ Computer Language Templates

| File | Language | Use Case |
|---|---|---|
| `languages/python-ai-agent.py` | Python | General AI agent, automation, data science |
| `languages/javascript-ai-agent.js` | JavaScript (Node.js) | Web backends, bots, serverless |
| `languages/typescript-ai-agent.ts` | TypeScript | Type-safe Node.js / Deno AI apps |
| `languages/go-ai-agent.go` | Go | High-performance concurrent AI services |
| `languages/rust-ai-agent.rs` | Rust | Systems-level, high-efficiency AI agents |
| `languages/java-ai-agent.java` | Java | Enterprise AI applications |
| `languages/csharp-ai-agent.cs` | C# (.NET) | .NET AI agents and Azure integrations |
| `languages/cpp-ai-agent.cpp` | C++ | Embedded AI, robotics, low-level systems |
| `languages/ruby-ai-agent.rb` | Ruby | Rails apps, scripting, rapid prototyping |
| `languages/php-ai-agent.php` | PHP | WordPress plugins, web APIs |

---

## ⛓️ Blockchain Language Templates

| File | Language/Platform | Use Case |
|---|---|---|
| `blockchain/solidity-smart-contract.sol` | Solidity (EVM) | Ethereum, Polygon, BNB Chain contracts |
| `blockchain/rust-solana-program.rs` | Rust (Solana) | Solana programs / on-chain logic |
| `blockchain/vyper-contract.vy` | Vyper (EVM) | Security-focused EVM smart contracts |
| `blockchain/move-aptos-module.move` | Move (Aptos/Sui) | Aptos and Sui blockchain modules |
| `blockchain/web3-connector.js` | JavaScript + Web3 | Frontend/backend Web3 dApp connector |

---

## 🚀 Quick Start

1. Copy the template for your language
2. Set your `OPENAI_API_KEY` environment variable (or substitute your LLM provider)
3. Run the template in your environment:

```bash
# Python
pip install openai
python languages/python-ai-agent.py

# Node.js / JavaScript
npm install openai
node languages/javascript-ai-agent.js

# TypeScript
npm install openai tsx
npx tsx languages/typescript-ai-agent.ts

# Go
go run languages/go-ai-agent.go

# Rust
cargo run --manifest-path languages/Cargo.toml
```

---

## 🔐 Environment Variables

All templates use the following environment variables (set in your shell or `.env` file):

```
OPENAI_API_KEY=sk-...           # Required for all AI templates
ETH_MAINNET_RPC_URL=https://... # Required for blockchain templates (Ethereum)
ETH_SEPOLIA_RPC_URL=https://... # Required for blockchain testnet templates
WALLET_PRIVATE_KEY=0x...        # Required for blockchain signing (use a dev wallet only!)
```

> ⚠️ **Security**: Never commit your `.env` file or private keys to version control.
> Add `.env` to your `.gitignore`.

---

## 🤝 Integration with lippytm Ecosystem

Every template includes a section showing how to connect back to the central agency hub.
See [`../cross-platform/api-bridge-config.json`](../cross-platform/api-bridge-config.json) for full platform connection details.
