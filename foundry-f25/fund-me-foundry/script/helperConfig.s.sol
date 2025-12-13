// SPDX-License-Identifier: MIT

// this contract is to :
// 1. Deploy mocks when we are on a local anvil chain(when we run contracts
// on our local chain we get on mock chain data to prevent crashing)

// 2. Keep track of contract addresses across different chains

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    // If we are on test anvil, we deploy mocks
    // else, grab the existing addresses from the livve network

    // this is written for the case that we want to get the same mulitple data fields from
    // different networks
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        // checking which chain we are on
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {}
}
