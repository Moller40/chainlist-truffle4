pragma solidity ^0.4.18;

contract Ownable {
  // state variables
  address owner;

  // modifiers
  modifier onlyOwner() {
    require(msg.sender == owner);
    _; // placeholder for the code that the modifier is applied to, it will just be "inserted here"
  }

  // constructor
  constructor() public {
    owner = msg.sender;
  }
}
