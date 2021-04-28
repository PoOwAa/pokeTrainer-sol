//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import './PokemonFactory.sol';
import './lib/SafeMath.sol';

contract PokemonAttack is PokemonFactory {
  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;
  using SafeMath8 for uint8;

  function attack(uint256 _pokemonId, uint256 _targetId)
    external
    view
    onlyOwnerOf(_pokemonId)
    returns (uint8)
  {
    Pokemon storage myPokemon = pokemons[_pokemonId];
    Pokemon storage enemyPokemon = pokemons[_targetId];

    uint256 p1Health = myPokemon.health;
    uint256 p2Health = enemyPokemon.health;

    uint256 p1Dmg = _calculateDamage(myPokemon, enemyPokemon);
    uint256 p2Dmg = _calculateDamage(enemyPokemon, myPokemon);

    // No damage on each other, it's a draw
    if (p1Dmg == 0 && p2Dmg == 0) {
      return 0;
    }

    while (p1Health > 0 && p2Health > 0) {
      // P1 attacks P2
      if (p2Health < p1Dmg) {
        p2Health = 0;
      } else {
        p2Health = p2Health.sub(p1Dmg);
      }

      // P2 attacks P1
      if (p1Health < p2Dmg) {
        p1Health = 0;
      } else {
        p1Health = p1Health.sub(p2Dmg);
      }
    }

    // Both pokemon died, it's a draw
    if (p1Health == 0 && p2Health == 0) {
      return 0;
    }

    // P2 died, the attacker (P1) win
    if (p2Health == 0) {
      return 1;
    }

    // P1 died, the target (P2) win
    return 2;
  }

  function _calculateDamage(Pokemon memory _p1, Pokemon memory _p2)
    internal
    pure
    returns (uint256)
  {
    if (_p1.atk > _p2.def) {
      return _p1.atk.sub(_p2.def);
    }

    return 0;
  }
}
