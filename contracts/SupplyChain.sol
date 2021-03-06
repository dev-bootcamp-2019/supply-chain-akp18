pragma solidity ^0.4.23;

 

contract SupplyChain
{
 

  /* set owner */
  address owner;
 

  /* Add a variable called skuCount to track the most recent sku # */
  uint skuCount;
 

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping(uint => Item) items;
 

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */

  enum State
  {

    ForSale,
    Sold,
    Shipped,
    Received
  }
 

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
  */

  struct Item
  {
    string name;
    uint sku;
    uint price;
    State state;
    address seller;
    address buyer;  
  }

 
  /* Create 4 events with the same name as each possible State (see above)
    Each event should accept one argument, the sku*/
  event ForSale(uint sku);
  event Sold(uint sku);
  event Shipped(uint sku);
  event Received(uint sku);


/* Create a modifer that checks if the msg.sender is the owner of the contract */

  modifier verifyCaller (address _address) { require (msg.sender == _address); _;} 

  modifier paidEnough(uint _price) { require(msg.value >= _price); _;}

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  } 

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. */
  modifier forSale (uint sku) {require(items[sku].state == State.ForSale); _;}
  modifier sold (uint sku) {require(items[sku].state == State.Sold); _;}
  modifier shipped (uint sku) {require(items[sku].state == State.Shipped); _;}
  modifier received (uint sku) {require(items[sku].state == State.Received); _;}
 

  constructor() public{
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */ 
       skuCount = 0;
       owner = msg.sender;
  } 

  function addItem(string _name, uint _price) public returns(bool)
  {
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
    skuCount += 1;
    return true;
  }
 

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/ 

  function buyItem(uint sku) paidEnough(items[sku].price) forSale(sku) checkValue(sku) public payable
  {
    //Check conditions
    require(items[sku].buyer == 0); //make sure that item has not already been purchased    
    //Payment to the seller and return remaining balance to buyer
    items[sku].seller.transfer(msg.value - items[sku].price); //pay the seller
    //Update the item properties
    items[sku].state = State.Sold; //set the state of the item to sold
    items[sku].buyer = msg.sender;
    emit Sold(sku);
  }


  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint sku) sold(sku) public
  {
    require(items[sku].seller == msg.sender); //make sure that the buyer is calling the function
    items[sku].state = State.Shipped;
    emit Shipped(sku);
  } 

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)  shipped(sku) public
  {
    require(items[sku].buyer == msg.sender); //make sure that the buyer is calling the function
    emit Received(sku);
    items[sku].state = State.Received;
  }


  /* We have these functions completed so we can run tests, just ignore it :) */
  function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}
