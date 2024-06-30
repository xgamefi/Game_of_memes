// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SetupMerkleRoot} from "./SetupMerkleRoot.s.sol";

contract DeployMerkleRoot is Script, SetupMerkleRoot {
    function run() public {
        vm.startBroadcast();
        bytes32 merkleRoot = vm.envBytes32("MERKLE_ROOT");
        address gameAirdrop = vm.envAddress("GAME_AIRDROP_ADDRESS");
        setDistributor(gameAirdrop);
        setMerkleRoot(merkleRoot);
        vm.stopBroadcast();
    }
}
