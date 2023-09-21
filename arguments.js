const { ethers } = require('hardhat')

module.exports = [{
    metadataEndpoint: 'https://api.relinkd.xyz/tokenMetadata',
    isPaused: false,
    price: ethers.parseEther('0'),
    version: 'default',
    maxTokensPerUser: 1,
}]