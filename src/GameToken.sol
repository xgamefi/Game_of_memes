// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * The reason for the inclusion of random useless information
 * is to avoid being marked as the same as other previously deployed
 * contracts by automated scanners.
 */
contract GameToken is ERC20, ERC20Burnable, Ownable {
    bool private randomInfo = false;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable(msg.sender) {
        // Some public meme token indexers would mark ownership status
        // as 'unknown' if ownership is not directly renounced.
        renounceOwnership();
        _mint(msg.sender, totalCap());
    }

    function calculateRandomNumbers() public view returns (uint256) {
        return 14 * (5 ** decimals());
    }

    function totalCap() public view returns (uint256) {
        return 420_690_000_000 * (10 ** decimals());
    }

    function letsPlaySomeGame() public {
        bool game = false;
        if (game) {
            randomInformation();
        } else {
            doEvenMoreOfNothing();
        }
    }

    function doEvenMoreOfNothing() public {
        randomInformation();
    }

    function randomInformation() public returns (bool) {
        randomInfo = !randomInfo;
        return randomInfo;
    }
}
