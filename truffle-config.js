require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: process.env.GANACHE_PORT || 7545, // Standard Ethereum port (default: 7545)
      network_id: "*",       // Any network (default: none)
    },
    coverage: {
      host: "127.0.0.1",
      network_id: "*",
      port: 8545, 
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    kovan: {
      provider: () => new HDWalletProvider(
        process.env.KOVAN_PRIVATE_KEY,
        `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`
      ),
      network_id: 42,       // Kovan's id
      gas: 12000000,
      gasPrice: 10000000000
    },
    main: {
      provider: () => new HDWalletProvider(
        process.env.MAINNET_PRIVATE_KEY,
        `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
      ),
      network_id: 1,
      gas: 12000000,
      gasPrice: 10000000000
    }
  },

  plugins: ["solidity-coverage", "truffle-contract-size"],

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 25000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.12",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  }
}