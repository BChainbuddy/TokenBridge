const { assert, expect } = require("chai");
const { network, getNamedAccounts, deployments } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("BridgeToken test", function () {
      let deployer, tokenContract, bridgeContract;
      beforeEach("", async () => {
        deployer = (await getNamedAccounts()).deployer;
        await deployments.fixture(["all"]);
        bridgeContract = ethers.getContract("TokenBridge", deployer);
        tokenContract = ethers.getContract("Token", deployer);
      });


    describe("Send tokens", () => {

    })


    describe("Receive tokens", () => {
        
    })

    //NONCE
    //HASHED
    //SIGNATURE
    //BURN
    //MINT
    });
