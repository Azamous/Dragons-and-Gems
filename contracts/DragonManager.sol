pragma solidity ^0.6.12;

import "./GemsERC20.sol";

contract DragonManager is GemsERC20 {
    function _createDragon(string memory _name, DragonType _type, defenceType _defence) internal {
        uint256 id;
        if (_type == DragonType.GreenWelch) {
           dragons.push(Dragon(_name, _type, 1000, 1, 0, 0, now + 3 days, 0, _defence));
        }
        id = dragons.length.sub(1);
        // Set owner for dragon and amount of dragons for owner
        ownerById[id] = msg.sender;
        ownerDragonsCount[msg.sender] = ownerDragonsCount[msg.sender].add(1);
        // Send starting amount of gems for dragon
        _mintGems(id, 100);
        _triggerCreationCooldown();
    }

    function CreateGreenWelschDragon(string memory _name, defenceType _defence) public _readyToCreate() {
        _createDragon(_name, DragonType.GreenWelch, _defence);
    }
}