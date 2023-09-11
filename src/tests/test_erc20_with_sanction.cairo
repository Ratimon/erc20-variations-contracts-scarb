// #[cfg(test)]
// mod Test {
//     // Starknet deps
//     use starknet::ContractAddress;
//     use starknet::deploy_syscall;
//     use starknet::testing::set_contract_address;

//     use openzeppelin::account::account::Account;

//     // Contracts
//     use erc20_variations::ERC20WithSanction;

//     const NAME: felt252 = 'NAME';
//     const SYMBOL: felt252 = 'SYMBOL';

//     #[derive(Drop)]
//     struct Signers {
//         owner: ContractAddress,
//         receiver: ContractAddress,
//         new_receiver: ContractAddress,
//     }

//     #[derive(Drop)]
//     struct Contracts {
//         preset: ContractAddress,
//     }

//     fn deploy_account(public_key: felt252) -> ContractAddress {
//         let mut calldata = array![public_key];
//         let (address, _) = deploy_syscall(
//             Account::TEST_CLASS_HASH.try_into().expect('Account declare failed'),
//             0,
//             calldata.span(),
//             false
//         )
//             .expect('Account deploy failed');
//         address
//     }

// }
