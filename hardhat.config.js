require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-web3-v4");

/** @type import('hardhat/config').HardhatUserConfig */
const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.0',
  settings: {
    //evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 200,
    }
  }
}

module.exports = {
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
};
