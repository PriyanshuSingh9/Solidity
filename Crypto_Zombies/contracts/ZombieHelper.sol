//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {ZombieFeeding} from "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{
    uint constant LEVEL_UP_FEE= 100 gwei;

    modifier checkLevel(uint256 _zombieId,uint _level){
        require(zombies[_zombieId].level>=_level,"Your zombie is not level enough to perform this action");
        _;
    }
    function giveName(uint256 _zombieId,string memory _name) external checkLevel(_zombieId,2) onlyOwnerOf(_zombieId){
            zombies[_zombieId].name=_name;
    }

    function newDna(uint256 _zombieId,uint256 _newDna) external checkLevel(_zombieId,20) onlyOwnerOf(_zombieId){
        if (_newDna < DNA_MODULUS / 10 || _newDna >= DNA_MODULUS) {
             revert("DNA must be a 16 digit number");
        }
        zombies[_zombieId].dna=_newDna;
    }


    function levelUp(uint _zombieId) external payable onlyOwnerOf(_zombieId){
        if (msg.value<LEVEL_UP_FEE){
            revert("You need to pay 100 gwei to level up your zombie");
        }
        Zombie storage myZombie= zombies[_zombieId];
        myZombie.level++;
        
    }
}