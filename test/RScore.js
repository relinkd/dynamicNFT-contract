const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {

  let rScore, RScore, owner, otherAccount

  beforeEach(async () => {

    // Contracts are deployed using the first signer/account by default
    [owner, otherAccount] = await ethers.getSigners();

    RScore = await ethers.getContractFactory("RScore");
    rScore = await RScore.deploy();

  })

  describe("Deployment", function () {


    it("Check Empty Maps", async function () {
      

      console.log(await lock.tokenIdToAddress, 'testAddress')
      console.log(await lock.mint(owner, testScore), 'testScore')
      console.log(await lock.tokenURI(0), 'tokenURI')

    });

  });

 
});
