import { HardhatRuntimeEnvironment, HardhatUserConfig } from 'hardhat/types';
import { task } from 'hardhat/config';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-typechain';

task('accounts', 'Prints the list of accounts', async (args, hre: HardhatRuntimeEnvironment) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.7.6',
        settings: {},
      },
    ],
  },
  paths: {
    root: 'src',
  },
  typechain: {
    outDir: 'src/typechain',
    target: 'ethers-v5',
  },
};

export default config;
