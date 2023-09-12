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
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::ERC20Impl;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::Access_Control;

const NAME: felt252 = 'NAME';
const SYMBOL: felt252 = 'SYMBOL';

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
    assert(Access_Control::has_role(@state, DEFAULT_ADMIN_ROLE, signers.owner), 'should not have role');
}

#[test]
#[available_gas(2000000)]
fn test_grant_role() {
    let (signers, mut state) = setup();
    set_caller_address(signers.owner);
    Access_Control::grant_role(ref state, DEFAULT_ADMIN_ROLE, signers.user1);
   
}


#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Caller is missing role',))]
fn test_grant_role_revert_when_role_unauthorized() {
    let (signers, mut state) = setup();
    set_caller_address(signers.user1);
    Access_Control::grant_role(ref state, DEFAULT_ADMIN_ROLE, signers.user1);

}