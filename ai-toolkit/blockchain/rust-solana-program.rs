// AI Agent Registry — Rust (Solana Program)
// Part of the lippytm AI Full-Stack Toolkit
// https://github.com/lippytm/Evolutionary-Evolutions-Social-Multimedia-Networks-Agency-
//
// Requirements (Cargo.toml):
//   [dependencies]
//   solana-program = "1.18"
//   borsh = "1"
//
// Build & Deploy:
//   cargo build-sbf
//   solana program deploy target/deploy/agent_registry.so

use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
    clock::Clock,
    sysvar::Sysvar,
};

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct AgentRecord {
    pub is_initialized: bool,
    pub name: String,
    pub repo_url: String,
    pub registrant: Pubkey,
    pub registered_at: i64,
    pub active: bool,
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub enum AgentInstruction {
    /// Register a new agent
    /// Accounts: [writable agent_account, signer registrant]
    Register { name: String, repo_url: String },

    /// Deactivate an agent
    /// Accounts: [writable agent_account, signer registrant]
    Deactivate,
}

// ---------------------------------------------------------------------------
// Entrypoint
// ---------------------------------------------------------------------------

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = AgentInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        AgentInstruction::Register { name, repo_url } => {
            process_register(program_id, accounts, name, repo_url)
        }
        AgentInstruction::Deactivate => process_deactivate(program_id, accounts),
    }
}

// ---------------------------------------------------------------------------
// Handlers
// ---------------------------------------------------------------------------

fn process_register(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
    name: String,
    repo_url: String,
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let agent_account = next_account_info(accounts_iter)?;
    let registrant = next_account_info(accounts_iter)?;

    if !registrant.is_signer {
        return Err(ProgramError::MissingRequiredSignature);
    }

    let clock = Clock::get()?;

    let record = AgentRecord {
        is_initialized: true,
        name,
        repo_url,
        registrant: *registrant.key,
        registered_at: clock.unix_timestamp,
        active: true,
    };

    record.serialize(&mut &mut agent_account.data.borrow_mut()[..])?;
    msg!("Agent registered: {}", record.name);
    Ok(())
}

fn process_deactivate(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let agent_account = next_account_info(accounts_iter)?;
    let registrant = next_account_info(accounts_iter)?;

    if !registrant.is_signer {
        return Err(ProgramError::MissingRequiredSignature);
    }

    let mut record = AgentRecord::try_from_slice(&agent_account.data.borrow())?;
    if record.registrant != *registrant.key {
        return Err(ProgramError::IllegalOwner);
    }

    record.active = false;
    record.serialize(&mut &mut agent_account.data.borrow_mut()[..])?;
    msg!("Agent deactivated.");
    Ok(())
}
