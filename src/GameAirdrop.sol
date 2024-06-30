// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {MerkleDistributor} from "./MerkleDistributor.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TokenHolder} from "./TokenHolder.sol";

error EndTimeInPast();
error NewEndTimeInPast();
error ClaimWindowFinished();
error NoWithdrawDuringClaim();
error Paused();

event UpdatePause(bool paused);

// @dev a distributor contract has two core functionalities:
// 1. Owner can airdrop tokens to multiple recipients.
// 2. Users can claim tokens with a merkle proof.
// It is entirely up to the owner to decide how to distribute the tokens
// between these two functionalities. A wrong calculation would result in
// some users not being able to claim the token, or the owner not being able
// to airdrop the tokens to all intended recipients.
contract GameAirdrop is MerkleDistributor, Ownable, TokenHolder {
    uint256 public endTime;
    bool public _paused = false;

    constructor(address token_, address owner) TokenHolder("GameAirdrop", token_, owner) MerkleDistributor(token_) {
        // Endtime is 5 days from deployment
        endTime = block.timestamp + 5 days;
    }

    modifier onlyUnpaused() {
        if (_paused) {
            revert Paused();
        }
        _;
    }

    function pause() external onlyOwner {
        _paused = true;
        emit UpdatePause(true);
    }

    function unpause() external onlyOwner {
        _paused = false;
        emit UpdatePause(false);
    }

    // @dev Claim tokens with a merkle proof.
    // @notice we need to make sure that there are enough tokens in the contract to airdrop
    // and for the users claim too. This is up to the management decision of the owner.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof)
        public
        override
        onlyUnpaused
    {
        if (block.timestamp > endTime) revert ClaimWindowFinished();
        super.claim(index, account, amount, merkleProof);
    }

    // @dev in some cases, the end time may need to be extended.
    // @param newEndTime The new end time.
    // @notice the new end time can also be earlier than the current end time.
    function modifyEndTime(uint256 newEndTime) external onlyOwner {
        // Already ended
        if (endTime < block.timestamp) revert EndTimeInPast();
        // New end time is in the past
        if (newEndTime < block.timestamp) revert NewEndTimeInPast();
        endTime = newEndTime;
    }

    // @dev airdrop directly to recipients.
    // @notice we need to make sure that there are enough tokens in the contract to airdrop
    // and for the users claim too. This is up to the management decision of the owner.
    function airdrop(address[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length, "GameAirdrop::airdrop: recipients and amounts length mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            // We already trust our token contract, so we don't use SafeERC20 here
            IERC20(token).transfer(recipients[i], amounts[i]);
        }
    }
}
