// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameToken} from "../src/GameToken.sol";
import {Setup} from "../script/Setup.s.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";

contract GameAirdropAirdropTest is Test, Setup, SetupMerkleRoot {
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

    function test_airdrop() public {
        address[] memory recipients = new address[](2);
        recipients[0] = address(0x3);
        recipients[1] = address(0x4);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        vm.startPrank(owner);
        distributor.airdrop(recipients, amounts);
        vm.stopPrank();

        for (uint256 i = 0; i < recipients.length; i++) {
            vm.assertEq(gome.balanceOf(recipients[i]), amounts[i]);
        }
    }

    function test_nonOwnerCannotAirdrop() public {
        address[] memory recipients = new address[](2);
        recipients[0] = address(0x3);
        recipients[1] = address(0x4);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        vm.startPrank(address(0x3));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x3)));
        distributor.airdrop(recipients, amounts);
        vm.stopPrank();

        for (uint256 i = 0; i < recipients.length; i++) {
            vm.assertEq(gome.balanceOf(recipients[i]), 0);
        }
    }

    function test_cannotAirdropMismatchedLength() public {
        address[] memory recipients = new address[](2);
        recipients[0] = address(0x3);
        recipients[1] = address(0x4);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100;

        vm.startPrank(owner);
        vm.expectRevert("GameAirdrop::airdrop: recipients and amounts length mismatch");
        distributor.airdrop(recipients, amounts);
        vm.stopPrank();

        for (uint256 i = 0; i < recipients.length; i++) {
            vm.assertEq(gome.balanceOf(recipients[i]), 0);
        }
    }
}
