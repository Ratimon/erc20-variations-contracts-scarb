use starknet::testing::{set_caller_address, set_contract_address};
use starknet::syscalls::deploy_syscall;
use starknet::{contract_address_const, ContractAddress, TryInto, Into, OptionTrait};
use result::ResultTrait;
use debug::PrintTrait;
use serde::Serde;

use openzeppelin::account::account::Account;
use openzeppelin::access::accesscontrol::DEFAULT_ADMIN_ROLE;

// Contracts
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::ERC20WithSanctionImpl;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::ERC20Impl;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::Access_ControlImpl;

const NAME: felt252 = 'NAME';
const SYMBOL: felt252 = 'SYMBOL';
const VALUE: u256 = 300;

#[derive(Drop)]
struct Signers {
    owner: ContractAddress,
    user1: ContractAddress,
    user2: ContractAddress,
}

//
// Setup
//
fn STATE() -> ERC20WithSanction::ContractState {
    ERC20WithSanction::contract_state_for_testing()
}

fn setup() -> (Signers, ERC20WithSanction::ContractState) {
    let signers = Signers {
        owner: contract_address_const::<'OWNER'>(),
        user1: contract_address_const::<'USER1'>(),
        user2: contract_address_const::<'USER2'>(),
    };
    let mut state = STATE();
    set_caller_address(signers.owner);
    ERC20WithSanction::constructor(ref state, NAME, SYMBOL, signers.owner);
    (signers, state)
}

#[test]
#[available_gas(2000000)]
fn test_constructor() {
    let (signers, state) = setup();

    assert(ERC20Impl::name(@state) == NAME, 'Name should be NAME');
    assert(ERC20Impl::symbol(@state) == SYMBOL, 'Symbol should be SYMBOL');
    assert(Access_ControlImpl::has_role(@state, DEFAULT_ADMIN_ROLE, signers.owner), 'should not have role');
}

#[test]
#[available_gas(2000000)]
fn test_grant_role() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    Access_ControlImpl::grant_role(ref state, DEFAULT_ADMIN_ROLE, signers.user1);
   
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Caller is missing role',))]
fn test_revert_when_role_unauthorized_grant_role() {
    let (signers, mut state) = setup();
    set_caller_address(signers.user1);
    Access_ControlImpl::grant_role(ref state, DEFAULT_ADMIN_ROLE, signers.user1);
}

#[test]
#[available_gas(2000000)]
fn test_mint() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    ERC20WithSanctionImpl::mint(ref state, signers.user2, VALUE);
    assert(ERC20Impl::balance_of(@state, signers.user2) == VALUE, 'Should eq VALUE');
}

#[test]
#[available_gas(2000000)]
fn test_add_to_blacklist() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    assert(!ERC20WithSanctionImpl::is_blacklist(@state, signers.user1), 'Should return false');
    ERC20WithSanctionImpl::add_to_blacklist(ref state, signers.user1);
    assert(ERC20WithSanctionImpl::is_blacklist(@state, signers.user1), 'Should return true');
}

#[test]
#[available_gas(2000000)]
fn remove_from_blacklist() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    ERC20WithSanctionImpl::add_to_blacklist(ref state, signers.user1);
    assert(ERC20WithSanctionImpl::is_blacklist(@state, signers.user1), 'Should return true');
    ERC20WithSanctionImpl::remove_from_blacklist(ref state, signers.user1);
    assert(!ERC20WithSanctionImpl::is_blacklist(@state, signers.user1), 'Should return false');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ON_BLACLKIST',))]
fn test_revert_when_on_blacklist_transfer() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    ERC20WithSanctionImpl::mint(ref state, signers.user1, VALUE);
    ERC20WithSanctionImpl::add_to_blacklist(ref state, signers.user1);
    set_caller_address(signers.user1);
    ERC20Impl::transfer(ref state, signers.user2, VALUE);
}