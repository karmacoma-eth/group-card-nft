# Group Cards

An NFT contract that represents group cards, e.g. a birthday card signed by a collective of people. The messages are then
rendered on-chain, Loot-style.

Flow:

1. create a card with `mint(string calldata _cardName, address[] calldata signers)` (signers can be added after the card creation with `auth(uint256 id, address signer)`)
2. each authorized signer can add a message with `etch(uint256 id, string calldata message, string calldata signedBy)` (calling `etch` again updates the message)
3. the initiator of the card can then call `seal(uint256 id)`, after which messages can no longer be added
4. the card can now be transferred to the recipient

Note that the address that minted the card is also implicitly an authorized signer, it does not need to be explicitly added to the `signers` array or `auth`'ed.


## Deployments

- mumbai: [0xdA9b46E5E3C0D593b79E0D165a5b4a36Ef1d6053](https://mumbai.polygonscan.com/address/0xda9b46e5e3c0d593b79e0d165a5b4a36ef1d6053#readContract)
- polygon: [0x13364356624F8883980636C87d01FD29bFab635a](https://polygonscan.com/address/0x13364356624f8883980636c87d01fd29bfab635a)


## Deploy

```sh
forge script script/GroupCardDeploy.sol --broadcast --ledger --sender $ETH_FROM --mnemonic-indexes 1 --rpc-url $RPC_URL -vvv
```

## Verify

```sh
forge script script/GroupCardDeploy.sol --verify --etherscan-api-key $ETHERSCAN_API_KEY --rpc-url $RPC_URL
```

## Troubleshooting

### Transaction underpriced

If deploying to mumbai/polygon fails with:

```
Error:
ProviderError(JsonRpcError(JsonRpcError { code: -32000, message: "transaction underpriced", data: None }))
```

-> try deploying with `--legacy` as a [workaround](https://github.com/foundry-rs/foundry/issues/1703)


### Header not found

If deploying fails with:

```
Message:  Failed to get account for 0x0343…65d7
ProviderError(JsonRpcError(JsonRpcError { code: -32000, message: "header not found", data: None }))
Location: evm/src/executor/fork/backend.rs:263
```

-> are you using Infura? Try switching to a different RPC provider
