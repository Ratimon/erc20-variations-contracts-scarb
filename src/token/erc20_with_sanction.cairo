#[starknet::contract]
mod ERC20WithSanction {

    use starknet:: {ContractAddress, get_caller_address} ;

    use openzeppelin::token::erc20::interface::IERC20;
    use openzeppelin::token::erc20::erc20::ERC20;

    use openzeppelin::access::accesscontrol::interface::IAccessControl;
    use openzeppelin::access::accesscontrol::accesscontrol::AccessControl;
    use openzeppelin::access::accesscontrol::DEFAULT_ADMIN_ROLE;

    use erc20_variations::token::interface::IERC20WithSanction;

    #[storage]
    struct Storage {
        _is_blacklist: LegacyMap<ContractAddress, bool>,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        admin: ContractAddress
    ) {
        let mut erc20_self = ERC20::unsafe_new_contract_state();
        ERC20::InternalImpl::initializer(ref erc20_self, name, symbol);
        let mut acess_control_self = AccessControl::unsafe_new_contract_state();
        AccessControl::InternalImpl::initializer(ref acess_control_self); 
        AccessControl::InternalImpl::_grant_role(ref acess_control_self, DEFAULT_ADMIN_ROLE, admin);
    }

    fn only_admin(self: @ContractState) {
        let access_control_self = AccessControl::unsafe_new_contract_state();
        let caller = get_caller_address();
        assert( AccessControl::AccessControlImpl::has_role(@access_control_self, DEFAULT_ADMIN_ROLE, caller ), 'ONLY_ADMIN');
    }

    fn only_not_blacklist(self: @ContractState) {
        let caller = get_caller_address();
        assert( !self._is_blacklist.read(caller), 'ON_BLACLKIST');
    }

    #[external(v0)]
    impl ERC20WithSanctionImpl of IERC20WithSanction<ContractState>{

        #[view]
        fn is_blacklist(self: @ContractState, address: ContractAddress) -> bool {
            self._is_blacklist.read(address)
        }

        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            only_admin(@self);
            let mut erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::InternalImpl::_mint(ref erc20_self, to, amount);
            true
        }

        fn add_to_blacklist(ref self: ContractState, blacklist: ContractAddress) -> bool {
            only_admin(@self);
            self._is_blacklist.write(blacklist, true);
            true
        }

        fn remove_from_blacklist(ref self: ContractState, blacklist: ContractAddress) -> bool {
            only_admin(@self);
            self._is_blacklist.write(blacklist, false);
            true
        }

    }

    #[external(v0)]
    impl ERC20Impl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::name(@erc20_self)
        }

        fn symbol(self: @ContractState) -> felt252 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::symbol(@erc20_self)
        }

        fn decimals(self: @ContractState) -> u8 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::decimals(@erc20_self)
        }

        fn total_supply(self: @ContractState) -> u256 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::total_supply(@erc20_self)
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::balance_of(@erc20_self, account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            let erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::allowance(@erc20_self, owner, spender)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            only_not_blacklist(@self);
            let mut erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::transfer(ref erc20_self, recipient, amount)
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            only_not_blacklist(@self);
            let mut erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::transfer_from(ref erc20_self, sender, recipient, amount)
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let mut erc20_self = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::approve(ref erc20_self, spender, amount)
        }
    }

    //
    // AccessControl
    //
    impl Access_ControlImpl of IAccessControl<ContractState>{

        fn has_role(self: @ContractState, role: felt252, account: ContractAddress) -> bool {
            let access_control_self = AccessControl::unsafe_new_contract_state();
            AccessControl::AccessControlImpl::has_role(@access_control_self, role, account)
        }

        fn get_role_admin(self: @ContractState, role: felt252) -> felt252 {
            let access_control_self = AccessControl::unsafe_new_contract_state();
            AccessControl::AccessControlImpl::get_role_admin(@access_control_self, role)
        }

        fn grant_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            let mut access_control_self = AccessControl::unsafe_new_contract_state();
            AccessControl::AccessControlImpl::grant_role(ref access_control_self, role, account)
        }

        fn revoke_role(ref self: ContractState, role: felt252, account: ContractAddress){
            let mut access_control_self = AccessControl::unsafe_new_contract_state();
            AccessControl::AccessControlImpl::revoke_role(ref access_control_self, role, account)
        } 
        fn renounce_role(ref self: ContractState, role: felt252, account: ContractAddress){
            let mut access_control_self = AccessControl::unsafe_new_contract_state();
            AccessControl::AccessControlImpl::renounce_role(ref access_control_self, role, account)
        }

    }

}