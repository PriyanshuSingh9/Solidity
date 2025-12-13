//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) fundsByUser;
    address public immutable i_owner;
    // price feed interface
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyi_Owner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function fund() public payable {
        require(
            msg.value.convertionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        funders.push(msg.sender);
        fundsByUser[msg.sender] += msg.value.convertionRate(s_priceFeed);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public onlyi_Owner {
        for (uint i = 0; i < funders.length; i++) {
            fundsByUser[funders[i]] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
