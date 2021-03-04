pragma solidity ^0.6.12;

import "./GemsERC20.sol";

contract DragonManager is GemsERC20 {

        // Creates dragon and mint him 100 gems. Each type of dragons has different started gems maximum
    function _createDragon(string memory _name, DragonType _type, defenceType _defence) private {
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

    // Get price of a dragon in gems
    function _dragonPrice(DragonType _dragonType) private pure returns (uint256) {
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

    // Breed a free dragon
    function CreateGreenWelschDragon(string memory _name, defenceType _defence) external _readyToCreate() {
        _createDragon(_name, DragonType.GreenWelch, _defence);
    }

    function CreatePaidDragon(string memory _name, uint256 _dragonToPay, DragonType _dragonType,
     defenceType _defence) external _ownerOfDragon(_dragonToPay) _readyToCreate() {
                  uint256 price = _dragonPrice(_dragonType);
                  require(_balances[_dragonToPay] >= price, "Not enough gems");
                  _burnGems(_dragonToPay, price);
                  _createDragon(_name, _dragonType, _defence);
              }

    // Upgrade you dragon's stage once in three days
    // Each stage expands dragon's gem maximum for 200 gems
    function GetNextStage(uint256 _id) external _ownerOfDragon(_id) _readyToGrow(_id) {
        Dragon storage dragon = dragons[_id];
        require(dragon.stage < 5, "Dragon has reached the maximum stage");
        dragon.stage++;
        dragon.gemsMax = dragon.gemsMax.add(200);
        dragon.nextStageCooldown = now + 3 days;
    }

    // Spend gems to expand gems maximum
    function expandGemsMax(uint256 _id) external _ownerOfDragon(_id) {
        require(_balances[_id] >= 200, "Not enough gems");
         Dragon storage dragon = dragons[_id];
         _burnGems(_id, 200);
         dragon.gemsMax = dragon.gemsMax.add(100);
    }

    function renameDragon(uint256 _id, string memory _newName) external _ownerOfDragon(_id) {
        require(_balances[_id] >= 500, "Not enough gems");
        Dragon storage dragon = dragons[_id];
        dragon.name = _newName;
        _burnGems(_id, 500);
    }
}