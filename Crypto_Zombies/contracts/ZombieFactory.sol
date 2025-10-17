//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract ZombieFactory{

    uint256 constant DNA_MODULUS=10**16;
    address immutable i_owner;

    struct Zombie{
        string name;
        uint256 dna;
        uint16 level;
    }
    Zombie[] public zombies;

    mapping(uint256 id => address owner) public  zombieToOwner; 
    mapping(address => uint256) public ownerZombieCount; 
    mapping(address owner=>uint256[] ids) public allZombies;

    modifier firstZombie(){
        if (ownerZombieCount[msg.sender]!=0){
            revert("You already have a zombie");
        }
        _;
    }

    constructor(){
        i_owner=msg.sender;
    }

    function _randDna(string memory _str)internal pure returns(uint256){
        uint256 dna= (uint256(keccak256(abi.encodePacked(_str))))%DNA_MODULUS;
        return dna-dna%100;
    }

    function _createZombie(string memory _name,uint256 _dna)internal{
        zombies.push(Zombie(_name,_dna,1));
        uint256 newZombieId=zombies.length-1;
        allZombies[msg.sender].push(newZombieId);
        ownerZombieCount[msg.sender]++;
        zombieToOwner[newZombieId]=msg.sender;
    }

    function createFirstZombie(string memory _name)public firstZombie{
        uint256 dna= _randDna(_name);
        _createZombie(_name,dna);
    }
}