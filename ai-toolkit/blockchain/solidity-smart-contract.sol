// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LippytmAgencyRegistry
 * @notice AI Full-Stack Toolkit — Solidity Smart Contract Template
 * @dev Part of the lippytm ecosystem cross-platform blockchain layer.
 *      Stores a registry of agent registrations on-chain for transparency.
 *
 * Deployment (Hardhat):
 *   npx hardhat run scripts/deploy.js --network sepolia
 *
 * Repository:
 *   https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
 */

/**
 * @notice Minimal Ownable implementation (no external dependency needed).
 */
abstract contract Ownable {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert OwnableInvalidOwner(address(0));
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert OwnableUnauthorizedAccount(msg.sender);
        _;
    }

    function owner() public view returns (address) { return _owner; }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert OwnableInvalidOwner(address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LippytmAgencyRegistry is Ownable {

    // -----------------------------------------------------------------------
    // Data structures
    // -----------------------------------------------------------------------

    struct Agent {
        string  name;
        string  repoUrl;
        address registrant;
        uint256 registeredAt;
        bool    active;
    }

    // -----------------------------------------------------------------------
    // State
    // -----------------------------------------------------------------------

    mapping(bytes32 => Agent) private _agents;
    bytes32[] private _agentIds;

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event AgentRegistered(bytes32 indexed agentId, string name, address indexed registrant);
    event AgentDeactivated(bytes32 indexed agentId);
    event AgentReactivated(bytes32 indexed agentId);

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor() Ownable(msg.sender) {}

    // -----------------------------------------------------------------------
    // Write functions
    // -----------------------------------------------------------------------

    /**
     * @notice Register a new AI agent in the on-chain registry.
     * @param name     Human-readable name for the agent.
     * @param repoUrl  GitHub repository URL for the agent's code.
     */
    function registerAgent(string calldata name, string calldata repoUrl) external returns (bytes32 agentId) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(repoUrl).length > 0, "Repo URL cannot be empty");

        agentId = keccak256(abi.encodePacked(msg.sender, name, block.timestamp));
        require(_agents[agentId].registeredAt == 0, "Agent already registered");

        _agents[agentId] = Agent({
            name:         name,
            repoUrl:      repoUrl,
            registrant:   msg.sender,
            registeredAt: block.timestamp,
            active:       true
        });
        _agentIds.push(agentId);

        emit AgentRegistered(agentId, name, msg.sender);
    }

    /**
     * @notice Deactivate an agent (owner or registrant only).
     */
    function deactivateAgent(bytes32 agentId) external {
        Agent storage agent = _agents[agentId];
        require(agent.registeredAt != 0, "Agent not found");
        require(
            msg.sender == agent.registrant || msg.sender == owner(),
            "Not authorized"
        );
        agent.active = false;
        emit AgentDeactivated(agentId);
    }

    /**
     * @notice Reactivate an agent (owner only).
     */
    function reactivateAgent(bytes32 agentId) external onlyOwner {
        require(_agents[agentId].registeredAt != 0, "Agent not found");
        _agents[agentId].active = true;
        emit AgentReactivated(agentId);
    }

    // -----------------------------------------------------------------------
    // Read functions
    // -----------------------------------------------------------------------

    function getAgent(bytes32 agentId) external view returns (Agent memory) {
        require(_agents[agentId].registeredAt != 0, "Agent not found");
        return _agents[agentId];
    }

    function getTotalAgents() external view returns (uint256) {
        return _agentIds.length;
    }

    function getAgentIdAt(uint256 index) external view returns (bytes32) {
        require(index < _agentIds.length, "Index out of bounds");
        return _agentIds[index];
    }
}
