The following Design Patterns were used in the Project:
1. Faily Early and Loud -> Extensive use of require() functions to enforce necessary conditions before function execution.
2. Restricted Access -> All key functions that can alter the state of the contract are restricted in access using relevant Modifiers such as isAdministrator, isStoreOwner, etc.
3. Pull instead of Push Payments -> Implemented in the WithdrawBalance function where StoreOwner is required to pull balance payment from the MarketPlace Smart Contract.
4. Circuit Breaker -> A Circuit Breaker variable Emergency is used to let SuperAdministrator pause the contract and lock down functionality during any emergency situation.
5. Library -> SafeMath library was imported and adapted for solidity 5.0.0 as the OpenZeppelin library is still for 4.0.x version.

Some of the Security Considerations:
1. Integer Over or Under Flow -> Prevented to a large extent through use of SafeMath library.
2. Force Sent Ether Balances -> Avoided referencing any critical logic to the balance of Ether held by the MarketPlace Smart Contract.
3. Avoid Tx.origin -> All checks and references are made with msg.sender instead
