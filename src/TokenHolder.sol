// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenHolder is Ownable {
    string public identity;
    address private immutable token;

    constructor(string memory identity_, address token_, address owner) Ownable(owner) {
        identity = identity_;
        token = token_;
    }

    function transferToken(address to, uint256 amount) public onlyOwner {
        // We already trust our token contract, so we don't use SafeERC20 here
        IERC20(token).transfer(to, amount);
    }
}
