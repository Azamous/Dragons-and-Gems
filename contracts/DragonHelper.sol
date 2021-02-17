pragma solidity ^0.6.12;

import "./SafeMath.sol";

contract DragonHelper {
    using SafeMath for uint256;

    enum DragonType {GreenWelch, Wyvern, Feydragon, Tarasque, ChineseFireball, NorwegianHornTail,
     UkrainianIronBelly}
    enum defenceType {defendHead, defendBelly, defendLegs} 
    // Fireball attacks head, ClawsAttack - belly, TailAttack - legs
    enum AttackType {FireBall, ClawsAttack, TailAttack}

    struct Dragon {
        string name;
        DragonType dragonType;
        uint256 gemsMax;
        uint256 stage;
        uint256 wins;
        uint256 losses;
        uint256 nextStageCooldown;
        uint256 attackCooldown;
        defenceType defence;
    }
    Dragon[] internal dragons;
    mapping (uint256 => address) internal ownerById;
    mapping (address => uint256) internal creationCooldown;
    mapping (address => uint256) internal ownerDragonsCount;

    modifier _readyToCreate() {
        require (creationCooldown[msg.sender] <= now);
        _;
    }

    modifier _readyToGrow(uint256 _id) {
        require(dragons[_id].nextStageCooldown <= now);
        _;
    }

    modifier _ownerOfDragon(uint256 _id) {
        require(ownerById[_id] == msg.sender);
        _;
    }


    // You can breed one dragon a day
    function _triggerCreationCooldown() internal {
        creationCooldown[msg.sender] = uint256(now + 1 days);
    }

    // Shows all owner's dragons' ids
    function ShowOwnerDragons(address _address) public view returns(uint256[] memory) {
        uint256[] memory ownedDragons = new uint256[](ownerDragonsCount[_address]);
        uint256 count = 0;
        for (uint i = 0; i < dragons.length; i++) {
            if (ownerById[i] == _address) {
                ownedDragons[count] = i;
                count++;
            }
        }
        return ownedDragons;
    }

    // Shows main info about dragon except defence type and gems amount
    function ShowDragon(uint256 _id) public view
             returns(string memory, DragonType, uint256, uint256, uint256, uint256){
        Dragon memory dragon = dragons[_id];
        return(dragon.name, dragon.dragonType, dragon.gemsMax, dragon.stage, dragon.wins, dragon.losses);
    }

    

    
}