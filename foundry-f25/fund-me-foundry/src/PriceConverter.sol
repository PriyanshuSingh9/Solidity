//SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        /**
         * Network: Sepolia
         * Aggregator: ETH/USD
         * Address_eth: 0x694AA1769357215DE4FAC081bf1f309aDC325306
         * Address_zkSync: 0x694AA1769357215DE4FAC081bf1f309aDC325306
         */

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function convertionRate(
        uint256 _ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}
