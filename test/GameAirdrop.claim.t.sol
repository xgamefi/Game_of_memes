// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Setup} from "../script/Setup.s.sol";
import {IMerkleDistributor} from "../src/interfaces/IMerkleDistributor.sol";
import {IMerkleDistributorWithDeadline} from "../src/interfaces/IMerkleDistributorWithDeadline.sol";
import {SetupMerkleRoot} from "../script/SetupMerkleRoot.s.sol";

contract GameAirdropClaimTest is Test, Setup, SetupMerkleRoot {
    address immutable deployer = address(0x1);
    address immutable owner = address(0x123);
    bytes32 immutable merkleRoot = bytes32(0x3f9aaec5ca2979e3145924a45f66e445869fc864018d3d1809178afce3b71d34);

    function setUp() public {
        vm.startPrank(owner);
        address lpCreator = address(0x2);
        deploy(lpCreator, owner, "Game of Memes", "GOME");
        setDistributor(address(distributor));
        setMerkleRoot(merkleRoot);
        vm.stopPrank();
    }

    function test_claim0x52000000000000000000_by_0x0187a11d91854F60124507c0bD8a4251243c0b60() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"744628cc03997f37d52ef51b472a2159105e8f35f869d6f151f37e5c3d448688"));
        proof[1] = bytes32(abi.encodePacked(hex"74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"));
        vm.startPrank(0x0187a11d91854F60124507c0bD8a4251243c0b60);
        distributor.claim(0, 0x0187a11d91854F60124507c0bD8a4251243c0b60, 0x52000000000000000000, proof);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(0x0187a11d91854F60124507c0bD8a4251243c0b60), 0x52000000000000000000);
        vm.assertEq(distributor.isClaimed(0), true);
    }

    function test_claim0x26000000000000000000_by_0x68b08287134f255ea8DEEfF409241f889C9f8Deb() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"46ae2c4cd3f2b8099e8536342607e38d38c2e4ddf6e2a6154c761d66fc97a447"));
        proof[1] = bytes32(abi.encodePacked(hex"0134906f1fbdc2b8830f7a20c4d728258c80e9705c058c02dbfacd6594f5aa02"));
        vm.startPrank(0x68b08287134f255ea8DEEfF409241f889C9f8Deb);
        distributor.claim(1, 0x68b08287134f255ea8DEEfF409241f889C9f8Deb, 0x26000000000000000000, proof);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(0x68b08287134f255ea8DEEfF409241f889C9f8Deb), 0x26000000000000000000);
        vm.assertEq(distributor.isClaimed(1), true);
    }

    function test_claim0x39000000000000000000_by_0x6c44EaAeF113Ba1fDfa6BC30Ef49E2342f2058a5() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"901b8ee7456186f717d9343c3bac2bb5401c104c0ba9e9eef7ef4a8ba98144d3"));
        proof[1] = bytes32(abi.encodePacked(hex"74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"));
        vm.startPrank(0x6c44EaAeF113Ba1fDfa6BC30Ef49E2342f2058a5);
        distributor.claim(2, 0x6c44EaAeF113Ba1fDfa6BC30Ef49E2342f2058a5, 0x39000000000000000000, proof);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(0x6c44EaAeF113Ba1fDfa6BC30Ef49E2342f2058a5), 0x39000000000000000000);
        vm.assertEq(distributor.isClaimed(2), true);
    }

    function test_claim0x13000000000000000000_by_0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"6713ffcc9e6a08f76fdd7db3958a277673141967928a181a8807711253b8cb39"));
        proof[1] = bytes32(abi.encodePacked(hex"0134906f1fbdc2b8830f7a20c4d728258c80e9705c058c02dbfacd6594f5aa02"));
        vm.startPrank(0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80);
        distributor.claim(3, 0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80, 0x13000000000000000000, proof);
        vm.stopPrank();
        vm.assertEq(gome.balanceOf(0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80), 0x13000000000000000000);
        vm.assertEq(distributor.isClaimed(3), true);
    }

    function test_cannotClaimTwice() public {
        test_claim0x13000000000000000000_by_0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80();
        vm.expectRevert(IMerkleDistributorWithDeadline.AlreadyClaimed.selector);
        test_claim0x13000000000000000000_by_0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80();
    }

    function test_cannotClaimWithFalseProof() public {
        bytes32[] memory falseProof = new bytes32[](2);
        // Use another account's proof to claim
        falseProof[0] = bytes32(abi.encodePacked(hex"901b8ee7456186f717d9343c3bac2bb5401c104c0ba9e9eef7ef4a8ba98144d3"));
        falseProof[1] = bytes32(abi.encodePacked(hex"74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"));
        vm.startPrank(0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80);

        vm.expectRevert(IMerkleDistributorWithDeadline.InvalidProof.selector);
        distributor.claim(3, 0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80, 0x39000000000000000000, falseProof);

        vm.stopPrank();
        vm.assertEq(gome.balanceOf(0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80), 0);
    }

    function test_cannotClaimAfterEnd() public {
        // Past the end time
        vm.warp(distributor.endTime() + 1 seconds);
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = bytes32(abi.encodePacked(hex"6713ffcc9e6a08f76fdd7db3958a277673141967928a181a8807711253b8cb39"));
        proof[1] = bytes32(abi.encodePacked(hex"0134906f1fbdc2b8830f7a20c4d728258c80e9705c058c02dbfacd6594f5aa02"));
        vm.startPrank(0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80);

        vm.expectRevert(IMerkleDistributorWithDeadline.ClaimWindowFinished.selector);
        distributor.claim(3, 0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80, 0x13000000000000000000, proof);

        vm.stopPrank();
    }

    function test_canModifyEndTime() public {
        uint256 initialEndTime = distributor.endTime();
        uint256 newEndTime = initialEndTime + 10 days;

        vm.warp(initialEndTime - 3 days);
        vm.startPrank(owner);

        distributor.modifyEndTime(newEndTime);
        vm.stopPrank();

        vm.assertEq(distributor.endTime(), newEndTime);
    }

    function test_cannotModifyEndTimeAfterEnd() public {
        uint256 initialEndTime = distributor.endTime();

        vm.warp(initialEndTime + 1 seconds);
        vm.startPrank(owner);

        vm.expectRevert(IMerkleDistributorWithDeadline.EndTimeInPast.selector);
        distributor.modifyEndTime(initialEndTime + 10 days);
        vm.stopPrank();

        vm.assertEq(distributor.endTime(), initialEndTime);
    }

    function test_cannotModifyEndTimeToPast() public {
        uint256 initialEndTime = distributor.endTime();
        vm.warp(initialEndTime - 2 days);
        vm.startPrank(owner);

        vm.expectRevert(IMerkleDistributorWithDeadline.NewEndTimeInPast.selector);
        distributor.modifyEndTime(initialEndTime - 2 days - 30 seconds);

        vm.stopPrank();

        vm.assertEq(distributor.endTime(), initialEndTime);
    }
}
