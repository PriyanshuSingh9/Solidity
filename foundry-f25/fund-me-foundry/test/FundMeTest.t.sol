// SPDX-License-Identifier : MIT

pragma solidity ^0.8.24;

// imprting the test and console module
// test module brings with itself a suite of testing methods and console brings the browser functionality
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

// adding this so that we don't have separate deploy scripts for testing and deploying
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // this function is always executed before any tests are performed
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // owner of fundMe is test and not us

        // using this script the contract deployer is us and not test thus we use msg.sender below
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Chainlink has updated the version of their pricefeed on mainnet.
    // Tests forking mainnet, as shown in the video, may fail.
    function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }
    // this test will always revert and produce an error if we use the anvil chain
    // to deploy it as there exists no such aggregator contract on it thus we have
    // to create a .env file and use our sepolia endpoint as fork url
}
