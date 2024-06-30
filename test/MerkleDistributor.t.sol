// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameToken} from "../src/GameToken.sol";
import {Setup} from "../script/Setup.s.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";
import {IMerkleDistributor} from "../src/interfaces/IMerkleDistributor.sol";

contract MerkleDistributorTest is Test, Setup, SetupMerkleRoot {
    address immutable deployer = address(0x1);
    address immutable owner = address(0x123);
    bytes32 newMerkleRoot = bytes32(0x3f9aaec5ca2979e3145924a45f66e445869fc864018d3d1809178afce3b71d34);

    function setUp() public {
        vm.startPrank(deployer);
        address lpCreator = address(0x2);
        deploy(lpCreator, owner, "Game of Memes", "GOME");
        setDistributor(address(distributor));

        vm.stopPrank();
    }

    function test_deployerCanSetMerkleRoot() public {
        vm.startPrank(deployer);
        setMerkleRoot(newMerkleRoot);
        vm.stopPrank();

        assertEq(distributor.merkleRoot(), newMerkleRoot);
    }

    function test_nonDeployerCannotSetMerkleRoot() public {
        vm.startPrank(address(0x3));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x3)));
        setMerkleRoot(newMerkleRoot);
        vm.stopPrank();

        assertEq(distributor.merkleRoot(), bytes32(0));
    }

    function test_deployerCannotSetNewMerkleRootAs0() public {
        vm.startPrank(deployer);
        vm.expectRevert(abi.encodeWithSelector(IMerkleDistributor.NewMerkleRootEmpty.selector));
        setMerkleRoot(bytes32(0));
        vm.stopPrank();
        assertEq(distributor.merkleRoot(), bytes32(0));
    }

    function test_deployerCannotSetMerkleRootAgain() public {
        vm.startPrank(deployer);
        setMerkleRoot(newMerkleRoot);
        vm.expectRevert(abi.encodeWithSelector(IMerkleDistributor.MerkleRootAlreadyExists.selector));
        setMerkleRoot(bytes32(uint256(12412412)));
        vm.stopPrank();
        assertEq(distributor.merkleRoot(), newMerkleRoot);
    }

    function test_cannotClaimWhenNoMerkleRootYet() public {
        vm.startPrank(address(0x3));
        vm.expectRevert(abi.encodeWithSelector(IMerkleDistributor.NoMerkleRootYet.selector));
        distributor.claim(0, address(0x3), 0x123, new bytes32[](0));
        vm.stopPrank();
        assertEq(gome.balanceOf(address(0x3)), 0);
        assertEq(distributor.isClaimed(0), false);
    }
}
