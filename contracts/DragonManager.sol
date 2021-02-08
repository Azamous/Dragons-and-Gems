pragma solidity ^0.6.12;

contract DragonManager {
    struct Dragon {
        string name;
        uint256 dragonType;
        uint256 gemsAmount;
        uint256 gemsCap;
        uint256 stage;
        uint256 wins;
        uint256 losses;
        uint256 nextStageCooldown;
    }
    Dragon[] private dragons;
    mapping (uint256 => address) private ownerById;
    mapping (address => uint256) private creationCooldown;
    mapping (address => uint256) private ownerDragonsCount;

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

    function _triggerCooldown() private {
        creationCooldown[msg.sender] = uint256(now + 1 days);
    }

    function _createDragon(string memory _name, uint256 _type) private {
        uint256 id;
        if (_type == 0) {
           dragons.push(Dragon(_name, _type, 0, 1000, 1, 0, 0, now + 3 days));
        }
        id = dragons.length - 1;
        ownerById[id] = msg.sender;
        ownerDragonsCount[msg.sender]++;
    }

    function ShowOwnerDragons(address _address) public view returns(uint256[] memory) {
        uint256[] memory ownedDragons;
        uint256 count = 0;
        for (uint i = 0; i < dragons.length; i++) {
            if (ownerById[i] == _address) {
                ownedDragons[count] = i;
                count++;
            }
        }
        return ownedDragons;
    }

    function ShowDragon(uint256 _id) public view
             returns(string memory, uint256, uint256, uint256, uint256, uint256){
        Dragon memory dragon = dragons[_id];
        return(dragon.name, dragon.dragonType, dragon.gemsAmount, dragon.stage, dragon.wins, dragon.losses);
    }

    function GetNextStage(uint256 _id) public _ownerOfDragon(_id) _readyToGrow(_id) {
        Dragon storage dragon = dragons[_id];
        require(dragon.stage < 5);
        dragon.stage++;
        dragon.nextStageCooldown = now + 3 days;
    }

    function CreateGreenWelschDragon(string memory _name) public _readyToCreate() {
        _createDragon(_name, 0);
        _triggerCooldown();
    }
}