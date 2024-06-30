// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Setup} from "../script/Setup.s.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";

contract GomeTest is Test, Setup, SetupMerkleRoot {
    address immutable deployer = address(0x1);
    address immutable owner = address(0x123);

    function setUp() public {
        vm.startPrank(deployer);
        address lpCreator = address(0x2);
        deploy(lpCreator, owner, "Game of Memes", "GOME");
        setDistributor(address(distributor));
        setMerkleRoot(bytes32(uint256(1)));
        vm.stopPrank();
    }

    function test_totalCapLuckyNumber() public view {
        assertEq(gome.totalCap(), 420_690_000_000 * 1 ether);
    }

    function test_totalSupplyEqualToTotalCap() public view {
        assertEq(gome.totalSupply(), gome.totalCap());
    }

    function test_canBurn() public {
        uint256 initialSupply = gome.totalSupply();
        uint256 burnAmount = 100;
        uint256 initialBalance = gome.balanceOf(lpCreator);
        vm.startPrank(lpCreator);
        gome.burn(burnAmount);
        vm.stopPrank();
        assertEq(gome.totalSupply(), initialSupply - burnAmount);
        assertEq(gome.balanceOf(lpCreator), initialBalance - burnAmount);
    }
}
