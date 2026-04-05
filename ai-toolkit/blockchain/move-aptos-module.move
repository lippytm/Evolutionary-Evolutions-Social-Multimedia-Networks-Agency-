/// AI Agent Registry — Move Module (Aptos)
/// Part of the lippytm AI Full-Stack Toolkit
/// https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
///
/// Deploy (Aptos CLI):
///   aptos move publish --named-addresses lippytm_agency=<YOUR_ADDRESS>
///
/// Call:
///   aptos move run --function-id <ADDRESS>::agent_registry::register_agent \
///     --args string:"MyAgent" string:"https://github.com/lippytm/..."

module lippytm_agency::agent_registry {
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event;
    use aptos_framework::account;

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_AGENT_NOT_FOUND: u64 = 3;
    const E_NOT_AUTHORIZED: u64 = 4;
    const E_EMPTY_STRING: u64 = 5;

    // -----------------------------------------------------------------------
    // Structs
    // -----------------------------------------------------------------------

    struct AgentRecord has store, drop, copy {
        name: String,
        repo_url: String,
        registrant: address,
        registered_at: u64,
        active: bool,
    }

    struct AgentRegistry has key {
        agents: vector<AgentRecord>,
        register_events: event::EventHandle<AgentRegisteredEvent>,
        deactivate_events: event::EventHandle<AgentDeactivatedEvent>,
    }

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    struct AgentRegisteredEvent has drop, store {
        name: String,
        registrant: address,
        index: u64,
    }

    struct AgentDeactivatedEvent has drop, store {
        index: u64,
    }

    // -----------------------------------------------------------------------
    // Initialization
    // -----------------------------------------------------------------------

    /// Initialize the registry under the deployer's account.
    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<AgentRegistry>(addr), E_ALREADY_INITIALIZED);

        move_to(account, AgentRegistry {
            agents: vector::empty<AgentRecord>(),
            register_events: account::new_event_handle<AgentRegisteredEvent>(account),
            deactivate_events: account::new_event_handle<AgentDeactivatedEvent>(account),
        });
    }

    // -----------------------------------------------------------------------
    // Write functions
    // -----------------------------------------------------------------------

    /// Register a new AI agent.
    public entry fun register_agent(
        caller: &signer,
        registry_addr: address,
        name: String,
        repo_url: String,
    ) acquires AgentRegistry {
        assert!(exists<AgentRegistry>(registry_addr), E_NOT_INITIALIZED);
        assert!(string::length(&name) > 0, E_EMPTY_STRING);
        assert!(string::length(&repo_url) > 0, E_EMPTY_STRING);

        let registry = borrow_global_mut<AgentRegistry>(registry_addr);
        let index = vector::length(&registry.agents);

        vector::push_back(&mut registry.agents, AgentRecord {
            name,
            repo_url,
            registrant: signer::address_of(caller),
            registered_at: timestamp::now_seconds(),
            active: true,
        });

        event::emit_event(&mut registry.register_events, AgentRegisteredEvent {
            name,
            registrant: signer::address_of(caller),
            index,
        });
    }

    /// Deactivate an agent by index (registrant only).
    public entry fun deactivate_agent(
        caller: &signer,
        registry_addr: address,
        index: u64,
    ) acquires AgentRegistry {
        assert!(exists<AgentRegistry>(registry_addr), E_NOT_INITIALIZED);

        let registry = borrow_global_mut<AgentRegistry>(registry_addr);
        assert!(index < vector::length(&registry.agents), E_AGENT_NOT_FOUND);

        let agent = vector::borrow_mut(&mut registry.agents, index);
        assert!(agent.registrant == signer::address_of(caller), E_NOT_AUTHORIZED);

        agent.active = false;
        event::emit_event(&mut registry.deactivate_events, AgentDeactivatedEvent { index });
    }

    // -----------------------------------------------------------------------
    // View functions
    // -----------------------------------------------------------------------

    #[view]
    public fun get_agent_count(registry_addr: address): u64 acquires AgentRegistry {
        assert!(exists<AgentRegistry>(registry_addr), E_NOT_INITIALIZED);
        vector::length(&borrow_global<AgentRegistry>(registry_addr).agents)
    }

    #[view]
    public fun get_agent(registry_addr: address, index: u64): AgentRecord acquires AgentRegistry {
        assert!(exists<AgentRegistry>(registry_addr), E_NOT_INITIALIZED);
        let registry = borrow_global<AgentRegistry>(registry_addr);
        assert!(index < vector::length(&registry.agents), E_AGENT_NOT_FOUND);
        *vector::borrow(&registry.agents, index)
    }
}
