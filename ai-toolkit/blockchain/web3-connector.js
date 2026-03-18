/**
 * Web3 Connector — JavaScript (ethers.js v6)
 * Part of the lippytm AI Full-Stack Toolkit
 * https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 *
 * Connects your frontend/backend to EVM-compatible blockchains and the
 * LippytmAgencyRegistry smart contract.
 *
 * Requirements:
 *   npm install ethers dotenv
 *
 * Usage (Node.js):
 *   ETH_SEPOLIA_RPC_URL=https://... WALLET_PRIVATE_KEY=0x... node web3-connector.js
 */

"use strict";

const { ethers } = require("ethers");

// ---------------------------------------------------------------------------
// Configuration — load from environment variables
// ---------------------------------------------------------------------------
const RPC_URL     = process.env.ETH_SEPOLIA_RPC_URL  || "";
const PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY   || "";

// Minimal ABI for LippytmAgencyRegistry (matches solidity-smart-contract.sol)
const REGISTRY_ABI = [
  "function registerAgent(string name, string repoUrl) external returns (bytes32)",
  "function deactivateAgent(bytes32 agentId) external",
  "function getAgent(bytes32 agentId) external view returns (tuple(string name, string repoUrl, address registrant, uint256 registeredAt, bool active))",
  "function getTotalAgents() external view returns (uint256)",
  "function getAgentIdAt(uint256 index) external view returns (bytes32)",
  "event AgentRegistered(bytes32 indexed agentId, string name, address indexed registrant)",
  "event AgentDeactivated(bytes32 indexed agentId)",
];

// ---------------------------------------------------------------------------
// Web3Connector class
// ---------------------------------------------------------------------------
class Web3Connector {
  /**
   * @param {string} rpcUrl         - JSON-RPC provider URL
   * @param {string} privateKey     - Wallet private key (hex, with 0x prefix)
   * @param {string} [contractAddr] - Deployed registry contract address
   */
  constructor(rpcUrl, privateKey, contractAddr = "") {
    if (!rpcUrl) throw new Error("ETH_SEPOLIA_RPC_URL environment variable is not set.");

    this.provider = new ethers.JsonRpcProvider(rpcUrl);

    if (privateKey) {
      this.wallet = new ethers.Wallet(privateKey, this.provider);
    }

    if (contractAddr) {
      this.registry = new ethers.Contract(
        contractAddr,
        REGISTRY_ABI,
        this.wallet || this.provider
      );
    }
  }

  // -------------------------------------------------------------------------
  // Network helpers
  // -------------------------------------------------------------------------

  async getNetwork() {
    const net = await this.provider.getNetwork();
    return { name: net.name, chainId: net.chainId.toString() };
  }

  async getBalance(address) {
    const bal = await this.provider.getBalance(address);
    return ethers.formatEther(bal);
  }

  // -------------------------------------------------------------------------
  // Registry interactions
  // -------------------------------------------------------------------------

  async registerAgent(name, repoUrl) {
    if (!this.registry) throw new Error("No registry contract address set.");
    const tx = await this.registry.registerAgent(name, repoUrl);
    console.log(`Transaction sent: ${tx.hash}`);
    const receipt = await tx.wait();
    console.log(`Confirmed in block ${receipt.blockNumber}`);

    const event = receipt.logs
      .map((log) => { try { return this.registry.interface.parseLog(log); } catch { return null; } })
      .find((e) => e && e.name === "AgentRegistered");

    return event ? event.args.agentId : null;
  }

  async getAgent(agentId) {
    if (!this.registry) throw new Error("No registry contract address set.");
    const agent = await this.registry.getAgent(agentId);
    return {
      name:         agent[0],
      repoUrl:      agent[1],
      registrant:   agent[2],
      registeredAt: new Date(Number(agent[3]) * 1000).toISOString(),
      active:       agent[4],
    };
  }

  async getTotalAgents() {
    if (!this.registry) throw new Error("No registry contract address set.");
    const total = await this.registry.getTotalAgents();
    return Number(total);
  }

  // -------------------------------------------------------------------------
  // Event listener
  // -------------------------------------------------------------------------

  listenForRegistrations(callback) {
    if (!this.registry) throw new Error("No registry contract address set.");
    this.registry.on("AgentRegistered", (agentId, name, registrant, event) => {
      callback({ agentId, name, registrant, blockNumber: event.log.blockNumber });
    });
    console.log("Listening for AgentRegistered events...");
  }
}

// ---------------------------------------------------------------------------
// Demo / CLI usage
// ---------------------------------------------------------------------------
async function main() {
  if (!RPC_URL) {
    console.error("Set ETH_SEPOLIA_RPC_URL in your environment and re-run.");
    process.exit(1);
  }

  const connector = new Web3Connector(RPC_URL, PRIVATE_KEY);
  const network   = await connector.getNetwork();
  console.log(`Connected to network: ${network.name} (chainId ${network.chainId})`);

  if (PRIVATE_KEY) {
    const balance = await connector.getBalance(connector.wallet.address);
    console.log(`Wallet: ${connector.wallet.address}  Balance: ${balance} ETH`);
  }

  console.log("\nWeb3 connector ready. Set REGISTRY_CONTRACT_ADDRESS and call registerAgent().");
}

module.exports = { Web3Connector };

if (require.main === module) {
  main().catch(console.error);
}
