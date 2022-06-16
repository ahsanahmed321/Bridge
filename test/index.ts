/* eslint-disable node/no-missing-import */
import { expect } from "chai";
import { ethers } from "hardhat";

import {
  ETHbridge__factory,
  ETHbridge,
  MaticBridge__factory,
  MaticBridge,
} from "../typechain";

const ERC20ABI = require("../artifacts/contracts/ERC20.sol/ERC20Token.json");

describe("Bridge", function () {
  let accounts: any;
  let ethBridge: ETHbridge;
  let ethTokenAddress: string;
  let matBridge: MaticBridge;
  let matTokenAddress: string;

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    ethBridge = await new ETHbridge__factory(accounts[0]).deploy();
    ethTokenAddress = await ethBridge.nativeToken();

    matBridge = await new MaticBridge__factory(accounts[0]).deploy();
    matTokenAddress = await matBridge.nativeToken();
  });

  it("Contracts Deployed", async function () {
    expect(ethBridge.address);
    expect(ethTokenAddress);
    expect(matBridge.address);
    expect(matTokenAddress);
  });

  it("Testing Locking and Minting Of Token", async function () {
    const ethToken = new ethers.Contract(
      ethTokenAddress,
      ERC20ABI.abi,
      accounts[0]
    );
    await ethToken.increaseAllowance(
      ethBridge.address,
      ethers.utils.parseEther("100")
    );
    await ethBridge.lock(
      ethers.utils.parseEther("100"),
      8001,
      accounts[1].address
    );

    const abi = ethers.utils.defaultAbiCoder;
    const message = abi.encode(
      ["uint", "uint", "uint", "address"],
      [ethers.utils.parseEther("100"), 0, 8001, accounts[1].address]
    );
    const messageHash = ethers.utils.keccak256(message);
    await matBridge.mintTokens(messageHash, message);

    const matToken = new ethers.Contract(
      matTokenAddress,
      ERC20ABI.abi,
      accounts[1]
    );
    const receivingAmount = await matToken.balanceOf(accounts[1].address);
    expect(Number(ethers.utils.formatEther(receivingAmount))).greaterThan(0);
  });
});
