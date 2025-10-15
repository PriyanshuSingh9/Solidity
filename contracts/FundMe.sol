//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

//get funds from users
//witdraw funds
//set a minimum value in usd
error NotOwner();
contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) fundsByUser;
    address public immutable i_owner;
    //we use constant and immutable for gas optimisation as they don't store data on storage
    //rather they store it in the bytecode of the contract directly
    //constant fro variables declared in the same line
    //immutable for variables declared later

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyi_Owner() {
        // require(msg.sender == i_owner, "must be i_owner");
        if (msg.sender != i_owner) {revert NotOwner();}
        //we can use this revert method instead of require as it is gas efficient
        //as we don't have to store the transcation failed message

        _;
        //underscore below the code means that first our modifier will be run inside
        //the function then the function contents are run
        //we can but underscore above our code to do the opposite
    }

    function fund() public payable {
        require(
            msg.value.convertionRate() >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        funders.push(msg.sender);
        fundsByUser[msg.sender] += msg.value.convertionRate();
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function withdraw() public onlyi_Owner {
        for (uint i = 0; i < funders.length; i++) {
            fundsByUser[funders[i]] = 0;
        }
        // resets the funders array
        funders = new address[](0);
        //msg.sender is of type "address"
        //we cast it as a "payable address" to transfer eth from it

        //transfer has a capped gas of 2300 and if amount sent along the transaction is not
        //enough transaction fails. transfer automatically reverts the transaction
        // payable(msg.sender).transfer(address(this).balance);

        //send also has a capped gas of 2300 but returns true or false to tell if transaction
        //was successful or not. We need to add require statement to revert transaction
        // bool sendSuccess=payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send failed");

        //call is a low level command and can be used to call virtually any function
        //in ethereum without even having the ABI
        //call returns two varaibles bool callSuccess and bytes memory dataReturned
        //at the end of call statement we use ("") to signify that we are not calling
        // any function
        //dataReturned will be the values call recieves if a function is called through it
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    // What happens when someone calls the wrong contract and sends their either
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()
    receive() external payable {fund(); }
    fallback() external payable {fund(); }
}
