pragma solidity ^0.4.18;

contract ChainList {
  // state variables
  address seller;
  string name;
  string description;
  uint256 price; // in wai == eth^-18

  // sell an article, calling this will cost gas
  function sellArticle(string _name, string _description, uint256 _price) public {
    seller = msg.sender;
    name = _name;
    description = _description;
    price = _price;
  }

  // get an article
  // view --> free to call, only read
  // pure --> free to call, can not modify or read state variables, usually used for util functions
  function getArticle() public view returns (
    address _seller,
    string _name,
    string _description,
    uint256 _price
  ) {
      return(seller, name, description, price);
  }
}
