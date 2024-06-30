import { program } from 'commander'
import fs from 'fs'
import { MerkleDistributorInfo } from '../merkle/parse-balance-map'

program
  .version('0.1.0')
  .requiredOption(
    '-i, --input <path>',
    'Generated merkle tree',
  )
  .option('-o, --output <path>', 'output JSON file location for the generated merkle tree', 'GameAirdrop.t.sol')

program.parse(process.argv)

const merkleDistributorInfo: MerkleDistributorInfo = JSON.parse(fs.readFileSync(program.input, 'utf-8'))

const claimTests = Object.entries(merkleDistributorInfo.claims).map(([account, claim]) => {
  const pushes = claim.proof.map((proof) => `bytes32(abi.encodePacked(hex"${proof.slice(2)}"))`).map((proof, i) => `        proof[${i}] = ${proof};`).join('\n');

  return `
    function test_claim${claim.amount}_by_${account}() public {
        bytes32[] memory proof = new bytes32[](${claim.proof.length});
${pushes}
        vm.startPrank(${account});
        merkleDistributor.claim(${claim.index}, ${account}, ${claim.amount}, proof);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(${account}), ${claim.amount});
        vm.assertEq(merkleDistributor.isClaimed(${claim.index}), true);
    }`
})

const contract = `
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Gome} from "../src/Gome.sol";
import {Setup} from "../script/Setup.s.sol";

contract MerkleDistributorTest is Test, Setup {
    address immutable deployer = address(0x1);
    bytes32 immutable merkleRoot = bytes32(${merkleDistributorInfo.merkleRoot});
    uint256 immutable tokenTotal = uint256(${merkleDistributorInfo.tokenTotal});

    function setUp() public {
        vm.startPrank(deployer);
        address lpCreator = address(0x2);
        deploy(lpCreator, merkleRoot);
        vm.stopPrank();
    }
    ${claimTests.join('\n')}
}
`

fs.writeFileSync(program.output, contract)
