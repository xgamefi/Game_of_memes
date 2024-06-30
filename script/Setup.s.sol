// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {GameToken} from "../src/GameToken.sol";
import {TokenHolder} from "../src/TokenHolder.sol";
import {GameAirdrop} from "../src/GameAirdrop.sol";
import {GameListing} from "../src/GameListing.sol";
import {GameMarketing} from "../src/GameMarketing.sol";

// Contract used for actual deployment and testing.
contract Setup {
    GameToken public gome;
    GameListing public listing;
    GameMarketing public marketing;
    GameAirdrop public distributor;
    address public lpCreator;

    // @dev the amounts are subject to change before real deployment
    // 10%
    uint256 immutable LISTING_ALLOCATION = 42_069_000_000;
    // 5%
    uint256 immutable MARKETING_ALLOCATION = 21_034_500_000;
    // 15%
    uint256 immutable DISTRIBUTOR_ALLOCATION = 63_103_500_000;
    // 70%
    uint256 immutable LPCREATOR_ALLOCATION = 294_483_000_000;

    // @param lpCreator The address of the LP creator; this is the address that will receive
    // the $GOME token and create the LP. The LP creator must be trusted.
    function deploy(address lpCreator_, address owner, string memory tokenName, string memory tokenSymbol) public {
        gome = new GameToken(tokenName, tokenSymbol);
        listing = new GameListing(address(gome), owner);
        marketing = new GameMarketing(address(gome), owner);
        distributor = new GameAirdrop(address(gome), owner);
        lpCreator = lpCreator_;

        distribute();
    }

    // @dev the amounts are subject to change before real deployment
    function distribute() public {
        uint256 decimals = 10 ** uint256(uint8(gome.decimals()));

        require(
            (LISTING_ALLOCATION + MARKETING_ALLOCATION + DISTRIBUTOR_ALLOCATION + LPCREATOR_ALLOCATION) * decimals
                == gome.totalSupply(),
            "setup::distribute: total supply mismatch"
        );

        gome.transfer(address(listing), LISTING_ALLOCATION * decimals);
        gome.transfer(address(marketing), MARKETING_ALLOCATION * decimals);
        gome.transfer(address(distributor), DISTRIBUTOR_ALLOCATION * decimals);

        gome.transfer(lpCreator, LPCREATOR_ALLOCATION * decimals);

        if (lpCreator != msg.sender) {
            require(gome.balanceOf(msg.sender) == 0, "setup::distribute: gome balance not zero");
        } else {
            require(
                gome.balanceOf(msg.sender) == LPCREATOR_ALLOCATION * decimals,
                "setup::distribute: gome balance not 7_000_000_000"
            );
        }
    }
}
