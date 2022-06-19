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
    error SignatureVerificationFailed();
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

    function unlock(
        bytes32 messageHash,
        bytes calldata message,
        bytes memory signature
    ) external {
        bytes32 unprefixedHash = keccak256(message);
        (
            uint256 amount,
            uint256 _nonce,
            uint32 receiverChainID,
            address to
        ) = abi.decode(message, (uint256, uint256, uint32, address));

        if (messageHash != unprefixedHash)
            revert HashMismatched(messageHash, unprefixedHash);

        if (verifySignature(messageHash, signature) == true)
            _unlockTokens(amount, _nonce, receiverChainID, to);
    }

    function verifySignature(bytes32 messageHash, bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 ethSignedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        address signer = ecrecover(ethSignedMessage, v, r, s);
        return signer == owner;
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        require(sig.length == 65, "sig len not 65");

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 byt (es).
            v := byte(0, mload(add(sig, 96)))
        }
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert SignatureVerificationFailed();
        }
        if (v != 27 && v != 28) {
            revert SignatureVerificationFailed();
        }

        return (v, r, s);
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
