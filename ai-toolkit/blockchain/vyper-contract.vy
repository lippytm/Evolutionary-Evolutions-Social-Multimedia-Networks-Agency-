# @version 0.3.10
# SPDX-License-Identifier: MIT
"""
@title LippytmAgencyRegistryVyper
@notice AI Full-Stack Toolkit — Vyper Smart Contract Template
@dev Security-focused EVM contract for the lippytm cross-platform blockchain layer.
     Stores a registry of AI agent registrations on-chain.

Repository:
    https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-

Deploy (Brownie):
    brownie run scripts/deploy.py --network sepolia
"""

# ---------------------------------------------------------------------------
# Structs
# ---------------------------------------------------------------------------

struct Agent:
    name: String[128]
    repo_url: String[256]
    registrant: address
    registered_at: uint256
    active: bool

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

owner: public(address)
agents: public(HashMap[bytes32, Agent])
agent_count: public(uint256)

# ---------------------------------------------------------------------------
# Events
# ---------------------------------------------------------------------------

event AgentRegistered:
    agent_id: indexed(bytes32)
    name: String[128]
    registrant: indexed(address)

event AgentDeactivated:
    agent_id: indexed(bytes32)

event OwnershipTransferred:
    previous_owner: indexed(address)
    new_owner: indexed(address)

# ---------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------

@deploy
def __init__():
    self.owner = msg.sender
    self.agent_count = 0

# ---------------------------------------------------------------------------
# Modifiers (implemented inline in Vyper)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# External functions
# ---------------------------------------------------------------------------

@external
def register_agent(name: String[128], repo_url: String[256]) -> bytes32:
    """
    @notice Register a new AI agent in the on-chain registry.
    @param name     Human-readable name for the agent.
    @param repo_url GitHub repository URL for the agent's code.
    @return agent_id Unique identifier for the registered agent.
    """
    assert len(name) > 0, "Name cannot be empty"
    assert len(repo_url) > 0, "Repo URL cannot be empty"

    agent_id: bytes32 = keccak256(
        concat(
            convert(msg.sender, bytes32),
            convert(len(name), bytes32),
            block.timestamp.to_bytes(32, "big")
        )
    )
    assert self.agents[agent_id].registered_at == 0, "Agent already registered"

    self.agents[agent_id] = Agent({
        name: name,
        repo_url: repo_url,
        registrant: msg.sender,
        registered_at: block.timestamp,
        active: True
    })
    self.agent_count += 1

    log AgentRegistered(agent_id, name, msg.sender)
    return agent_id


@external
def deactivate_agent(agent_id: bytes32):
    """
    @notice Deactivate an agent (registrant or owner only).
    """
    agent: Agent = self.agents[agent_id]
    assert agent.registered_at != 0, "Agent not found"
    assert msg.sender == agent.registrant or msg.sender == self.owner, "Not authorized"

    self.agents[agent_id].active = False
    log AgentDeactivated(agent_id)


@external
def transfer_ownership(new_owner: address):
    """
    @notice Transfer contract ownership.
    """
    assert msg.sender == self.owner, "Not owner"
    assert new_owner != empty(address), "Invalid owner"
    log OwnershipTransferred(self.owner, new_owner)
    self.owner = new_owner


# ---------------------------------------------------------------------------
# View functions
# ---------------------------------------------------------------------------

@view
@external
def get_agent(agent_id: bytes32) -> Agent:
    assert self.agents[agent_id].registered_at != 0, "Agent not found"
    return self.agents[agent_id]
