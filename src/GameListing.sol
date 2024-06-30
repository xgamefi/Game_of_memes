// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {TokenHolder} from "./TokenHolder.sol";

contract GameListing is TokenHolder {
    constructor(address token_, address owner) TokenHolder("GameListing", token_, owner) {}
}
