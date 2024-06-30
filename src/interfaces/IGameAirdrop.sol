// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Allows anyone to claim a token if they exist in a merkle root.
interface IGameAirdrop {
    error Paused();

    event UpdatePause(bool paused);
}
