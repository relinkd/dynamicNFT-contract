// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const Contract = await ethers.getContractFactory("RScore");
  const contract = await Contract.attach('0x4B627F6988770849e7DF37BAd2658E4519f07d48');


  console.log(await contract.mint('0x889aeaC6e58b143F33FB2bE28f1406839D0ce05A'))
// const transaction = await contract.tokenURI(0)
// console.log(transaction);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});