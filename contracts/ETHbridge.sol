//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {ERC20Token} from "./ERC20.sol";

contract ETHbridge {
    event LockTokens(bytes32 txHash, bytes tx, uint32 receiverChainID);
    event UnlockTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 senderChainID,
        uint32 receiverChainID,
        address receiver
    );
    error ZeroAddressPassed();
    error ZeroAmount();
    error TransferFromFailed();
    error UnlockingTokensFailed();
    uint256 public nonce;
    address public immutable nativeToken;

    constructor() {
        ERC20Token nativeTokenContract = new ERC20Token(
            2000 ether,
            "KUMAIL",
            "KUM",
            msg.sender
        );
        nativeToken = address(nativeTokenContract);
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

    function _unlockTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 senderChainID,
        uint32 receiverChainID,
        address to
    ) internal {
        if (IERC20(nativeToken).transfer(to, amountToUnlock) == false)
            revert UnlockingTokensFailed();
        emit UnlockTokens(
            amountToUnlock,
            _nonce,
            senderChainID,
            receiverChainID,
            to
        );
    }
}
