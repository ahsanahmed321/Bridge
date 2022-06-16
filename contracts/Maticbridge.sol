//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {ERC20Token} from "./ERC20.sol";

contract MaticBridge {


    
    error InvalidChainID(uint32 actual, uint32 expected);
    error HashMismatched(bytes32 h1, bytes32 h2);
    error TransferFromFailed();
    error ZeroAmount();
    error ZeroAddressPassed();
    error UnlockingTokensFailed();
    uint256 public nonce;
    address public immutable nativeToken;
    event MintTokens(
        uint256 amountToUnlock,
        uint256 _nonce,
        uint32 senderChainID,
        uint32 receiverChainID,
        address receiver
    );
    event BurnTokens(bytes32 txHash, bytes tx,uint32 receiverChainID);
    address immutable public owner;


    constructor() {
        ERC20Token nativeTokenContract = new ERC20Token(200000, "Ahsan", "AHS", msg.sender);
        nativeToken = address(nativeTokenContract);
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function mintTokens(
        bytes32 messageHash,
        bytes calldata message
    ) external onlyOwner {
        bytes32  unprefixedHash = keccak256(message);
        (
            uint256 amount,
            uint256 _nonce,
            uint32 senderChainID,
            uint32 receiverChainID,
            address to
        ) = abi.decode(message, (uint256, uint256, uint32,uint32, address));

        //verify logic

        if (receiverChainID !=block.chainid) revert InvalidChainID(receiverChainID,uint32(block.chainid));
        if (messageHash != prefixed(unprefixedHash))
            revert HashMismatched(messageHash, prefixed(unprefixedHash));

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

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
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
