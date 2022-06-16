const { expect } = require("chai");
const { ethers } = require("hardhat");

const ETHbridgeABI = require("../artifacts/contracts/ETHbridge.sol/ETHbridge.json")
const MaticBridgeABI = require("../artifacts/contracts/Maticbridge.sol/MaticBridge.json")
const TokenABI = require("../artifacts/contracts/ERC20.sol/ERC20Token.json")

describe("Greeter", function () {
  // it("Should return the new greeting once it's changed", async function () {
  //   const Greeter = await ethers.getContractFactory("Greeter");
  //   const greeter = await Greeter.deploy("Hello, world!");
  //   await greeter.deployed();

  //   expect(await greeter.greet()).to.equal("Hello, world!");

  //   const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

  //   // wait until the transaction is mined
  //   await setGreetingTx.wait();

  //   expect(await greeter.greet()).to.equal("Hola, mundo!");
  // });

  let accounts;

  let TokenContractAddress;
  let TokenContractForEth;
  let TokenContractForMatic;

  let ETHbridgeContract;
  let ETHbridgeContractAddress;
  let ETHBridgeNativeToken;
  
  let MaticbridgeContract;
  let MaticBridgeContractAddress;
  let MaticBridgeNativeToken;


  let ETHnativeToken;
  let MaticNativeToken;

  console.log("running")

  beforeEach( async () => {
    accounts = await ethers.getSigners();
    let ETHbridgeContractFactory = await ethers.getContractFactory("ETHbridge");
    ETHbridgeContract = await ETHbridgeContractFactory.deploy();
    
    let MaticbridgeContractFactory = await ethers.getContractFactory("MaticBridge");
    MaticbridgeContract = await MaticbridgeContractFactory.deploy();

    await ETHbridgeContract.deployed();
    await MaticbridgeContract.deployed();

    //console.log(ETHbridgeContract.address, "address")
    ETHbridgeContractAddress = ETHbridgeContract.address;
    MaticBridgeContractAddress = MaticbridgeContract.address;

    ETHbridgeContract = new ethers.Contract(ETHbridgeContractAddress, ETHbridgeABI.abi, accounts[0]);
    ETHBridgeNativeToken = await ETHbridgeContract.nativeToken();

    MaticbridgeContract = new ethers.Contract(MaticBridgeContractAddress, MaticBridgeABI.abi, accounts[0]);
    MaticBridgeNativeToken = await MaticbridgeContract.nativeToken();



    TokenContractForEth = new ethers.Contract(ETHBridgeNativeToken, TokenABI.abi, accounts[0])
    TokenContractForMatic = new ethers.Contract(MaticBridgeNativeToken, TokenABI.abi, accounts[0])

  })
  it("deploys the ETHBriddgeContract", async function () {

    

  })

  it("deplys the token contract and checks balance of account[0]", async function(){

  })
});
