// test/RScore.js
const { expect } = require('chai');
const { ethers } = require('hardhat')

describe('RScore', function () {
  let RScore;
  let rscore;
  let owner;
  let addr1;
  let addr2;
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

  beforeEach(async function () {
    RScore = await ethers.getContractFactory('RScore');
    [owner, addr1, addr2] = await ethers.getSigners();

    rscore = await RScore.deploy({
      metadataEndpoint: 'https://example.com/api/metadata/',
      isPaused: false,
      price: ethers.parseEther('0.1'),
      version: 'default',
      maxTokensPerUser: 1,
    });

  });

  describe('mint', function () {
    it('should mint a token to the receiver', async function () {
      await rscore.connect(owner).mint(owner.address);

      expect(await rscore.ownerOf(0)).to.equal(owner.address);
    });

    it('should not mint if contract is paused', async function () {
      await rscore.setProtocolState({
        metadataEndpoint: 'https://example.com/api/metadata/', 
        isPaused: true, 
        price: ethers.parseEther('0.2'), 
        version: 'default',
        maxTokensPerUser: 1,
      });
      await expect(rscore.connect(addr1).mint(addr1.address))
        .to.be.revertedWith('Contract is paused');
    });

    it('should mint for free if price is 0', async function () {
      await rscore.setProtocolState({
        metadataEndpoint: 'https://example.com/api/metadata/', 
        isPaused: false, 
        price: ethers.parseEther('0'), 
        version: 'default',
        maxTokensPerUser: 1,
      });
      await expect(rscore.connect(addr1).mint(addr1.address))
        .to.emit(rscore, 'Transfer')
        .withArgs(ZERO_ADDRESS, addr1.address, 0);
    });

    it('should require correct payment if price is greater than 0', async function () {
      await expect(rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.09') }))
        .to.be.revertedWith('Value is not enough');

      await expect(rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.2') }))
    });

    it('should prevent duplicate mints for the same address', async function () {
      await rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.1') });
      await expect(rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.1') }))
        .to.be.revertedWith('Address already owns a token');
    });

    it('tokenOfOwnerByIndex check', async function () {
      await rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.1') });
      expect(await rscore.tokenOfOwnerByIndex(addr1.address, 0)).to.equal(0);

    })
  });

  describe('bulkMint', function () {
    it('should bulk mint tokens to the specified addresses', async function () {
      const addresses = [addr1.address, addr2.address];
      await expect(rscore.connect(owner).bulkMint(addresses))
        .to.emit(rscore, 'Transfer')
        .withArgs(ZERO_ADDRESS, addr1.address, 0)
        .to.emit(rscore, 'Transfer')
        .withArgs(ZERO_ADDRESS, addr2.address, 1);

      expect(await rscore.ownerOf(0)).to.equal(addr1.address);
      expect(await rscore.ownerOf(1)).to.equal(addr2.address);
    });

    it('should not bulk mint if not called by owner', async function () {
      const addresses = [addr1.address, addr2.address];
      await expect(rscore.connect(addr1).bulkMint(addresses))
        .to.be.revertedWith('Ownable: caller is not the owner');
    });
  });

  describe('tokenURI', function () {
    it('should return correct URI', async function () {
      await rscore.connect(owner).mint(owner.address);
      const uri = await rscore.tokenURI(0);
      
      expect(uri).to.equal(`https://example.com/api/metadata/?tokenId=0&owner=${owner.address.toLowerCase()}&version=default`);
    });

    it('should revert for non-existent token', async function () {
      await expect(rscore.tokenURI(999)).to.be.revertedWith('Token does not exist');
    });
  });

  describe('setProtocolState', function () {
    it('should set protocol state', async function () {
      await rscore.connect(owner).setProtocolState({
        metadataEndpoint: 'https://example.com/api/metadata/', 
        isPaused: true, 
        price: ethers.parseEther('0.2'), 
        version: 'default',
        maxTokensPerUser: 1,
      });
      const state = await rscore.getProtocolState();

      expect(state.metadataEndpoint).to.equal('https://example.com/api/metadata/');
      expect(state.isPaused).to.equal(true);
      expect(state.price).to.equal(ethers.parseEther('0.2'));
      expect(state.version).to.equal('default');
    });

    it('should only be callable by owner', async function () {
      await expect(rscore.connect(addr1).setProtocolState({
        metadataEndpoint: 'https://example.com/api/metadata/', 
        isPaused: true, 
        price: ethers.parseEther('0.2'), 
        version: 'default',
        maxTokensPerUser: 1,
      }))
        .to.be.revertedWith('Ownable: caller is not the owner');
    });
  });

  describe('withdrawFunds', function () {
    it('should withdraw funds to specified recipient', async function () {
      await rscore.connect(addr1).mint(addr1.address, { value: ethers.parseEther('0.1') });
      const initialBalance = await ethers.provider.getBalance(addr2.address);

      await rscore.connect(owner).withdrawFunds(addr2.address);

      const finalBalance = await ethers.provider.getBalance(addr2.address);
      const expectedFinalBalance = 10000100000000000000000n
      expect(finalBalance).to.equal(expectedFinalBalance);
    });

    it('should only be callable by owner', async function () {
      await expect(rscore.connect(addr1).withdrawFunds(addr1.address))
        .to.be.revertedWith('Ownable: caller is not the owner');
    });
  });
});
