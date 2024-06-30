// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IMerkleDistributor} from "./interfaces/IMerkleDistributor.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

error AlreadyClaimed();
error InvalidProof();
error NoMerkleRootYet();
error NewMerkleRootEmpty();
error MerkleRootAlreadyExists();

event MerkleRootUpdated(bytes32 merkleRoot);

abstract contract MerkleDistributor is IMerkleDistributor, Context {
    address public immutable override token;
    bytes32 public override merkleRoot;
    address private _deployer;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_) {
        token = token_;
        _deployer = _msgSender();
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyDeployer() virtual {
        _checkDeployer();
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkDeployer() internal view virtual {
        if (_deployer != _msgSender()) {
            revert Ownable.OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /**
     * @dev Sets the merkle root for the contract after deployment of the contract.
     * @notice setting a merkle root is irreversible. It's an one time operation.
     * In case of a mistake, another MerkleDistributor contract will need to be deployed.
     * Make sure that the inheriting contract has a method to recover tokens to the owner.
     */
    function setMerkleRoot(bytes32 newMerkleRoot) external onlyDeployer {
        if (newMerkleRoot == bytes32(0)) revert NewMerkleRootEmpty();
        if (merkleRoot != bytes32(0)) revert MerkleRootAlreadyExists();

        merkleRoot = newMerkleRoot;
        emit MerkleRootUpdated(newMerkleRoot);
    }

    /**
     * @dev Claim tokens with a merkle proof.
     * @notice it needs to be made sure that the contract holds enough tokens to be claimed.
     * @notice the merkle root must be set before calling this function.
     */
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof)
        public
        virtual
        override
    {
        if (isClaimed(index)) revert AlreadyClaimed();
        if (merkleRoot == bytes32(0)) revert NoMerkleRootYet();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(index);
        // We already trust our token contract, so we don't use SafeERC20 here
        IERC20(token).transfer(account, amount);

        emit Claimed(index, account, amount);
    }
}
