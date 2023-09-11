


use openzeppelin::account::account::Account;
use openzeppelin::token::erc20::ERC20::InternalImpl;
// use openzeppelin::token::erc20::ERC20::ERC20Impl;
use openzeppelin::token::erc20::ERC20;


    // Contracts
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction;
use erc20_variations::token::erc20_with_sanction::ERC20WithSanction::ERC20Impl;

// use erc20_variations::token::erc20_with_sanction::InternalImpl;

const NAME: felt252 = 'NAME';
const SYMBOL: felt252 = 'SYMBOL';


//
// Setup
//

fn STATE() -> ERC20WithSanction::ContractState {
    ERC20WithSanction::contract_state_for_testing()
}

fn setup() -> ERC20WithSanction::ContractState {
    let mut state = STATE();
    ERC20WithSanction::constructor(ref state, NAME, SYMBOL);
    state
}

#[test]
#[available_gas(2000000)]
fn test_constructor() {
    let mut state = STATE();
    ERC20WithSanction::constructor(ref state, NAME, SYMBOL);

    assert(ERC20Impl::name(@state) == NAME, 'Name should be NAME');
}