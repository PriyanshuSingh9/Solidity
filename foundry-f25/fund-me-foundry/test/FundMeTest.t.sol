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

    address USER = makeAddr("user");
    // it is a forge std cheat returns an address to use
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // this function is always executed before any tests are performed
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // owner of fundMe is test and not us

        // using this script the contract deployer is us and not test thus we use msg.sender below
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        // cheatcode to send some funds to an address to make tx in the future
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

    function testEnoughEthNotSent() public {
        // testing function fund() in FundMe.sol

        // this cheatcode means that we expect the following section to revert
        // if it doesn't the test will fail i.e. assert(this tx will fail/revert)
        vm.expectRevert();
        fundMe.fund(); // sending no value to fxn fund
    }

    function testFundUpdatesDone() public {
        // testing function fund() in FundMe.sol
        vm.prank(USER);
        // prank is also a cheatcode in foundry which means that the next tx will be sent from the
        // address USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}
