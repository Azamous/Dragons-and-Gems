pragma solidity ^0.6.12;

import "./DragonManager.sol";

contract DragonBattle is DragonManager {
    // Fireball attacks head, ClawsAttack - belly, TailAttack - legs
    enum AttackType {FireBall, ClawsAttack, TailAttack}
    // Required to generate random numbers
    uint256 randNonce = 0;

    event Victory(string _ownerDragon, string _another, uint256 _value);
    event Loss(string _ownerDragon, string _another);

    modifier _readyToAttack(uint256 _id) {
        require(dragons[_id].attackCooldown <= now);
        _;
    }

    modifier _CantAttackSmallerDragons(uint256 _attackerId, uint256 _anotherId) {
        require(dragons[_attackerId].stage <= dragons[_anotherId].stage ||
                 dragons[_attackerId].stage - dragons[_anotherId].stage <= 2);
        _;
    }
    // Returns precent of gems to steal
    function _getPercentage(DragonType _type) internal pure returns(uint256) {
        if (_type == DragonType.GreenWelch) {
            return 20;
        }
        return 1;
    }

    function _triggerAttackCooldown(Dragon storage _dragon) internal {
        _dragon.attackCooldown =  uint256(now + 1 days);
    }

    function _isAttackSuccessfull(AttackType _attack, defenceType _defence) internal pure 
        returns (bool) {
            return uint256(_attack) == uint256(_defence);
        }

    function _getRandom() internal returns(uint256) {
        return uint256(keccak256(abi.encodePacked(now, msg.sender, randNonce++)));
    }

    function _DragonVictory(Dragon storage _attacker, Dragon storage _another) internal  {
        // Collect Gems
        uint256 precent;
        if (_attacker.dragonType == DragonType.GreenWelch) {
            precent = _getPercentage(_attacker.dragonType);
        }
        uint256 value = _another.gemsAmount * precent / 100;
        _another.gemsAmount -= value;
        _attacker.gemsAmount += value;
        // Change win/loss counters
        _attacker.wins++;
        _another.losses++;
        // Emit events
        emit Victory(_attacker.name, _another.name, value);
        emit Loss (_another.name, _attacker.name);
    }

    function _DragonLoss(Dragon storage _attacker, Dragon storage _another) internal {
        // Change win/loss counters
        _attacker.losses++;
        _another.wins++;
        // Emit Events
        emit Victory(_another.name, _attacker.name, 0);
        emit Loss(_attacker.name, _another.name);
    }

    function SetDefence(uint256 _id, defenceType _defence) public _ownerOfDragon(_id) {
        Dragon storage dragon = dragons[_id];
        dragon.defence = _defence;
    }

    function GetDefence(uint256 _id) public _ownerOfDragon(_id) returns(defenceType) {
        Dragon storage dragon = dragons[_id];
        return dragon.defence;
    }

    function AttackDragon(uint256 _attackerId, uint256 _anotherId, AttackType _attack) public 
        _ownerOfDragon(_attackerId) _readyToAttack(_attackerId)
        _CantAttackSmallerDragons(_attackerId, _anotherId) {
            Dragon storage attacker = dragons[_attackerId];
            Dragon storage another = dragons[_anotherId];
            if (_isAttackSuccessfull(_attack, another.defence)) { // Attack is correct
                if (attacker.stage >= another.stage) { // Victory if your dragon is same stage or higher
                    _DragonVictory(attacker, another);
                } 
                else if (_getRandom() % 100 < 70) { // Victory if your dragon stage is lower but you get 70% chance
                    _DragonVictory(attacker, another);
                }
                else { // Loss
                    _DragonLoss(attacker, another);
                }
            }
            else { // Attack is incorrect but still have chance to win
                if (attacker.stage > another.stage && _getRandom() % 100 < 50) { // Victory if stage is higher and get 50% chance
                    _DragonVictory(attacker, another);
                }
                else if (attacker.stage == another.stage && _getRandom() % 100 < 30){ // Victory if stage is the same and get 30% chance
                    _DragonVictory(attacker, another);
                } 
                else if (_getRandom() % 100 < 10) { // Victory if stage is lower but got 10% chence
                    _DragonVictory(attacker, another);
                }
                else { // Loss
                    _DragonLoss(attacker, another);
                }
            }
            _triggerAttackCooldown(attacker);
        }
}