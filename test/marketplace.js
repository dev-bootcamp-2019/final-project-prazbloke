/*

This test file has been updated for Truffle version 5.0. If your tests are failing, make sure that you are
using Truffle version 5.0. You can check this by running "trufffle version"  in the terminal. If version 5 is not
installed, you can uninstall the existing version with `npm uninstall -g truffle` and install the latest version (5.0)
with `npm install -g truffle`.

*/

var MarketPlace = artifacts.require('MarketPlace')

contract('MarketPlace', function(accounts) {

    const superadmin = accounts[0]
    const admin1 = accounts[1]
    const storeowner1 = accounts[2]
    const shopper1 = accounts[3]
    //const emptyAddress = '0x0000000000000000000000000000000000000000'

    var status

    it("SuperAdministrator should be able to add another Administrator", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false

      	const tx = await marketPlace.AddAdministrator(admin1, {from: superadmin})
      	if (tx.logs[0].event === "ActorRegistryUpdate") {
      		status = tx.logs[0].args._status.toString(75)
      		eventEmitted = true
      	}

        const result = await marketPlace.getAdministrators.call()

        assert.equal(result[0], superadmin, 'the first admin should match SuperAdministrator')
        assert.equal(result[result.length-1], admin1, 'the latest Administrator should match the added Administrator')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed addition of Administrator')
        assert.equal(status, "Newly Added as Administrator!", 'the event should reflect Successful addition of Administrator')
    })

    it("Administrator should be able to add a StoreOwner", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false

        const tx = await marketPlace.AddStoreOwner(storeowner1, "SO1", {from: admin1})
        if (tx.logs[0].event === "ActorRegistryUpdate") {
          status = tx.logs[0].args._status.toString(75)
          eventEmitted = true
        }

        const result = await marketPlace.getStoreOwners.call()

        assert.equal(result[result.length-1].so_address, storeowner1, 'the latest StoreOwner should match the added StoreOwner')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed addition of StoreOwner')
        assert.equal(status, "Newly Added as StoreOwner!", 'the event should reflect Successful addition of StoreOwner')
    })

    it("StoreOwner should be able to add a StoreFront", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false

        const tx = await marketPlace.AddStoreFront("SF1", {from: storeowner1})
        if (tx.logs[0].event === "ObjectRegistryUpdate") {
          status = tx.logs[0].args._status.toString(75)
          eventEmitted = true
        }

        const result = await marketPlace.getStoreFronts.call()

        assert.equal(result[result.length-1].sf_name, "SF1", 'the latest StoreFront should match the added StoreFront')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed addition of StoreFront')
        assert.equal(status, "Newly Added as StoreFront!", 'the event should reflect Successful addition of StoreFront')
    })

    it("StoreOwner should be able to add a Product to a StoreFront", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false

        const tx = await marketPlace.AddProduct("SF1","PDT1", 1, 100, {from: storeowner1})
        if (tx.logs[0].event === "ObjectRegistryUpdate") {
          status = tx.logs[0].args._status.toString(75)
          eventEmitted = true
        }

        const result = await marketPlace.getProducts.call()
        const result2 = await marketPlace.getStoreFronts.call()

        assert.equal(result[result.length-1].pdt_name, "PDT1", 'the latest Product should match the added Product')
        assert.equal(result2[result2.length-1].sf_pdt_ids[0], result[result.length-1].pdt_id, 'the Product ID should match in StoreFront and Product records')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed addition of Product')
        assert.equal(status, "Newly Added as Product!", 'the event should reflect Successful addition of Product')
    })

    it("Shopper should be able to buy a Product from a StoreFront", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false
        const amount = 20
        const orderQty = 10
        var shopperBalanceBefore = await web3.eth.getBalance(shopper1)

        const resultBefore = await marketPlace.getProducts.call()
        const resultBefore2 = await marketPlace.getStoreOwners.call()

        const tx = await marketPlace.BuyProduct("PDT1", orderQty, {from: shopper1, value: amount})
        if (tx.logs[0].event === "TransactionRegistryUpdate") {
          status = tx.logs[0].args._status.toString(75)
          eventEmitted = true
        }

        var shopperBalanceAfter = await web3.eth.getBalance(shopper1)

        const resultAfter = await marketPlace.getProducts.call()
        const resultAfter2 = await marketPlace.getStoreOwners.call()

        assert.equal(parseInt(resultAfter[resultAfter.length-1].pdt_qty,10), parseInt(resultBefore[resultBefore.length-1].pdt_qty,10) - parseInt(orderQty,10), 'the Product qty should change by Order qty')
        assert.isAbove(parseInt(resultAfter2[resultAfter2.length-1].so_balance,10), parseInt(resultBefore2[resultBefore2.length-1].so_balance,10), 'the StoreOwner Balance should be higher after Successful purchase')
        assert.isBelow(parseInt(shopperBalanceAfter,10), parseInt(shopperBalanceBefore,10), 'the Shopper Balance should be lower after Successful purchase')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed purchase of Product')
        assert.equal(status, "Successful!", 'the event should reflect Successful purchase of Product')
    })

    it("StoreOwner should be able to withdraw Balance from MarketPlace", async() => {
        const marketPlace = await MarketPlace.deployed()

        var eventEmitted = false
        const amount = 10

        var storeOwnerBalanceBefore = await web3.eth.getBalance(storeowner1)
        const resultBefore = await marketPlace.getStoreOwners.call()

        const tx = await marketPlace.WithdrawBalance(amount, {from: storeowner1})
        if (tx.logs[0].event === "TransactionRegistryUpdate") {
          status = tx.logs[0].args._status.toString(75)
          eventEmitted = true
        }

        var storeOwnerBalanceAfter = await web3.eth.getBalance(storeowner1)
        const resultAfter = await marketPlace.getStoreOwners.call()

        assert.equal(parseInt(resultAfter[resultAfter.length-1].so_balance,10), parseInt(resultBefore[resultBefore.length-1].so_balance,10) - parseInt(amount,10), 'the StoreOwner Balance should be lower after Successful withdrawal')
        //Cant assert the below condition as withdrawal amount received is too low compared to gas cost incurred by StoreOwner
        //assert.isAbove(parseInt(storeOwnerBalanceAfter,10), parseInt(storeOwnerBalanceBefore,10), 'the StoreOwner Address Balance should be higher after Successful withdrawal')
        assert.equal(eventEmitted, true, 'an Event should get emitted regardless of Successful or Failed withdrawal of Balance')
        assert.equal(status, "Successful!", 'the event should reflect Successful withdrawal of Balance')
    })

});
