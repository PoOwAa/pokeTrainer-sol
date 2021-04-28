import { run, ethers } from 'hardhat';

async function deploySmartContract() {
  await run('compile');

  const PokemonFactory = await ethers.getContractFactory('PokemonFactory');
  const pokemonFactory = await PokemonFactory.deploy();

  await pokemonFactory.deployed();

  console.log(`PokemonFactory deployed! Address: ${pokemonFactory.address}`);
}

deploySmartContract()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
