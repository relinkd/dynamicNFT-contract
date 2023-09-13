const hre = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("RScore");
  const contract = await Contract.deploy();

  console.log('address', contract)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
