/* eslint-disable prettier/prettier */
/* eslint-disable node/no-missing-import */
import { expect } from "chai";
import { ethers } from "hardhat";

import {
  ETHbridge__factory,
  ETHbridge,
  MaticBridge__factory,
  MaticBridge,
  ERC20,
} from "../typechain";

const ERC20ABI = require("../artifacts/contracts/ERC20.sol/ERC20Token.json");

describe("Bridge", function () {
  let accounts: any;
  let ethBridge: ETHbridge;
  let ethTokenAddress: string;
  let matBridge: MaticBridge;
  let matTokenAddress: string;
  let matToken: any;

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

    matToken = new ethers.Contract(
      matTokenAddress,
      ERC20ABI.abi,
      accounts[1]
    );
    console.log(matToken.address, "mat add")
    const receivingAmount = await matToken.balanceOf(accounts[1].address);
    console.log(receivingAmount, "old balance")
    expect(Number(ethers.utils.formatEther(receivingAmount))).greaterThan(0);
  });

  it("Testing unlock and Burning of Token", async function () {
    // yahan per mat token badal kese gaya?

    // console.log("mat", matToken)
    await matToken.approve(
      matBridge.address,
      ethers.utils.parseEther("100")
    );
    const old = await matToken.balanceOf(accounts[1].address);



    await matBridge.burnTokens(ethers.utils.parseEther("100"), 1, accounts[1].address)
    const newBal = await matToken.balanceOf(accounts[1].address);

    console.log(old, "new balance", newBal)
  });
});
