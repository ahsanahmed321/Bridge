//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import {IERC20} from "./IERC20.sol";
import {ERC20Token} from "./ERC20.sol";

contract ETHbridge {


    
    error InvalidChainID();
    error HashMismatched();
    error TransferFromFailed();
    error ZeroAmount();
    error ZeroAddressPassed();
    error UnlockingTokensFailed();
    uint256 public nonce;
    address immutable nativeToken;
    event MintTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 senderChainID,
        uint32 receiverChainID,
        address receiver
    );
    event BurnTokens(bytes32 txHash, bytes tx,uint32 receiverChainID);


    constructor() {
        ERC20Token nativeTokenContract = new ERC20Token(200000, "Ahsan", "AHS");
        nativeToken = address(nativeTokenContract);
    }
    

    function mintTokens(
        bytes32 messageHash,
        bytes calldata message
    ) external {
        bytes32  unprefixedHash = keccak256(message);
        (
            uint256 amount,
            uint256 _nonce,
            uint32 senderChainID,
            uint32 receiverChainID,
            address to
        ) = abi.decode(message, (uint256, uint256, uint32,uint32, address));

        //verify logic

            _mintTokens(amount, 
            _nonce,
            senderChainID,
             receiverChainID,
              to,
            unprefixedHash);
    }

    function _mintTokens(
        uint256 amountToMint,
        uint256 _nonce,
        uint32 senderChainID,
        uint32 receiverChainID,
        address to,
        bytes32 _tX
    ) internal {
        IERC20(nativeToken).mint(amountToMint, to);
        emit MintTokens(amountToMint, _nonce, senderChainID,receiverChainID, to);
    }


    function burnTokens(uint256 amount,uint32 receiverChainID, address recipient) external {
        if ((amount <= 0)) revert ZeroAmount();
        if (recipient == address(0)) revert ZeroAddressPassed();

     
//ask 
        IERC20(nativeToken).burnFrom(amount, msg.sender);
        uint256 oldNonce = nonce;
        nonce++;

        emit BurnTokens(
            keccak256(
                abi.encode(amount,oldNonce,uint32(block.chainid),receiverChainID,recipient)
            ),
            abi.encode(amount,oldNonce,uint32(block.chainid),receiverChainID,recipient),
            receiverChainID
        )
        ;
    }
}