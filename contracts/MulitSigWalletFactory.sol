// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MulitSigWallet.sol";

contract MultiSigWalletFactory {
    MultiSigWallet[] contracts;

    function create(address[] memory _owners, uint _required) public {
        MultiSigWallet wallet = new MultiSigWallet(_owners, _required);
        contracts.push(wallet);
    }

    function get(uint index) public view returns (address) {
        return address(contracts[index]);
    }
}
