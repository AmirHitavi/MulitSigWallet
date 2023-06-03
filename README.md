# Multisig Wallet

This project is an implementation of a multisignature wallet using Solidity and Hardhat. A multisignature wallet requires multiple parties to approve a transaction before it can be executed, providing additional security against unauthorized access.

## Features:
   Allows multiple users to create and interact with a shared wallet
   Each user has their own set of private keys, which are used to sign transactions
   Transactions require a minimum number of signatures to be approved before execution
   Supports adding and removing users from the wallet
   Provides functionality for viewing the balance of the wallet and approving or rejecting pending transactions

## Installation

To run this project, you will need to have Node.js and Hardhat installed. To get started, clone the repository and navigate to the root directory. Then, run the following commands:
```
npm install
npx hardhat compile
```

## Usage

To deploy the multisig wallet contract, run the following command:
```
npx hardhat run scripts/deploy.js --network <network-name>
```
Replace ```<network-name>``` with the name of the network you want to deploy to (e.g. sepolia, mainnet, etc.). You will also need to configure the network in the hardhat.config.js file.

You can then interact with the contract using the Hardhat console:

```npx hardhat console --network <network-name>```

From here, you can use ethers.js to interact with the deployed contract instance.

## Contributing

Contributions to this project are welcome! If you find a bug or have a feature request, please open an issue on GitHub. If you would like to contribute code, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.
