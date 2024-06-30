# GAME Smart Contract

This is repository containing all smart contracts related to $GOME.

## Deployments

## Using the deployment script

You just need to run this:

```bash
./deploy.[local|sepolia|mainnet].sh -d [initial|merkle-root]
```

Deployment has two steps:
1. Setup initial contracts: it deploys all contracts
2. Set merkle root: it sets the merkle root at the token claim (airdrop) contract.

Before deployment, make sure you fill out these files:

```bash
.env.initial # for -d initial
.env.merkleroot # for -d merkle-root
```

Otherwise, the script won't work. You can copy the template from `.env.*.example` files.

### Local

Deploy locally to see if everything gets deployed locally without reverting after making any changes.

```bash
# launch anvil for local RPC
anvil

# open another terminal, and then run
chmod +x ./deploy.local.sh

cp .env.initial.example .env.initial
# then, fill out .env.initial
vim .env.initial
# then, deploy contracts
./deploy.local.sh -d initial

# later, you have your merkle root ready
cp .env.merkleroot.example .env.merkleroot
# then, fill out .env.merkleroot
vim .env.merkleroot
# then, set the merkle root
./deploy.local.sh -d merkle-root
```

### Sepolia

To deploy to Sepolia:

```bash
chmod +x ./deploy.sepolia.sh

cp .env.initial.example .env.initial
# then, fill out .env.initial
vim .env.initial
# then, deploy contracts
./deploy.sepolia.sh -d initial

# later, you have your merkle root ready
cp .env.merkleroot.example .env.merkleroot
# then, fill out .env.merkleroot
vim .env.merkleroot
# then, set the merkle root
./deploy.sepolia.sh -d merkle-root
```

### Mainnet

For mainnet, make sure your deployer account has some ETH in it. Also make sure you have correct environment variables in `.env.initial` because this costs real $$$ and the deployment is irreversible. In particular, you MUST make sure that these variables below:
```
OWNER_ADDRESS
LP_CREATOR_ADDRESS
GOME_SYMBOL
GOME_NAME
```
are correctly configured because they will be supplied as constructor arguments to the contracts.

Also, adjust 

```solidity
// @dev the amounts are subject to change before real deployment
// 10%
uint256 immutable LISTING_ALLOCATION = 1_000_000_000;
// 5%
uint256 immutable MARKETING_ALLOCATION = 500_000_000;
// 15%
uint256 immutable DISTRIBUTOR_ALLOCATION = 1_500_000_000;
// 60%
uint256 immutable LPCREATOR_ALLOCATION = 7_000_000_000;
```

as needed to specify allocation amounts for different contracts/EOAs in [`Setup.s.sol`](./script/Setup.s.sol). **Final numbers would need to be discussed with John.**

Then:

```bash
chmod +x ./deploy.mainnet.sh

cp .env.initial.example .env.initial
# then, fill out .env.initial
vim .env.initial
# then, deploy contracts
./deploy.mainnet.sh -d initial
```

The script will deploy all contracts and verify them on Basescan for you.

Later, you would have the merkle root ready. Then, run this:

```bash
# later, you have your merkle root ready
cp .env.merkleroot.example .env.merkleroot
# then, fill out .env.merkleroot
vim .env.merkleroot
# then, set the merkle root
./deploy.mainnet.sh -d merkle-root
```

## Airdrop

First, copy `airdrop.example.json` to `airdrop.json`:

```bash
cp airdrop.example.json airdrop.json
```

Then, modify fields in the json file as needed.

Then, run the script:

Local RPC example using anvil
```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 npm run airdrop -- --input airdrop.json --rpc "http://127.0.0.1:8545" --contract "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
```

Mainnet example
```bash
PRIVATE_KEY=<AIRDROP_CONTRACT_OWNER_PRIVATE_KEY> npm run airdrop -- --input airdrop.json --rpc "https://mainnet.base.org" --contract "0x15a5b32ed221fa59b25bc7d7eb3a2659ffb0a594"
```

Then it should show something like

```bash
sending airdrop txn to 1 addresses..
airdrop txn sent: 0x4e9826041bdae0a6ee2c9036ca514f204a6498354a47a8783597d95cbc106816
```

Use the txn hash to check if the airdrop has been sent as expected on basescan.

[Example airdrop transaction on Sepolia is here](https://sepolia.basescan.org/tx/0x168a8b628033449f2aa80c944649b9a5ed1f2f590847000406f7f593f0bdd698).

## Latest Sepolia addresses

| Contract | Address |
|---|---|
| GameToken | https://sepolia.basescan.org/address/0x6372da1618a3fbdf3a2200aa09c1be8d91d20d87 |
| GameListing | https://sepolia.basescan.org/address/0x8eccb19e64b1adf50d9e775b9548aba78fb10f76 |
| GameMarketing | https://sepolia.basescan.org/address/0xf2ff7c5207f1805ae342cd86cfcc47100b76cce7 |
| GameAirdrop | https://sepolia.basescan.org/address/0x6de17144d93f954ed1e37aacdf983e74c0de68d5 |
