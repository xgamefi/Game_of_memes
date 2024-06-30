// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameToken} from "../src/GameToken.sol";
import {Setup} from "../script/Setup.s.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";

contract TokenHolderTest is Test, Setup, SetupMerkleRoot {
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

    function test_identity() public view {
        vm.assertEq(listing.identity(), "GameListing");
    }

    function test_ownerCanTransferToken() public {
        vm.startPrank(owner);
        listing.transferToken(address(0x3), 100);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(address(0x3)), 100);
    }

    function test_nonOwnerCannotTransferToken() public {
        vm.startPrank(address(0x3));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x3)));
        listing.transferToken(address(0x4), 100);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(address(0x4)), 0);
    }
}
