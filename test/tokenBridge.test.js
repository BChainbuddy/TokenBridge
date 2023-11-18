const { assert, expect } = require("chai");
const { network, getNamedAccounts, deployments, ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("BridgeToken test", function () {
      let deployer, tokenContract, bridgeContract, amount, signer, signer2;
      beforeEach("", async () => {
        deployer = (await getNamedAccounts()).deployer;
        await deployments.fixture(["all"]);
        bridgeContract = await ethers.getContract("TokenBridge", deployer);
        tokenContract = await ethers.getContract("Token", deployer);
        amount = ethers.parseEther("1");
        const accounts = await ethers.getSigners();
        signer = accounts[0];
        signer2 = accounts[1];
        await tokenContract.mintTokens(deployer, amount);
      });

      describe("Send tokens", () => {
        //SIGN THE HASH
        it("Signs and verifies the hash", async () => {
          const messageHash = await bridgeContract.messageHash(
            signer.address,
            amount
          );

          const signature = await signer.signMessage(
            ethers.getBytes(messageHash)
          ); // getBytes is arrayify in ethers v5

          // CORRECT SIGNATURE
          assert.equal(
            await bridgeContract.verifySignature(
              signer.address,
              messageHash,
              signature
            ),
            true
          );

          // UNCORRECT SIGNATURE
          assert.equal(
            await bridgeContract.verifySignature(
              signer2.address,
              messageHash,
              signature
            ),
            false
          );
        });
        it("Sends the tokens", async () => {
          const balanceBefore = await tokenContract.balanceOf(deployer);
          assert.equal(balanceBefore, amount);
          const messageHash = await bridgeContract.messageHash(
            signer.address,
            amount
          );
          const signature = await signer.signMessage(
            ethers.getBytes(messageHash)
          );
          await bridgeContract.sendTokens(signer.address, amount, signature);
          const balanceAfter = await tokenContract.balanceOf(deployer);
          assert.equal(balanceAfter.toString(), "0");
          await expect(
            bridgeContract.sendTokens(signer.address, amount, signature)
          ).to.be.reverted;
        });
      });

      describe("Receive tokens", () => {
        it("Receives the tokens", async () => {
          //CHECK NONCE
          expect(
            await bridgeContract.getCurrentNonce(signer.address)
          ).to.be.equal("0");
          //GETS THE SIGNATURE
          const balanceBefore = await tokenContract.balanceOf(deployer);
          assert.equal(balanceBefore, amount);
          const messageHash = await bridgeContract.messageHash(
            signer.address,
            amount
          );
          const signature = await signer.signMessage(
            ethers.getBytes(messageHash)
          );
          // REVERTS THE MINT IF TOKENS HAVEN'T BEEN BURNED YET
          await expect(
            bridgeContract.receiveTokens(signer.address, amount, signature)
          ).to.be.reverted;
          // SEND THE TOKENS
          await bridgeContract.sendTokens(signer.address, amount, signature);
          const balanceAfter = await tokenContract.balanceOf(deployer);
          assert.equal(balanceAfter.toString(), "0");
          await expect(
            bridgeContract.sendTokens(signer.address, amount, signature)
          ).to.be.reverted;
          //RECEIVES THEM
          const balanceBeforeMint = await tokenContract.balanceOf(deployer);
          assert.equal(balanceBeforeMint, "0");
          await bridgeContract.receiveTokens(signer.address, amount, signature);
          const balanceAfterMint = await tokenContract.balanceOf(deployer);
          assert.equal(balanceAfterMint.toString(), amount);
          await expect(
            bridgeContract.receiveTokens(signer.address, amount, signature)
          ).to.be.reverted;
          //INCREMENTS THE NONCE
          expect(
            await bridgeContract.getCurrentNonce(signer.address)
          ).to.be.equal("1");
        });
      });
    });
