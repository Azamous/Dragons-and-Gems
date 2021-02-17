pragma solidity ^0.6.12;

import "./GemsERC20.sol";

contract DragonManager is GemsERC20 {
    function _createDragon(string memory _name, DragonType _type, defenceType _defence) internal {
        uint256 id;
        uint256 max = 200 + 100 * uint256(_type);
        dragons.push(Dragon(_name, _type, max, 1, 0, 0, now + 3 days, 0, _defence));
        id = dragons.length.sub(1);
        // Set owner for dragon and amount of dragons for owner
        ownerById[id] = msg.sender;
        ownerDragonsCount[msg.sender] = ownerDragonsCount[msg.sender].add(1);
        // Send starting amount of gems for dragon
        _mintGems(id, 100);
        _triggerCreationCooldown();
    }


    function _dragonPrice(DragonType _dragonType) internal view returns (uint256) {
            if (_dragonType == DragonType.Wyvern)
                return 200;
            if (_dragonType == DragonType.Feydragon)
                return 450;
            if (_dragonType == DragonType.Tarasque)
                return 600;
            if (_dragonType == DragonType.ChineseFireball)
                return 900;
            if (_dragonType == DragonType.NorwegianHornTail)
                return 1100;
            if (_dragonType == DragonType.UkrainianIronBelly)
                return 1500;

    }

    function CreateGreenWelschDragon(string memory _name, defenceType _defence) public _readyToCreate() {
        _createDragon(_name, DragonType.GreenWelch, _defence);
    }

    function CreatePaidDragon(string memory _name, uint256 _dragonToPay, DragonType _dragonType,
     defenceType _defence) public _readyToCreate() {
                  uint256 price = _dragonPrice(_dragonType);
                  _balances[_dragonToPay] = _balances[_dragonToPay].sub(price);
                  _createDragon(_name, _dragonType, _defence);
              }

    function GetNextStage(uint256 _id) public _ownerOfDragon(_id) _readyToGrow(_id) {
        Dragon storage dragon = dragons[_id];
        require(dragon.stage < 5);
        dragon.stage++;
        dragon.nextStageCooldown = now + 3 days;
    }

    function expandGemsMax(uint256 _id) public _ownerOfDragon(_id) {
        require(_balances[_id] >= 200);
         Dragon storage dragon = dragons[_id];
         _balances[_id] = _balances[_id].sub(200);
         dragon.gemsMax = dragon.gemsMax.add(100);
    }
}