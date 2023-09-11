use starknet::ContractAddress;


#[starknet::interface]
trait IERC20<TState> {
    fn name(self: @TState) -> felt252;
}