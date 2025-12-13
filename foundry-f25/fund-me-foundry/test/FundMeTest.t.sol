// SPDX-License-Identifier : MIT

pragma solidity ^0.8.24;

// imprting the test and console module
// test module brings with itself a suite of testing methods and console brings the browser functionality
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // this function is always executed before any tests are performed
    function setUp() external {
        fundMe = new FundMe();
        // owner of fundMe is test and not us
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), address(this));
        // msg.sender does not work because here the msg sender will be us while the contract is deplyed
        // by the test contract thus we use address(this) to get the address sof our test contract
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
