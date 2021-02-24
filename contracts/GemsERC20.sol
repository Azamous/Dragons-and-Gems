pragma solidity ^0.6.12;

import "./DragonHelper.sol";
// Transfer gems among dragons
// Dragons ids are used instead of address

contract GemsERC20 is DragonHelper {
    mapping (uint256 => uint256) internal _balances;
    mapping(uint256 => mapping(address => uint256)) internal _allowances;
    
    string private _name = "GemToken";
    string private _symbol = "GM";

    uint256 private _totalSupply;

    event Approval(uint256 indexed owner, address indexed approved, uint256 amount);
    event Transfer(uint256 indexed from, uint256 indexed to, uint256 amount);

    modifier checkAllowance(uint256 _dragonSender, uint256 _amount) {
         require(_allowances[_dragonSender][msg.sender] >= _amount, 
                "You are not permitted to use this amount of gems");
         _;
    }

    function nameGems() public view returns (string memory) {
        return _name;
    }

    function symbolGems() public view returns (string memory) {
        return _symbol;
    }

    function totalSupplyGems() public view returns (uint256) {
        return _totalSupply;
    }

    function BalanceOfGems(uint256 _dragonId) public view returns (uint256) {
        return _balances[_dragonId];
    }

    function allowance(uint256 _owner, address _spender) public view returns( uint256) {
        return _allowances[_owner][_spender];
    }

    function approveGems(uint256 _dragonOwner, address _spender, uint256 _amount) public
         _ownerOfDragon(_dragonOwner) returns (bool) {
             _approveGems(_dragonOwner, _spender, _amount);
             return true;
         } 

    function increaseAllowance(uint256 _dragonId, address _spender, uint256 _value) public
        _ownerOfDragon(_dragonId) returns (bool) {
            _approveGems(_dragonId, _spender, _allowances[_dragonId][_spender].add(_value));
            return true;
    }

    function decreaseAllowances(uint256 _dragonId, address _spender, uint256 _value) public
         _ownerOfDragon(_dragonId) returns (bool) {
        _approveGems(_dragonId, _spender, _allowances[_dragonId][_spender].sub(_value));
        return true;
    }

    function transferGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) public 
            _ownerOfDragon(_dragonSender) returns (bool) {
                _transferGems(_dragonSender, _dragonReceiver, _amount);
                return true;
            }

    function transferFromGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) public
               checkAllowance(_dragonSender, _amount) returns (bool) {
                   _transferGems(_dragonSender, _dragonReceiver, _amount);
                    _approveGems(_dragonSender, msg.sender, _allowances[_dragonSender][msg.sender].sub(_amount));
                    return true;
                }

    function _transferGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) internal {
        require(_dragonReceiver < dragons.length, "Dragon doesn't exist");
        require(_amount.add(_balances[_dragonReceiver]) <= dragons[_dragonReceiver].gemsMax, "Dragon cant hold so much gems");
        _balances[_dragonSender] = _balances[_dragonSender].sub(_amount);
        _balances[_dragonReceiver] = _balances[_dragonReceiver].add(_amount);
        emit Transfer(_dragonSender, _dragonReceiver, _amount);
    }

    function _approveGems(uint256 _dragonOwner, address _spender, uint256 _amount) internal {
            require (_spender != address(0), "Approve to the zero address");
             _allowances[_dragonOwner][_spender] = _amount;
             emit Approval(_dragonOwner, _spender, _amount);
    }

    function _mintGems(uint256 _dragonId, uint256 _amount) internal {
        require(_dragonId < dragons.length, "Dragon doesn't exist");
        _totalSupply = _totalSupply.add(_amount);
        _balances[_dragonId] = _balances[_dragonId].add(_amount);
    }

    function _burnGems(uint256 _dragonId, uint256 _amount) internal {
        _balances[_dragonId] = _balances[_dragonId].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);
    }
}