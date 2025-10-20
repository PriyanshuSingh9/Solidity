//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ZombieHelper} from "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper{
    uint256 constant WIN_PROB=70;
    uint256 randNonce=0;

    event BattleResult(uint256 _zombieId, uint256 _enemyId, bool _win);

    function _chance() internal returns (uint256){
        randNonce+=1;
        return uint256(keccak256(abi.encodePacked(block.timestamp,randNonce,msg.sender)))%100;
    }
    function battle(uint256 _myZombieId, uint256 _enemyZombieId) public onlyOwnerOf(_myZombieId) ready(_myZombieId) {
        Zombie storage myZombie = zombies[_myZombieId];
        Zombie storage enemyZombie = zombies[_enemyZombieId];
        uint256 rand = _chance();
        
        if (rand < WIN_PROB) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            myZombie.readyTime=block.timestamp+1 days;
            feedAndMultiply(_myZombieId, enemyZombie.dna, "zombie");
        } else {
            enemyZombie.level++;
            myZombie.lossCount++;
            enemyZombie.winCount++;
            myZombie.readyTime = block.timestamp + 1 days;
        }
        emit BattleResult(_myZombieId, _enemyZombieId, rand < WIN_PROB);
    }
}