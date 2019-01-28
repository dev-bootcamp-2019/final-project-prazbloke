import React, { Component } from "react";
import MarketPlaceContract from "./contracts/MarketPlace.json";
import getWeb3 from "./utils/getWeb3";

import "./App.css";

class App extends Component {
  state = { superadmin: null, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = MarketPlaceContract.networks[networkId];
      const instance = new web3.eth.Contract(
        MarketPlaceContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.initUI);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  initUI = async () => {
    const { accounts, contract } = this.state;
    const response = accounts[0];
    // Update state with the SuperAdministrator account.
    this.setState({ superadmin: response });
    console.log(response);
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Online MarketPlace - Page under construction!</h1>
        <p>Apologies the UI couldnt be completed on time!</p>
        <h2>Instructions</h2>
        <p>
          Please refer to README.md and run the 'truffle migrate' in combination with Ganache (v2 recommended) and import the 12-word seed phrase into Metamask pointing to 127.0.0.1:8545 (localhost)
        </p>
        <div>The SuperAdministrator of this MarketPlace is: {this.state.superadmin}</div>
      </div>
    );
  }
}

export default App;
