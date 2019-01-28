# MarketPlace

The Market Place directory is a truffle project that contains the required contract, migration and test files.

The Project Design can be explained as below:
1. There are 3 Types of Actors who can interact in a Market Place:
  a. A SuperAdministrator who owns the Marketplace and decides the rules of the Market Place. He or she can add other Administrators.
  b. Administrator who can add StoreOwners to the MarketPlace.
  c. StoreOwners who can add StoreFronts within the MarketPlace and add specific Products within specific StoreFronts.
2. There are 2 main Types of Objects that are crucial to maintaining the MarketPlace infrastructure:
  a. A StoreFront which represents an organized shop window offering specific products.
  b. A Product which represents the amount of inventory and price at which it is offered.
3. There is a concept of Ownership or parental relationship where a StoreOwner owns certain StoreFronts and each StoreFront contains certain Products.
4. Shoppers are external entities who arent registered Actors in the MarketPlace and can purchase items from the MarketPlace. The purchase considerations will be paid by the Shopper to the StoreOwner upon Successful purchase.
5. All Actors are Mutually Exclusive, i.e., they can take on only one Actor Type role.

Project Launch instructions:
`$ truffle compile`
`$ truffle migrate --reset`
`$ npm run start`
`$ truffle test`

Given the lack of prior UI development experience and loss of critical time due to unavoidable health circumstances, the UI could not completed by the developer and only a skeletal UI (using `$ truffle unbox react`) that marginally runs a server and displays the address of owner deploying the MarketPlace contract is displayed.

The Project requires a Ganache client (ideally V2 GUI is well suited for this exercise) running a private network on '127.0.0.1:8545' and also requires an import of the 12 phrase seed into Metamask. The DApp UI (though not functional) will still likely trigger the browser to seek permission from Metamask to access accounts for the very first time.

However, the project could be extensively tested using the Remix browser (any version above 5.0.0 works) with a lot of getter functions. Also, the developer has employed the "pragma experimental" directive that allows structs to be retrieved via get functions and displayed as tuples.
1. getAdministrators -> Gets an array of Addresses of all the Administrators of the MarketPlace
2. getStoreOwners -> Gets an array of StoreOwner objects that contain attributes that uniquely describe the Store Owner and the Store Fronts owned
3. getStoreFronts -> Gets an array of StoreFront objects that contain attributes that uniquely describe the Store Front and the Products contained in it
4. getActorData -> Gives a quick tuple that explains the Type of Actor and the Array Index of the specific Actor in the specific ActorTypeList (e.g. AdministratorList, StoreOwnerList)
5. getObjectData -> Gives a quick tuple that explains the Type of Object and the Array Index of the specific Object in the specific ObjectTypeList (e.g. StoreFrontList, ProductList)
6. getObjectOwnerData -> Gives a quick tuple that explains the Type of ObjectOwner and the Array Index of the specific ObjectOwner in the specific ActorTypeList or ObjectTypeList.
