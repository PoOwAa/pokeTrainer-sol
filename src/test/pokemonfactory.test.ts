import { BigNumber } from '@ethersproject/bignumber';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { solidity } from 'ethereum-waffle';
import { ethers } from 'hardhat';
import { PokemonFactory } from '../typechain/PokemonFactory';
import chai from 'chai';

chai.use(solidity);
const { expect } = chai;

describe('PokemonFactory', () => {
  let pokemonFactory: PokemonFactory;
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let addresses: SignerWithAddress[];

  beforeEach(async () => {
    [owner, user, ...addresses] = await ethers.getSigners();

    const PokemonFactoryContract = await ethers.getContractFactory('PokemonFactory', owner);
    pokemonFactory = (await PokemonFactoryContract.deploy()) as PokemonFactory;
  });

  it('Should create our first pokemon!', async () => {
    const pikachu = await pokemonFactory.firstPokemon('Pikachu');
    expect(pikachu.value).to.eq(0);

    const count = await pokemonFactory.getCount();
    expect(count).to.eq(1);
  });

  it('Should get my own pokemonIds', async () => {
    await pokemonFactory.firstPokemon('Pikachu');

    const pokemonIdList = await pokemonFactory.getMyPokemons();

    let contains: boolean = false;
    for (const id of pokemonIdList) {
      if (id.eq(BigNumber.from(0))) {
        contains = true;
        break;
      }
    }

    expect(contains).to.eq(true);
  });

  it('Should get the owners pokemon', async () => {
    await pokemonFactory.firstPokemon('Pikachu');

    const pokemonIdList = await pokemonFactory.getPokemonsByOwner(owner.address);

    let contains: boolean = false;
    for (const id of pokemonIdList) {
      if (id.eq(BigNumber.from(0))) {
        contains = true;
        break;
      }
    }

    expect(contains).to.eq(true);
  });

  it('Should get pokemon data', async () => {
    await pokemonFactory.firstPokemon('Pikachu');

    const pikachu = await pokemonFactory.pokemons(0);

    expect(pikachu.name).to.eq('Pikachu');
  });

  it('Should hatch an egg', async () => {
    await pokemonFactory.firstPokemon('Pikachu');

    const transaction = await pokemonFactory.hatchPokemonEgg('Bulbasaur', {
      value: ethers.utils.parseEther('0.001'),
    });
    const pokemonIdList = await pokemonFactory.getMyPokemons();
    const bulbasaur = await pokemonFactory.pokemons(pokemonIdList[pokemonIdList.length - 1]);
    expect(bulbasaur.name).to.eq('Bulbasaur');

    await expect(transaction).to.emit(pokemonFactory, 'NewPokemon');
  });
});
