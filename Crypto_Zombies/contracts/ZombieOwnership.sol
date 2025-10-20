//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {ZombieAttack} from "./ZombieAttack.sol";

contract ZombieOwnership is ZombieAttack{

    event Transfer(address from, address to , uint256 tokenId);

    modifier upForSale(uint256 tokenId){
        if ( zombies[tokenId].auctionPrice == 0 ) {
            revert("Zombie is not up for sale");
        }
        if(tokenId >= zombies.length){
            revert("Zombie does not exist");
        }
        _;
    }

    modifier amountCheck(uint256 _tokenId, uint256 _value) {
        if (zombies[_tokenId].auctionPrice > _value) {
            revert("Insufficient amount");
        }
        _;
    }

// balanceOf(address owner) → Number of NFTs an address owns
    function balanceOf(address _owner) public view returns (uint256) {
        return ownerZombieCount[_owner];
    }
// ownerOf(uint256 tokenId) → Who owns a specific NFT
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return zombieToOwner[_tokenId];
    }

    function removeZombie(address _owner, uint256 _tokenId) internal {
        uint256[] storage zombiesOwned = allZombies[_owner];
        for (uint256 i = 0; i < zombiesOwned.length; i++) {
            if (zombiesOwned[i] == _tokenId) {
                zombiesOwned[i] = zombiesOwned[zombiesOwned.length - 1];
                zombiesOwned.pop();
                break;
            }
        }
    }

    function buyZombie(uint256 _tokenId) external payable upForSale(_tokenId) amountCheck(_tokenId, msg.value) {

        uint256 price = zombies[_tokenId].auctionPrice;
        address seller = zombieToOwner[_tokenId];
        require(msg.sender != seller, "Cannot buy your own zombie");

        // 1) checks already done by modifiers

        // 2) effects - update state first
        ownerZombieCount[seller]--;
        ownerZombieCount[msg.sender]++;
        zombieToOwner[_tokenId] = msg.sender;
        zombies[_tokenId].auctionPrice = 0;

        // update allZombies (remove from seller's list, add to buyer's)
        removeZombie(seller,_tokenId);
        allZombies[msg.sender].push(_tokenId);
        
        // 3) interactions - pay seller
        (bool successSeller, ) = payable(seller).call{ value: price }("");
        require(successSeller, "Payment to seller failed");

        // refund overpayment to buyer
        if (msg.value > price) {
            (bool successRefund, ) = payable(msg.sender).call{ value: msg.value - price }("");
            require(successRefund, "Refund failed");
        }

        emit Transfer(seller, msg.sender, _tokenId); // see event naming below
    }


    function setAuctionPrice(uint256 _auctionPrice, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombies[_tokenId].auctionPrice = _auctionPrice;
    }

    function getZombiesByOwner(address _owner) external view returns (uint256[] memory) {
        return allZombies[_owner];
    }


}