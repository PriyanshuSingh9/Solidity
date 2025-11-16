// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        // this keyworfvm is a cheatcode that can be used only in foundry.
        // it is not valid in normal solidity files.
        // only valid when you import Script from "forge-std/Script.sol"
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        // everything between startBroadcast() and stopBroadcast() will be
        // sent as a transaction to the blockchain
        // this is done so as to avoid spending gas on intiailization code

        return simpleStorage;
    }
}
