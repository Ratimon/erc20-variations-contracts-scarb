
katana-node:
	katana --accounts 3 --seed 0 --gas-price 250

declare:
	starkli declare target/dev/erc20_variations_ERC20WithSanction.sierra.json --compiler-version 2.1.0 --rpc http://0.0.0.0:5050 --account ~/.starkli-wallets/deployer/account1_account.json --keystore ~/.starkli-wallets/deployer/account1_keystore.json

deploy:
	starkli deploy 0x0594a043fc6d2ca85122b8c1cdc48172f7b509ab1b885168f6c27a36c8c2e8d3 str:NAME str:SYMBOL 0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973 --rpc http://0.0.0.0:5050 --account ~/.starkli-wallets/deployer/account1_account.json --keystore ~/.starkli-wallets/deployer/account1_keystore.json


