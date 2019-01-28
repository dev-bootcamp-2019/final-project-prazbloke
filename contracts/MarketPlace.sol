pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol"; // Demonstration of usage of Library. SafeMath local instance is adapted to solidity 0.5.0

contract MarketPlace {

  using SafeMath for uint;

  bool public Emergency; // Circuit-breaker flag

  address public SuperAdministrator; // Super Administrator who is owner of the MarketPlace contract and can add other Administrators

  address[] public AdministratorList; // List of Administrators
  StoreOwner[] public StoreOwnerList; // List of Store Owners
  StoreFront[] public StoreFrontList; // List of Store Fronts
  Product[] public ProductList; // List of Products

  struct StoreOwner {
    uint so_id; //Store Owner ID
    string so_name; //Store Owner Name
    address so_address; //Store Owner Address
    uint so_balance; //Store Owner Balance
    uint[] so_sf_ids; //Array of StoreFront IDs (used as Indices to retrieve the relevant StoreFront object from StoreFrontList Array)
  }

  struct StoreFront {
    uint sf_id; //Store Front ID
    string sf_name; //Store Front Name
    uint[] sf_pdt_ids; ////Array of Product IDs (used as Indices to retrieve the relevant Product object from ProductList Array)
  }

  struct Product {
    uint pdt_id; //Product ID
    string pdt_name; //Product Name
    uint pdt_price; //Product Price
    uint pdt_qty; //Product Quantity
  }

  enum ActorType {NonExistentActor, Administrator, StoreOwner}
  enum ObjectType {NonExistentObject, StoreFront, Product}
  enum ObjectOwnerType {NonExistentObjectOwner, StoreOwner, StoreFront}

  mapping (address => ActorType) Actors; //Administrators and StoreOwners are considered Actors
  mapping (address => uint) ActorIDs; //Mapping Actors to their respective IDs can be used to retrieve them for their respective List Array
  mapping (string => ObjectType) Objects; //StoreFronts and Products are considered Objects
  mapping (string => uint) ObjectIDs; //Mapping Objects to their respective IDs can be used to retrieve them for their respective List Array
  mapping (string => ObjectOwnerType) ObjectOwners; //StoreOwners and StoreFronts are considered Object Owners.
  mapping (string => uint) ObjectOwnerIDs; //Mapping Object Owners to their respective IDs can be used to retrieve them for their respective List Array

  event ActorRegistryUpdate(address indexed _actor_id, ActorType _actor_type, string _status);
  event ObjectRegistryUpdate(address indexed _actor_id, ActorType _actor_type, uint _object_id, ObjectType _object_type, string _status);
  event TransactionRegistryUpdate(address indexed _actor_id, ActorType _actor_type, string _transaction_type, string _status);

  modifier StopInEmergency() {require(!Emergency); _;} //Allows normal user functioning of MarketPlace only in the absence of an Emergency
  modifier OnlyInEmergency() {require(Emergency); _;} //Allows only SuperAdministrator to perform Emergency function like Lifting Emergency
  modifier isSuperAdministrator() {require(msg.sender == SuperAdministrator); _;} //Can execute only if SuperAdministrator
  modifier isAdministrator() {require(Actors[msg.sender] == ActorType.Administrator); _;} //Can execute only if Administrator
  modifier isStoreOwner() {require(Actors[msg.sender] == ActorType.StoreOwner); _;} //Can execute only if StoreOwner
  modifier isShopper() {require(Actors[msg.sender] == ActorType.NonExistentActor); _;} //Can execute only if Shopper (i.e., not in the mapped list of Actors)

  constructor() public {
       SuperAdministrator = msg.sender;
       Actors[SuperAdministrator] = ActorType.Administrator;
       AdministratorList.push(SuperAdministrator); //SuperAdministrator is the very first Administrator
  }

    /*SuperAdministrator Functions*/

  function DeclareEmergency() //Impose Circuit-breaker in case of emergency
  public
  isSuperAdministrator
  returns(bool)
  {
    Emergency = true;
    return (Emergency);
  }

  function LiftEmergency() //Lift Circuit-breaker once emergency is addressed
  public
  OnlyInEmergency isSuperAdministrator
  returns(bool)
  {
    Emergency = false;
    return (!Emergency);
  }

  function AddAdministrator(address _Administrator) // A function where by only SuperAdministrator can add an Administrator. Returns true if Successful and false if Administrator already exists as Administrator type or exists as another ActorType.
  public
  StopInEmergency isSuperAdministrator
  returns(bool){
    if(Actors[_Administrator] == ActorType.NonExistentActor)
    {
        Actors[_Administrator] = ActorType.Administrator;
        ActorIDs[_Administrator] = AdministratorList.length;
        AdministratorList.push(_Administrator); //Add to AdministratorList
        emit ActorRegistryUpdate(_Administrator, Actors[_Administrator],"Newly Added as Administrator!");
        return true;
    }
    else
    {
        if(Actors[_Administrator] == ActorType.Administrator)
        {
            emit ActorRegistryUpdate(_Administrator, Actors[_Administrator],"Already Exists as Administrator!");
            return false;
        }
        else
        {
            emit ActorRegistryUpdate(_Administrator, Actors[_Administrator],"Failed to Add as Administrator! Already Exists as Another Type of Actor!");
            return false;
        }
    }
  }

    /*Administrator Functions*/

  // A function where by only an Administrator can add a Store Owner.
  //Returns true if Successful and false if Store Owner already exists as Store Owner type or exists as another ActorType.

  function AddStoreOwner(address _StoreOwner, string memory _StoreOwnerName)
  public
  StopInEmergency isAdministrator
  returns (bool){
    if(Actors[_StoreOwner] == ActorType.NonExistentActor)
    {
      Actors[_StoreOwner] = ActorType.StoreOwner;
      ActorIDs[_StoreOwner] = StoreOwnerList.length;

      StoreOwner memory _tempStoreOwner;
      _tempStoreOwner.so_id = ActorIDs[_StoreOwner];
      _tempStoreOwner.so_name = _StoreOwnerName;
      _tempStoreOwner.so_address = _StoreOwner;
      _tempStoreOwner.so_balance = 0; //Initialize store owner balance as 0

      StoreOwnerList.push(_tempStoreOwner); //Add to StoreOwnerlist
      emit ActorRegistryUpdate(_StoreOwner, Actors[_StoreOwner], "Newly Added as StoreOwner!");
      return true;
    }
    else
    {
        if(Actors[_StoreOwner] == ActorType.StoreOwner)
        {
            emit ActorRegistryUpdate(_StoreOwner, Actors[_StoreOwner],"Already Exists as StoreOwner!");
            return false;
        }
        else
        {
            emit ActorRegistryUpdate(_StoreOwner, Actors[_StoreOwner],"Failed to Add as StoreOwner! Already Exists as Another Type of Actor!");
            return false;
        }
    }
  }

    /*StoreOwner Functions*/

  //A function where by only a Store Owner can add a Store Front.
  //Returns true if Successful and false if Store Front already exists as Store Front type or exists as another ObjectType.

  function AddStoreFront(string memory _StoreFrontName)
  public
  StopInEmergency isStoreOwner
  returns (bool){
    if(Objects[_StoreFrontName] == ObjectType.NonExistentObject)
    {
      Objects[_StoreFrontName] = ObjectType.StoreFront;
      ObjectIDs[_StoreFrontName] = StoreFrontList.length;

      StoreFront memory _tempStoreFront;
      _tempStoreFront.sf_id = ObjectIDs[_StoreFrontName];
      _tempStoreFront.sf_name = _StoreFrontName;

      StoreFrontList.push(_tempStoreFront); //Add to StorefrontList
      ObjectOwners[_StoreFrontName] = ObjectOwnerType.StoreOwner; // Track the ObjectOwnerType as Storeowner
      ObjectOwnerIDs[_StoreFrontName] = ActorIDs[msg.sender]; // Track the ID of ObjectOwner (i.e., StoreOwner) to easily retrieve by index from Array StoreOwnerList
      StoreOwnerList[ObjectOwnerIDs[_StoreFrontName]].so_sf_ids.push(ObjectIDs[_StoreFrontName]); // Track StoreFront ID in an Array within StoreOwner owner to easily retrieve by index from Array StoreFrontList

      emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_StoreFrontName], Objects[_StoreFrontName], "Newly Added as StoreFront!");
      return true;
    }
    else
    {
        if(Objects[_StoreFrontName] == ObjectType.StoreFront)
        {
            emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_StoreFrontName], Objects[_StoreFrontName], "Already Exists as StoreFront!");
            return true;
        }
        else
        {
            emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_StoreFrontName], Objects[_StoreFrontName], "Failed to Add as StoreFront! Already Exists as Another Type of Object!");
            return false;
        }
    }
  }

  //A function where by only a Store Owner can add a Product under a specific Store Front.
  //Returns true if Successful and false if Product already exists as Product Type or exists as another ObjectType.

  function AddProduct(string memory _StoreFrontName, string memory _ProductName, uint _ProductPrice, uint _ProductQty)
  public
  StopInEmergency isStoreOwner
  returns (bool){
    require (Objects[_StoreFrontName] == ObjectType.StoreFront && StoreOwnerList[ObjectOwnerIDs[_StoreFrontName]].so_address == msg.sender);

    if(Objects[_ProductName] == ObjectType.NonExistentObject)
    {
      Objects[_ProductName] = ObjectType.Product;
      ObjectIDs[_ProductName] = ProductList.length;

      Product memory _tempProduct;
      _tempProduct.pdt_id = ObjectIDs[_ProductName];
      _tempProduct.pdt_name = _ProductName;
      _tempProduct.pdt_price = _ProductPrice;
      _tempProduct.pdt_qty = _ProductQty;

      ProductList.push(_tempProduct); //Add to ProductList
      ObjectOwners[_ProductName] = ObjectOwnerType.StoreFront; // Track the ObjectOwnerType as StoreFront
      ObjectOwnerIDs[_ProductName] = ObjectIDs[_StoreFrontName]; // Track the ID of ObjectOwner (i.e., StoreFront) to easily retrieve by index from Array StoreFrontList
      StoreFrontList[ObjectOwnerIDs[_ProductName]].sf_pdt_ids.push(ObjectIDs[_ProductName]); // Track Product ID in an Array within the StoreFront owner to easily retrieve by index from Array ProductList

      emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_StoreFrontName], Objects[_StoreFrontName], "Newly Added as Product!");
      return true;
    }
    else
    {
        if(Objects[_ProductName] == ObjectType.Product)
        {
            emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_ProductName], Objects[_ProductName], "Already Exists as Product!");
            return false;
        }
        else
        {
            emit ObjectRegistryUpdate(msg.sender, Actors[msg.sender], ObjectIDs[_ProductName], Objects[_ProductName], "Failed to Add as Product! Already Exists as Another Type of Object!");
            return false;
        }
    }
  }

  function WithdrawBalance(uint _WithdrawAmount)
  public
  StopInEmergency isStoreOwner
  returns(bool)
  {
    if(StoreOwnerList[ActorIDs[msg.sender]].so_balance >= _WithdrawAmount)
    {
        uint storeOwnerbalance = StoreOwnerList[ActorIDs[msg.sender]].so_balance;
        StoreOwnerList[ActorIDs[msg.sender]].so_balance = storeOwnerbalance.sub(_WithdrawAmount);
        msg.sender.transfer(_WithdrawAmount);
        emit TransactionRegistryUpdate(msg.sender, Actors[msg.sender], "Withdraw Balance","Successful!");
        return true;
    }
    else
    {
        emit TransactionRegistryUpdate(msg.sender, Actors[msg.sender], "Withdraw Balance","Failed!");
        return false;
    }
  }

    /*Shopper Functions*/
  function BuyProduct(string memory _ProductName, uint _OrderQty)
  public
  payable
  StopInEmergency isShopper
  returns(bool)
  {
    require(Objects[_ProductName] == ObjectType.Product);

    if(ProductList[ObjectIDs[_ProductName]].pdt_qty >= _OrderQty && msg.value >= ProductList[ObjectIDs[_ProductName]].pdt_price.mul(_OrderQty))
    {
        uint orderAmount = ProductList[ObjectIDs[_ProductName]].pdt_price.mul(_OrderQty);
        uint amountToRefund = msg.value.sub(orderAmount);
        uint storeOwnerbalance = StoreOwnerList[ObjectOwnerIDs[StoreFrontList[ObjectOwnerIDs[_ProductName]].sf_name]].so_balance;
        StoreOwnerList[ObjectOwnerIDs[StoreFrontList[ObjectOwnerIDs[_ProductName]].sf_name]].so_balance = storeOwnerbalance.add(orderAmount);
        uint productQty = ProductList[ObjectIDs[_ProductName]].pdt_qty;
        ProductList[ObjectIDs[_ProductName]].pdt_qty = productQty.sub(_OrderQty);
        msg.sender.transfer(amountToRefund);
        emit TransactionRegistryUpdate(msg.sender, Actors[msg.sender], "Buy Product", "Successful!");
        return true;
    }
    else
    {
        emit TransactionRegistryUpdate(msg.sender, Actors[msg.sender], "Buy Product", "Failed!");
        return false;
    }
  }

  function getAdministrators()
  public
  view
  returns (address[] memory)
  {
    return (AdministratorList);
  }

  function getStoreOwners()
  public
  view
  returns (StoreOwner[] memory)
  {
    return (StoreOwnerList);
  }

  function getStoreFronts()
  public
  view
  returns (StoreFront[] memory)
  {
    return (StoreFrontList);
  }

  function getProducts()
  public
  view
  returns (Product[] memory)
  {
    return (ProductList);
  }

  function getActorData(address _ActorAddress)
  public
  view
  returns (ActorType, uint)
  {
    return (Actors[_ActorAddress], ActorIDs[_ActorAddress]);
  }

  function getObjectData(string memory _ObjectName)
  public
  view
  returns (ObjectType, uint)
  {
    return (Objects[_ObjectName], ObjectIDs[_ObjectName]);
  }

  function getObjectOwnerData(string memory _ObjectOwnerName)
  public
  view
  returns (ObjectOwnerType, uint)
  {
    return (ObjectOwners[_ObjectOwnerName], ObjectOwnerIDs[_ObjectOwnerName]);
  }

}
