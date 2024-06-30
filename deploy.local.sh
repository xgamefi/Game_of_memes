#!/bin/sh

set -eu

# Before running the script, launch anvil on another terminal

# Get options from the command line
# usage: deploy.local.sh -d initial|merkle-root
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

  forge script script/Deploy.s.sol --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://127.0.0.1:8545
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
  forge script script/DeployMerkleRoot.s.sol --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://127.0.0.1:8545
else
  echo "Invalid option: $DEPLOY_TYPE" >&2
  exit 1
fi

rm .env

set +eu
