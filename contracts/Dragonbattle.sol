pragma solidity ^0.6.12;

import "./DragonManager.sol";

// A fight between two dragons is represented in style of "Камень ножницы бумага" game
// Defence and attack types can be seen in DragonHelper
contract DragonBattle is DragonManager {
    // Required to generate random numbers
    uint256 private randNonce = 0;

    event Victory(string _ownerDragon, string _another, uint256 _value);
    event Loss(string _ownerDragon, string _another);

    /// @dev Dragon can attack once a day
    modifier _readyToAttack(uint256 _id) {
        require(dragons[_id].attackCooldown <= now, "Dragon is not ready to attack");
        _;
    }

    /// @dev Dragon can attack others that 2 stages lower
    modifier _CantAttackSmallerDragons(uint256 _attackerId, uint256 _anotherId) {
        require(dragons[_attackerId].stage <= dragons[_anotherId].stage ||
                 dragons[_attackerId].stage - dragons[_anotherId].stage <= 2, "Can't attack smaller dragons");
        _;
    }
    /// @dev Returns precent of gems to steal, each type of dragon has its own precent
    /// @param _type Type of dragon
    function _getPercentage(DragonType _type) public pure returns(uint256) {
        if (_type == DragonType.GreenWelch) 
            return 15;
        if (_type == DragonType.Wyvern) 
            return 20;
        if (_type == DragonType.Feydragon) 
            return 25;
        if (_type == DragonType.Tarasque) 
            return 25;
        if (_type == DragonType.ChineseFireball) 
            return 30;
        if (_type == DragonType.NorwegianHornTail) 
            return 30;
        if (_type == DragonType.UkrainianIronBelly) 
            return 35;
        return 1;
    }

    /// @dev This function is called after an attack in order to trigger cooldown
    /// @param _dragon Dragon who attacked
    function _triggerAttackCooldown(Dragon storage _dragon) private {
        _dragon.attackCooldown =  uint256(now + 1 days);
    }

    /// @dev Returns true if you successeded with guessing the attack type
    /// @param _attack Attack type of attacking dragon
    /// @param _defence Defence type of defending dragon
    function _isAttackSuccessfull(AttackType _attack, defenceType _defence) private pure 
        returns (bool) {
            return uint256(_attack) == uint256(_defence);
        }

    /// @dev Returns a random number, required to add some randomness in battles
    function _getRandom() private returns(uint256) {
        return uint256(keccak256(abi.encodePacked(now, msg.sender, randNonce++)));
    }

    /// @dev If attack is successfull, an attacking dragon gets gems from other dragon 
    /// @param _attackerId ID of an attacking dragon
    /// @param _anotherId ID of an defending dragon
    /// @param _attacker Dragon struct of an attacking dragon
    /// @param _another Dragon struct of an defending dragon
    function _DragonVictory(uint256 _attackerId, uint256 _anotherId,
                Dragon storage _attacker, Dragon storage _another) private  {
        // Collect Gems
        uint256 precent;
        precent = _getPercentage(_attacker.dragonType);
        uint256 value = _balances[_anotherId].mul(precent).div(100);
        _balances[_anotherId] = _balances[_anotherId].sub(value);
        if (_balances[_attackerId].add(value) > _attacker.gemsMax) { // Check if new value of gems bigger than Gem Cap
            _balances[_attackerId] = _attacker.gemsMax;
        }
         else {
            _balances[_attackerId] = _balances[_attackerId].add(value);
         }
        // Change win/loss counters
        _attacker.wins = _attacker.wins.add(1);
        _another.losses = _another.losses.add(1);
        // Emit events
        emit Victory(_attacker.name, _another.name, value);
        emit Loss (_another.name, _attacker.name);
    }

    /// @dev This function is called in case of attacking dragon loss
    /// @dev Increment wins count for defending dragon and losses count for attacker
     /// @param _attacker Dragon struct of an attacking dragon
    /// @param _another Dragon struct of an defending dragon
    function _DragonLoss(Dragon storage _attacker, Dragon storage _another) private {
        // Change win/loss counters
        _attacker.losses = _attacker.losses.add(1);
        _another.wins = _another.wins.add(1);
        // Emit Events
        emit Victory(_another.name, _attacker.name, 0);
        emit Loss(_attacker.name, _another.name);
    }

    /// @dev Sets a type of defence for your dragon(default - defendHead)
    /// @param _id ID of dragon
    /// @param _defence Defence type(see DragonHepler for list of defence types)
    function SetDefence(uint256 _id, defenceType _defence) external _ownerOfDragon(_id) {
        Dragon storage dragon = dragons[_id];
        dragon.defence = _defence;
    }

    /// @dev Shows defence of your dragon
    /// @param _id ID of dragon
    function GetDefence(uint256 _id) external view _ownerOfDragon(_id) returns(defenceType) {
        Dragon storage dragon = dragons[_id];
        return dragon.defence;
    }

    /// @dev Attack other dragon once a day
    /// @dev Calls DragonVictory function in case of attacker victory 
    /// @dev Calls DragonLoss function in case of attacker loss
    function AttackDragon(uint256 _attackerId, uint256 _anotherId, AttackType _attack) external 
        _ownerOfDragon(_attackerId) _readyToAttack(_attackerId)
        _CantAttackSmallerDragons(_attackerId, _anotherId) {
            Dragon storage attacker = dragons[_attackerId];
            Dragon storage another = dragons[_anotherId];
            if (_isAttackSuccessfull(_attack, another.defence)) { // Attack is correct
                if (attacker.stage >= another.stage) { // Victory if your dragon is same stage or higher
                    _DragonVictory(_attackerId, _anotherId, attacker, another);
                } 
                else if (_getRandom() % 100 < 70) { // Victory if your dragon stage is lower but you get 70% chance
                    _DragonVictory(_attackerId, _anotherId, attacker, another);
                }
                else { // Loss
                    _DragonLoss(attacker, another);
                }
            }
            else { // Attack is incorrect but still have chance to win
                if (attacker.stage > another.stage && _getRandom() % 100 < 50) { // Victory if stage is higher and get 50% chance
                    _DragonVictory(_attackerId, _anotherId, attacker, another);
                }
                else if (attacker.stage == another.stage && _getRandom() % 100 < 30){ // Victory if stage is the same and get 30% chance
                    _DragonVictory(_attackerId, _anotherId, attacker, another);
                } 
                else if (_getRandom() % 100 < 10) { // Victory if stage is lower but got 10% chence
                    _DragonVictory(_attackerId, _anotherId, attacker, another);
                }
                else { // Loss
                    _DragonLoss(attacker, another);
                }
            }
            _triggerAttackCooldown(attacker);
        }
}