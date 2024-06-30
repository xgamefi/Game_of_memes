// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Setup} from "./Setup.s.sol";

contract GomeScript is Script, Setup {
    function run() public {
        vm.startBroadcast();
        address lpCreatorAddress = vm.envAddress("LP_CREATOR_ADDRESS");
        address ownerAddress = vm.envAddress("OWNER_ADDRESS");
        string memory tokenName = vm.envString("GOME_NAME");
        string memory tokenSymbol = vm.envString("GOME_SYMBOL");
        deploy(
            // address lpCreator_,
            lpCreatorAddress,
            // address owner,
            ownerAddress,
            // string memory tokenName,
            tokenName,
            // string memory tokenSymbol
            tokenSymbol
        );
        vm.stopBroadcast();
    }
}
