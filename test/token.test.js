const { assert, expect } = require("chai");
const { network, getNamedAccounts, deployments } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Token test", function () {
      let deployer, tokenContract, bridgeContract, amount, user;
      beforeEach("", async () => {
        deployer = (await getNamedAccounts()).deployer;
        const accounts = await ethers.getSigners();
        user = accounts[1];
        await deployments.fixture(["all"]);
        bridgeContract = await ethers.getContract("TokenBridge", deployer);
        tokenContract = await ethers.getContract("Token", deployer);
        amount = ethers.parseEther("1");
      });

      describe("Does the function revert", () => {
        it("Modifier", async () => {
          await expect(tokenContract.bridgeBurn(deployer, amount)).to.be
            .reverted;
          await expect(tokenContract.bridgeMint(deployer, amount)).to.be
            .reverted;
        });
        it("The token Bridge was added successfuly", async () => {
          assert.equal(
            await tokenContract.tokenBridgeAddress(),
            bridgeContract.target
          );
        });
        it("Only owner can change bridge contract, the bridge contract gets changed", async () => {
          const connectedUser = tokenContract.connect(user);
          await expect(connectedUser.addTokenBridgeAddress(deployer)).to.be
            .reverted;
          await tokenContract.addTokenBridgeAddress(deployer);
          assert.equal(await tokenContract.tokenBridgeAddress(), deployer);
        });
      });
    });
