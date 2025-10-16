//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {ZombieFactory} from "./ZombieFactory.sol"; 

interface KittyInterface{
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory{
    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external{
        kittyContract = KittyInterface(_address);
    }

    modifier onlyOwner(uint _zombieId){
        if (msg.sender!=zombieToOwner[_zombieId]){
            revert("Thats not your Zombie");
        }
        _;
    }

    function feedAndMultiply(uint _zombieId,uint _target,string memory _species)internal{
        Zombie storage myZombie=zombies[_zombieId];
        _target%=DNA_MODULUS;
        uint256 newDna=(myZombie.dna+_target/2);
        if(keccak256(abi.encodePacked(_species))==keccak256(abi.encodePacked("kitty"))){
            newDna-=newDna%100+99;
        }
        _createZombie("no name", newDna);
        
    }
    function feedOnKitty(uint _zombieId,uint _kittyId)public onlyOwner(_zombieId){
        (,,,,,,,,,uint256 kittyDna)=kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId,kittyDna,"kitty");
    }

}