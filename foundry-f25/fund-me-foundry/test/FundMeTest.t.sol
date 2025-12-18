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
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        // helps in setting up tests by giving some value to fundMe contract
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

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
        assertEq(fundMe.getOwner(), msg.sender);
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
        // testing function fund() in FundMe.sol--> funds are mapped to user or not
        vm.prank(USER);
        // prank is also a cheatcode in foundry which means that the next tx will be sent from the
        // address USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArray() public funded {
        // testing function fund() in FundMe.sol--> funders are saved or not

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // testing function withdraw() in FundMe.sol--> onlyb owner of contract should be able to withdraw

        vm.expectRevert();
        vm.prank(USER);
        // works for only this : vvvvvvvvvvv
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // using this methodology we structure our tests i.e. initialise test conditions perform
        // a function and then check for the required result.

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();

        // Act
        // gasleft is a built-in fxn in solidity tells us how much gas is left in a tx.
        uint256 gasStart = gasleft();

        // setting a gas price for all subsequent transactions after this fxn call.
        vm.txGasPrice(GAS_PRICE);
        // in an anvil cahin the default gas price is taken as zero this is why
        // withdrawing all the funds would give exact amount of funds that were sent
        // even though gas would have been used in both depositing and withdrawing.
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used :", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // we use uint160 to generate addresses bcs address also consist of 160 bits
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // using 1 as starting index as sometimes address(0) reverts.

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax is another std library cheat that combines deal and prank
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();

        // this block behaves the same as startBroadcast() and stopBroadcast()
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
}
