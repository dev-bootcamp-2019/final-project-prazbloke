const path = require("path");

const HDWallet = require('truffle-hdwallet-provider');
const infuraKey = "a3c2a085c6344540b4127be7d81f7316";

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

var HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  compilers: {
    solc: {
      version: "0.5.0"
    }
  },
 networks: {
   development: {
     host: "localhost",
     port: 8545,
     network_id: "*" // Match any network id
   },
   rinkeby: {
     provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/${infuraKey}`),
     network_id: 4,   // This network is yours, in the cloud.
     gas: 5500000    // Treats this network as if it was a public net. (default: false)
   }
 }
};
