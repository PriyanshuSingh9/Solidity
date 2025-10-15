//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SimpleStorage} from "./SimpleStorage.sol";
//useful if there are multiple contracts in a single file

contract StorageFactory{
    // first we declare an array of type SimpleStorage
    // to store all contracts we deploy 
    SimpleStorage[] public listOfSimpleStorageContracts;

    function createSimpleStorageContract() public {
        // creates variable of type SimpleStorage 
        // this stores our contract we just created
        SimpleStorage newSimpleStorageContract= new SimpleStorage();
        // adds the new contract to our list of contracts
        listOfSimpleStorageContracts.push(newSimpleStorageContract);
    }

    function sfstore(uint256 _index, uint256 _newNumber) public {
        //to call a contract from another contract you need:
        //contract address
        //contract ABI(Application Binary Interface)
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_index];
        mySimpleStorage.store(_newNumber);
    }

    function sfGet(uint _index) public view returns(uint256){
        SimpleStorage mySimpleStorage = listOfSimpleStorageContracts[_index];
        return mySimpleStorage.retrieve();
    }
}