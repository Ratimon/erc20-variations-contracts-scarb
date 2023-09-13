use starknet::ContractAddress;

#[starknet::interface]
trait IERC20WithSanction<TState> {
    fn mint(ref self: TState, to: ContractAddress, amount: u256) -> bool;

    fn add_to_blacklist(ref self: TState, blacklist: ContractAddress) -> bool;

    fn remove_from_blacklist(ref self: TState, blacklist: ContractAddress) -> bool;

}