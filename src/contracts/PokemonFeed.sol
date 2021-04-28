//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import './PokemonFactory.sol';
import './lib/SafeMath.sol';

contract PokemonFeed is PokemonFactory {
  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;
  using SafeMath8 for uint8;

  uint256 feedPokemonFee = 0.001 ether;

  function setFeedPokemonFee(uint256 _newFee) external onlyOwner {
    feedPokemonFee = _newFee;
  }

  function feedPokemon(uint256 _pokemonId)
    external
    payable
    onlyOwnerOf(_pokemonId)
  {
    require(msg.value >= feedPokemonFee);
    _feedPokemon(_pokemonId);

    // Send back the leftover ether
    if (msg.value > feedPokemonFee) {
      address payable sender = payable(msg.sender);
      sender.transfer(msg.value - feedPokemonFee);
      // TODO: emit event overpay!
    }
  }

  function _feedPokemon(uint256 _pokemonId) internal view {
    Pokemon storage myPokemon = pokemons[_pokemonId];
    myPokemon.level.add(1);
    myPokemon.atk.add(myPokemon.level**2);
    myPokemon.def.add(myPokemon.level * 2);
    myPokemon.health.mul(myPokemon.level);
  }
}
