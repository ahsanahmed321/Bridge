//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ERC20Token is ERC20, ERC20Burnable {
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol,
        address to
    ) ERC20(tokenName, tokenSymbol) {
        _mint(to, initialSupply);
    }

    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }
}
