const { ethers, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function deployToken({ getNamedAccounts, deployments }) {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;
  const blockConfirmations = developmentChains.includes(network.name) ? 1 : 6;

  const args = [];

  log(`Deploying the token contract on ${network.name}`);
  const tokenContract = await deploy("Token", {
    from: deployer,
    log: true,
    args: args,
    waitConfirmations: blockConfirmations,
  });
  log("Contract deployed!!!");
  if (network.config.chainId == 80001) {
    log("This contract was deployed to Mumbai testnet");
    await verify(tokenContract.address, args);
  }
  if (network.config.chainId == 11155111) {
    log("This contract was deployed to Sepolia testnet");
    await verify(tokenContract.address, args);
  }
};

module.exports.tags = ["all", "token"];
