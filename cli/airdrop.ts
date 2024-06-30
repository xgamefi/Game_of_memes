import { program } from "commander";
import fs from "fs";
import ethers, { Contract, Wallet } from "ethers";
import { getAddress } from "ethers/lib/utils";
import { JsonRpcProvider } from "@ethersproject/providers";

program
  .version("0.1.0")
  .requiredOption(
    "-i, --input <path>",
    "Airdrop information file, consisting of addresses and corresponding amounts in uint256",
  )
  .option(
    `-r, --rpc <rpcUrl>`,
    `RPC URL (default Base emainnet)`,
    `https://mainnet.base.org`,
  )
  .option(
    `-c, --contract <address>`,
    `Airdrop contract address (default is Base mainnet airdrop contract address)`,
    // Mainnet Airdrop contract address https://basescan.org/address/0x15a5b32ed221fa59b25bc7d7eb3a2659ffb0a594
    `0x15a5b32ed221fa59b25bc7d7eb3a2659ffb0a594`,
  );

program.parse(process.argv);

interface ExpectedInput {
  addresses: string[];
  amounts: string[];
}

function isExpectedInput(json: any): json is ExpectedInput {
  return (
    json.addresses !== undefined &&
    json.amounts !== undefined &&
    Array.isArray(json.addresses) &&
    Array.isArray(json.amounts) &&
    json.addresses.length > 0 &&
    json.amounts.length > 0
  );
}

function validateAddress(address: string): boolean {
  try {
    getAddress(address);
  } catch (e) {
    return false;
  }

  return true;
}

function validateAmount(amount: string): boolean {
  return !isNaN(Number(amount)) && BigInt(amount) >= 0 && BigInt(amount) <=
      // 2^256 - 1
      115792089237316195423570985008687907853269984665640564039457584007913129639936n;
}

async function run() {
  // Private key of the airdrop contract owner
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    console.error("PRIVATE_KEY environment variable is required");
    process.exit(1);
  }

  const rpcUrl = program.rpc;
  const airdropContractAddress = program.contract;

  const json = JSON.parse(fs.readFileSync(program.input, { encoding: "utf8" }));

  if (!isExpectedInput(json)) {
    console.error("Invalid input file format");
    process.exit(1);
  }

  try {
    new URL(rpcUrl);
  } catch (e) {
    console.error(`Invalid RPC_URL: ${rpcUrl}`);
    process.exit(1);
  }

  if (json.addresses.length !== json.amounts.length) {
    console.error("Address and amount arrays must have the same length");
    process.exit(1);
  }

  for (const address of json.addresses) {
    if (!validateAddress(address)) {
      console.error(`Invalid address found: ${address}`);
      process.exit(1);
    }
  }

  for (const amount of json.amounts) {
    if (!validateAmount(amount)) {
      console.error(`Invalid amount found: ${amount}`);
      process.exit(1);
    }
  }

  const provider = new JsonRpcProvider(rpcUrl);
  const wallet = new Wallet(privateKey, provider);

  const airdropContractAbi = [
    {
      "inputs": [{
        "internalType": "address[]",
        "name": "recipients",
        "type": "address[]",
      }, {
        "internalType": "uint256[]",
        "name": "amounts",
        "type": "uint256[]",
      }],
      "name": "airdrop",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function",
    },
  ] as const;

  const airdropContract = new Contract(
    airdropContractAddress,
    airdropContractAbi,
    wallet,
  );

  const bigintAmounts = json.amounts.map((amount) => BigInt(amount));

  console.log(`sending airdrop txn to ${json.addresses.length} addresses..`)
  const tx = await airdropContract.airdrop(json.addresses, bigintAmounts);
  await tx.wait();
  console.log(`airdrop txn sent: ${tx.hash}`)
}

run();
