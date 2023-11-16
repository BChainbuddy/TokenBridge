const { ethers, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function deployBridge({
  getNamedAccounts,
  deployments,
}) {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const tokenContract = await ethers.getContract("Token");

  const blockConfirmations = developmentChains.includes(network.name) ? 1 : 6;

  const args = [tokenContract.target];

  log(`Deploying the bridge contract on ${network.name}`);
  const bridgeContract = await deploy("TokenBridge", {
    from: deployer,
    log: true,
    args: args,
    waitConfirmations: blockConfirmations,
  });
  log("Contract deployed!!!");
  if (network.config.chainId == 80001) {
    log("This contract was deployed to Mumbai testnet");
    await verify(bridgeContract.address, args);
  }
  if (network.config.chainId == 11155111) {
    log("This contract was deployed to Sepolia testnet");
    await verify(bridgeContract.address, args);
  }

  // ADDING THE TOKEN ADDRESS TO THE BRIDGE TO ENABLE MINT AND BURN
  console.log("---------------------------");
  console.log(`The contract addreses for ${network.name} have been received!`);
  console.log(
    `Adding the ${bridgeContract.address} to ${tokenContract.target}`
  );
  await tokenContract.addTokenBridgeAddress(bridgeContract.address);
  console.log("The bridge contract was successfuly added!");
};

module.exports.tags = ["all", "bridge"];
