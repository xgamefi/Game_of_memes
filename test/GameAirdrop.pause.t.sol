// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameToken} from "../src/GameToken.sol";
import {Setup} from "../script/Setup.s.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";
import {IGameAirdrop} from "../src/interfaces/IGameAirdrop.sol";

contract GameAirdropPauseTest is Test, Setup, SetupMerkleRoot {
    address immutable deployer = address(0x1);
    address immutable owner = address(0x123);
    bytes32 immutable merkleRoot = bytes32(0x3f9aaec5ca2979e3145924a45f66e445869fc864018d3d1809178afce3b71d34);

    function setUp() public {
        vm.startPrank(deployer);
        address lpCreator = address(0x2);
        deploy(lpCreator, owner, "Game of Memes", "GOME");
        setDistributor(address(distributor));
        setMerkleRoot(merkleRoot);
        vm.stopPrank();
    }

    function test_claim0x52000000000000000000_by_0x0187a11d91854F60124507c0bD8a4251243c0b60() private {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"744628cc03997f37d52ef51b472a2159105e8f35f869d6f151f37e5c3d448688"));
        proof[1] = bytes32(abi.encodePacked(hex"74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"));
        vm.startPrank(0x0187a11d91854F60124507c0bD8a4251243c0b60);
        distributor.claim(0, 0x0187a11d91854F60124507c0bD8a4251243c0b60, 0x52000000000000000000, proof);
        vm.stopPrank();
    }

    function test_cannotClaimWhenPaused() public {
        vm.startPrank(owner);
        distributor.pause();
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(IGameAirdrop.Paused.selector));
        test_claim0x52000000000000000000_by_0x0187a11d91854F60124507c0bD8a4251243c0b60();
        vm.assertEq(gome.balanceOf(0x0187a11d91854F60124507c0bD8a4251243c0b60), 0);
        vm.assertEq(distributor.isClaimed(0), false);
    }

    function test_canClaimWhenUnpaused() public {
        vm.startPrank(owner);
        distributor.pause();
        distributor.unpause();
        vm.stopPrank();

        test_claim0x52000000000000000000_by_0x0187a11d91854F60124507c0bD8a4251243c0b60();
        vm.assertEq(gome.balanceOf(0x0187a11d91854F60124507c0bD8a4251243c0b60), 0x52000000000000000000);
        vm.assertEq(distributor.isClaimed(0), true);
    }

    function test_ownerCanTogglePause() public {
        vm.startPrank(owner);
        distributor.pause();
        vm.assertEq(distributor._paused(), true);
        distributor.unpause();
        vm.assertEq(distributor._paused(), false);
        distributor.unpause();
        vm.assertEq(distributor._paused(), false);
        distributor.pause();
        vm.assertEq(distributor._paused(), true);
        distributor.pause();
        vm.assertEq(distributor._paused(), true);
        distributor.unpause();
        vm.assertEq(distributor._paused(), false);
        vm.stopPrank();
    }
}
