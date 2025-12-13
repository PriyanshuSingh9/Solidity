// SPDX-License-Identifier : MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        // adding return so that we can use the same script in tests as well
        return fundMe;
    }
}
