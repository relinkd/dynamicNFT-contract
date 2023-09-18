require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "hardhat",
  // allowUnlimitedContractSize: true,
  settings: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
        details: { yul: false }
      },
    },
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/4UmtUzP8lxDs0py28-rdGB7LvyVk9lV7`,
      accounts: [
        process.env.ADDRESS1,
        process.env.ADDRESS2,
        process.env.ADDRESS3
      ],
      // gasMultiplier: 1,
      // gas: 50000000,
      // gasPrice: 250000000000,
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/9KJSOnqmLZ11g9l-O0BxrfYEALnGZ0bG`,
      accounts: [
        process.env.ADDRESS1,
        process.env.ADDRESS2,
        process.env.ADDRESS3
      ],
      gas: 50000000,
      gasPrice: 250000000000,
    },
    polygon: {
      url: "https://polygon-rpc.com",
      // chainId: 137,
      gas: 50000000,
      gasPrice: 250000000000,
      accounts: [
        process.env.ADDRESS1,
        process.env.ADDRESS2,
        process.env.ADDRESS3
      ],
    },
    hardhat: {
      blockGasLimit: 100000000,
      accounts: {
        count: 10
      }
    }
  }
};
