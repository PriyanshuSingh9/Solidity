// SPDX-License-Identifier: MIT

// this contract is to :
// 1. Deploy mocks when we are on a local anvil chain(when we run contracts
// on our local chain we get on mock chain data to prevent crashing)

// 2. Keep track of contract addresses across different chains

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on test anvil, we deploy mocks
    // else, grab the existing addresses from the livve network

    // this is written for the case that we want to get the same mulitple data fields from
    // different networks
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    // magic numbers
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

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

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // check if we have already setup a mock price feed and use it
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. deploy the mocks
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        // 8 bcs we know that our price feeed uses 8 decimals and a starting price of 2000
        vm.stopBroadcast();

        // 2. return the mock addresses
        NetworkConfig memory anvilconfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilconfig;
    }
}
