//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {ERC20Token} from "./ERC20.sol";

contract ETHbridge {
    event LockTokens(bytes32 txHash, bytes tx, uint32 receiverChainID);
    event UnlockTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 receiverChainID,
        address receiver
    );
    error ZeroAddressPassed();
    error HashMismatched(bytes32 h1, bytes32 h2);
    error ZeroAmount();
    error TransferFromFailed();
    error UnlockingTokensFailed();
    uint256 public nonce;
    address public immutable nativeToken;
    address public immutable owner;

    constructor() {
        ERC20Token nativeTokenContract = new ERC20Token(
            2000 ether,
            "KUMAIL",
            "KUM",
            msg.sender
        );
        nativeToken = address(nativeTokenContract);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function lock(
        uint256 amount,
        uint32 receiverChainID,
        address recipient
    ) external {
        if ((amount <= 0)) revert ZeroAmount();
        if (recipient == address(0)) revert ZeroAddressPassed();

        if (
            IERC20(nativeToken).transferFrom(
                msg.sender,
                address(this),
                amount
            ) == false
        ) revert TransferFromFailed();

        uint256 oldNonce = nonce;
        nonce++;

        emit LockTokens(
            keccak256(abi.encode(amount, oldNonce, receiverChainID, recipient)),
            abi.encode(amount, oldNonce, receiverChainID, recipient),
            receiverChainID
        );
    }

    function unlock(bytes32 messageHash, bytes calldata message)
        external
        onlyOwner
    {
        bytes32 unprefixedHash = keccak256(message);
        (
            uint256 amount,
            uint256 _nonce,
            uint32 receiverChainID,
            address to
        ) = abi.decode(message, (uint256, uint256, uint32, address));

        if (messageHash != unprefixedHash)
            revert HashMismatched(messageHash, unprefixedHash);

        _unlockTokens(amount, _nonce, receiverChainID, to);
    }

    function _unlockTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 receiverChainID,
        address to
    ) internal {
        if (IERC20(nativeToken).transfer(to, amountToUnlock) == false)
            revert UnlockingTokensFailed();
        emit UnlockTokens(amountToUnlock, _nonce, receiverChainID, to);
    }
}
