//SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function getPrice() internal view returns(uint256){
        /**
        * Network: Sepolia
        * Aggregator: ETH/USD
        * Address_eth: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        * Address_zkSync: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        AggregatorV3Interface priceFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);        
        (,int256 price,,,)=priceFeed.latestRoundData();
        //price has 8 decimal points 
        //thus we remove (18-8)=10 decimal places from price to match with msg.value
        return uint256(price*1e10);
    }
    function convertionRate(uint256 _ethAmount) internal view  returns(uint256){
        uint256 ethPrice=getPrice();
        //in solidity we always multiply first before divding
        //as we can only work with whole numbers in solidity
        uint256 ethAmountInUsd=(ethPrice*_ethAmount)/1e18;
        //we divide by 18 decimal places as both ethPrice ethAmount
        //have 18 decimals thus, ethAmountInUsd would have 36 decimals
        return ethAmountInUsd;
    }
}