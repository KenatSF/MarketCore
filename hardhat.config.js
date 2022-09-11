require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")
require('hardhat-contract-sizer');
require("dotenv").config();
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    compilers: [
        {
            version: "0.8.0"
        },
        {
            version: "0.8.1"
        }
    ]
  },
  networks: {
    hardhat:{
      chainId: 1337
    }, 
    avalanche: {
      url: `https://api.avax.network/ext/bc/C/rpc`,
      chainId: 43114,
      accounts: [PRIVATE_KEY],
      gasLimit: 3000000,
      gasPrice: 27000000000
    },
    fuji: {
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      chainId: 43113,
      accounts: [PRIVATE_KEY],
      gasLimit: 3000000,
      gasPrice: 27000000000
    },
    polygon: {
      url: `https://rpc-mainnet.maticvigil.com/`,
      chainId: 137,
      accounts: [PRIVATE_KEY],
      gasLimit: 3000000,
      gasPrice: 50000000000
    },
  },
  etherscan: {
    apiKey: process.env.API_KEY_POLYGON_SCAN
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};