//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

contract Random {
  function randMod(uint256 _modulus, uint256 _nonce)
    internal
    view
    returns (uint256)
  {
    return
      uint256(
        keccak256(abi.encodePacked(block.timestamp, msg.sender, _nonce))
      ) % _modulus;
  }
}
