const { network } = require("hardhat");

async function addTokensToBridge() {
  let tokenContract, bridgeContract;

  console.log("Finding the contract addresses...");
  bridgeContract = await ethers.getContract("TokenBridge");
  tokenContract = await ethers.getContract("Token");
  console.log(`The contract addreses for ${network.name} have been received!`);
  console.log(`Adding the ${bridgeContract.target} to ${tokenContract.target}`);
  await tokenContract.addTokenBridgeAddress(bridgeContract.address);
  console.log("The bridge contract was successfuly added!");
}

addTokensToBridge()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
