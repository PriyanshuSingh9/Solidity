//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5e18;
    address[] public s_funders;
    mapping(address funder => uint256 amountFunded) private s_fundsByUser;
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
        s_funders.push(msg.sender);
        s_fundsByUser[msg.sender] += msg.value.convertionRate(s_priceFeed);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public onlyi_Owner {
        for (uint i = 0; i < s_funders.length; i++) {
            s_fundsByUser[s_funders[i]] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // view/pure functions i.e. getters
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_fundsByUser[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
