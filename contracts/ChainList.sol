pragma solidity ^0.4.18;

// http://solidity.readthedocs.io/en/latest/contracts.html#inheritance
import "./Ownable.sol";

contract ChainList is Ownable {
  // custom types
  struct Article {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price; // in wai == eth^-18
  }

  // state variables
  address owner;
  mapping (uint => Article) public articles; // array/dict, zeroed, not iterable
  // uint == uint256 actually
  uint articleCounter; // To keep track of size of the mapping

  // events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );
  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );

  // constructor, not always needed
  // Called ONLY one time, when the contract is deloyed.
  //constructor() public {
  //  owner = msg.sender;
  //}

  // deactivate the contract
  // Will cost negative gas, ie cleaning the blockchain is rewarded.
  // Any ether (or other tokens?) in the contract is refunded to owner
  // Call from truffle if needed:
  // app.kill({from: web3.eth.accounts[0]})
  // NOTE: a selfdestructed contract can still recieve ether, but they get stuck!
  // New nameserver, where you can change what it points to in order to avoid above problem:
  // https://ens.domains/ 
  function kill() public onlyOwner {
    // only allow the contract owner
    //require(msg.sender == owner); // not needed when we have onlyOwner modifier
    selfdestruct(owner);
  }

  // sell an article
  // calling this will cost gas
  function sellArticle(string _name, string _description, uint256 _price) public {
    // a new article
    articleCounter++;

    // store this article
    articles[articleCounter] = Article(
      articleCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price
    );
    // declare event
    emit LogSellArticle(articleCounter, msg.sender, _name, _price);
  }

  // fetch the number of articles in the contract
  function getNumberOfArticles() public view returns (uint) {
    return articleCounter;
  }

  // fetch and return all article IDs for articles still for sale
  // view --> free to call, only read
  // pure --> free to call, can not modify or read state variables, usually used for util functions
  function getArticlesForSale() public view returns (uint[]) {
    // prepare output array
    uint[] memory articleIds = new uint[](articleCounter);
    // memory == not stored in contract: cheaper gas (or no gas) cost

    uint numberOfArticlesForSale = 0;
    // iterate over articles
    for(uint i = 1; i <= articleCounter;  i++) {
      // keep the ID if the article is still for sale
      if(articles[i].buyer == 0x0) {
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }

    // copy the articleIds array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for(uint j = 0; j < numberOfArticlesForSale; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

  // buy an article
  // payable --> function may recieve value/ether. If a function not is payable,
  // then it is not possible to send ether to it (only gas).
  function buyArticle(uint _id) payable public {
    // we check whether there is an article for sale
    require(articleCounter > 0);

    // we check that the article exists
    // But if I seel one in the middle: ok, it is not removed, just set as sold by having a buyer
    require(_id > 0 && _id <= articleCounter);

    // we retrieve the article
    // storage == modifications to its members will be stored in the contract state
    Article storage article = articles[_id];
    // zzz check null!?

    // we check that the article has not been sold yet
    require(article.buyer == 0X0);

    // we don't allow the seller to buy his own article
    require(msg.sender != article.seller);

    // we check that the value sent corresponds to the price of the article
    require(msg.value == article.price);

    // keep buyer's information
    article.buyer = msg.sender;

    // the buyer can pay the seller
    // The transfer() function is new, the old send() is not that safe.
    // Programmer need to check returned value and revert "manually" in case of error/false return.
    article.seller.transfer(msg.value);

    // trigger the event
    emit LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }
}
