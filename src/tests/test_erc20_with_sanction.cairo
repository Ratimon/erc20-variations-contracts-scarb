use starknet::testing::{set_caller_address, set_contract_address};
use starknet::syscalls::deploy_syscall;
use starknet::{contract_address_const, ContractAddress, TryInto, Into, OptionTrait};
use result::ResultTrait;
use debug::PrintTrait;
use serde::Serde;

use openzeppelin::account::account::Account;

// Contracts
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::ERC20Impl;

const NAME: felt252 = 'NAME';
const SYMBOL: felt252 = 'SYMBOL';

#[derive(Drop)]
struct Signers {
    owner: ContractAddress,
    receiver: ContractAddress,
}

//
// Setup
//


// fn setup() -> ERC20WithSanction::ContractState {
//     let mut state = STATE();
//     ERC20WithSanction::constructor(ref state, NAME, SYMBOL);
//     state
// }

fn deploy_account(public_key: felt252) -> ContractAddress {
    let mut calldata = array![public_key];
    let (address, _) = deploy_syscall(
        Account::TEST_CLASS_HASH.try_into().expect('Account declare failed'),
        0,
        calldata.span(),
        false
    ).expect('Account deploy failed');
    
    address
}

fn STATE() -> ERC20WithSanction::ContractState {
    ERC20WithSanction::contract_state_for_testing()
}

fn setup() -> (Signers, ERC20WithSanction::ContractState) {
    let signers = Signers {
        owner: deploy_account('OWNER'),
        receiver: deploy_account('RECEIVER'),
    };
    let mut state = STATE();
    ERC20WithSanction::constructor(ref state, NAME, SYMBOL, signers.owner);
    (signers, state)
}

#[test]
#[available_gas(2000000)]
fn test_constructor() {
    // let mut state = STATE();
    // ERC20WithSanction::constructor(ref state, NAME, SYMBOL);
    let (signers, state) = setup();

    assert(ERC20Impl::name(@state) == NAME, 'Name should be NAME');
    assert(ERC20Impl::symbol(@state) == SYMBOL, 'Symbol should be SYMBOL');
}