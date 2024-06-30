#!/bin/sh

set -eu

# Get options from the command line
# usage: deploy.mainnet.sh -d initial|merkle-root
while getopts ":d:" opt; do
  case $opt in
  d)
    DEPLOY_TYPE=$OPTARG
  ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
  ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
  ;;
  esac
done

if [ "$DEPLOY_TYPE" == "initial" ]
then
  echo "Deploying contracts"
  if [ -f .env ]
  then
    rm .env
  fi
  cp .env.initial .env
  source .env

  forge script script/Deploy.s.sol --broadcast --private-key "${DEPLOYER_PRIVATE_KEY}" --verify --rpc-url "https://mainnet.base.org" --verifier-url "https://api.basescan.org/api" --etherscan-api-key "${BASESCAN_API_KEY}"
elif [ "$DEPLOY_TYPE" == "merkle-root" ]
then
  if [ -f .env ]
  then
    rm .env
  fi
  cp .env.merkleroot .env
  source .env

  if [ -z "$MERKLE_ROOT" ]
  then
    echo "MERKLE_ROOT is not set" >&2
    exit 1
  fi
  if [ -z "$GAME_AIRDROP_ADDRESS" ]
  then
    echo "GAME_AIRDROP_ADDRESS is not set" >&2
    exit 1
  fi

  echo "Setting merkle root"
  forge script script/DeployMerkleRoot.s.sol --broadcast --private-key "${DEPLOYER_PRIVATE_KEY}" --rpc-url "https://mainnet.base.org"
else
  echo "Invalid option: $DEPLOY_TYPE" >&2
  exit 1
fi

rm .env

set +eu
