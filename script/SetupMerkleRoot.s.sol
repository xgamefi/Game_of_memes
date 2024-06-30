// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {GameAirdrop} from "../src/GameAirdrop.sol";

contract SetupMerkleRoot {
    GameAirdrop private distributor;

    function setDistributor(address distributor_) public {
        distributor = GameAirdrop(distributor_);
    }

    function setMerkleRoot(bytes32 merkleRoot) public {
        require(address(distributor) != address(0), "SetupMerkleRoot:distributor not set");

        distributor.setMerkleRoot(merkleRoot);
    }
}
