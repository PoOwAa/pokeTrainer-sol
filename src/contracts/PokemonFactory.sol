//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import './lib/Ownable.sol';
import './lib/SafeMath.sol';
import './lib/Random.sol';
import 'hardhat/console.sol';

contract PokemonFactory is Ownable, Random {
  using SafeMath for uint256;
  using SafeMath16 for uint16;

  event NewPokemon(uint256 id, string name, uint8 pokeType, uint8 level, uint16 atk, uint16 def, uint256 health);

  struct Pokemon {
    string name;
    uint8 pokeType;
    uint8 level;
    uint16 atk;
    uint16 def;
    uint256 health;
  }

  Pokemon[] public pokemons;
  uint256 newPokemonFee = 0.001 ether;
  uint256 pokeCount = 0;

  mapping(uint256 => address) pokemonToOwner;
  mapping(address => uint16) ownerPokemonCount;

  modifier onlyOwnerOf(uint256 _id) {
    require(msg.sender == pokemonToOwner[_id]);
    _;
  }

  function setNewPokemonFee(uint256 _newFee) external onlyOwner {
    newPokemonFee = _newFee;
  }

  function getCount() public view returns (uint256) {
    return pokeCount;
  }

  function getOwnerPokemonCount(address _owner) public view returns (uint256) {
    return ownerPokemonCount[_owner];
  }

  function getMyPokemonCount() public view returns (uint256) {
    return ownerPokemonCount[msg.sender];
  }

  function firstPokemon(string calldata _name) external returns (uint256) {
    require(ownerPokemonCount[msg.sender] == 0);

    uint8 pokeType;
    uint16 atk;
    uint16 def;
    uint256 health;

    (pokeType, atk, def, health) = _generatePokeData();

    return _createPokemon(_name, pokeType, atk, def, health);
  }

  function hatchPokemonEgg(string calldata _name) external payable returns (uint256) {
    require(msg.value >= newPokemonFee);

    uint8 pokeType;
    uint16 atk;
    uint16 def;
    uint256 health;

    (pokeType, atk, def, health) = _generatePokeData();

    uint256 newPokemonId = _createPokemon(_name, pokeType, atk, def, health);
    if (msg.value > newPokemonFee) {
      address payable sender = payable(msg.sender);
      sender.transfer(msg.value - newPokemonFee);
      // TODO: emit event overpay!
    }

    console.log('New pokemon id %s', newPokemonId);

    return newPokemonId;
  }

  function getMyPokemons() external view returns (uint256[] memory) {
    return _getPokemonsByOwner(msg.sender);
  }

  function getPokemonsByOwner(address _owner) external view returns (uint256[] memory) {
    return _getPokemonsByOwner(_owner);
  }

  function _getPokemonsByOwner(address _owner) internal view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](ownerPokemonCount[_owner]);
    uint256 counter = 0;
    console.log('There are %s pokemons', pokemons.length);
    for (uint256 i = 0; i < pokemons.length; i++) {
      if (pokemonToOwner[i] == _owner) {
        console.log('counter [%s] Pokemon [%s] matches to owner [%s]', counter, i, _owner);
        result[counter] = i;
        counter++;
      }
    }

    return result;
  }

  function _createPokemon(
    string calldata _name,
    uint8 _pokeType,
    uint16 _atk,
    uint16 _def,
    uint256 _health
  ) internal returns (uint256) {
    pokemons.push(Pokemon(_name, _pokeType, 1, _atk, _def, _health));
    uint256 id = pokemons.length - 1;
    pokemonToOwner[id] = msg.sender;
    ownerPokemonCount[msg.sender] = ownerPokemonCount[msg.sender].add(1);
    pokeCount++;
    emit NewPokemon(id, _name, _pokeType, 1, _atk, _def, _health);
    console.log('New pokemon has been created! %s %s %s', id, _name, _pokeType);
    return id;
  }

  function _generatePokeData()
    internal
    view
    returns (
      uint8 pokeType,
      uint16 atk,
      uint16 def,
      uint256 health
    )
  {
    pokeType = uint8(randMod(255, 0));
    atk = uint16(randMod(100, 1));
    def = uint16(randMod(100, 2));
    health = 100 + uint16(randMod(500, 3));
  }
}
