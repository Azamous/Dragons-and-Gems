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

    /// @dev Returns name of token
    function nameGems() external view returns (string memory) {
        return _name;
    }

    /// @dev Returns symbol of token
    function symbolGems() external view returns (string memory) {
        return _symbol;
    }

    /// @dev Returns total supply tokens
    function totalSupplyGems() external view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Returns balance of a dragon
    /// @param _dragonId Id of dragon who holds gems
    function BalanceOfGems(uint256 _dragonId) external view returns (uint256) {
        return _balances[_dragonId];
    }

    /// @dev Returns allowance of gems
    function allowance(uint256 _owner, address _spender) external view returns( uint256) {
        return _allowances[_owner][_spender];
    }

    /// @dev Sets allowance for an address to use dragon's gems
    /// @param _dragonOwner Id of dragon who holds gems
    /// @param _spender Approved address to use gems
    /// @param _amount Amount of gems to use
    function approveGems(uint256 _dragonOwner, address _spender, uint256 _amount) external
         _ownerOfDragon(_dragonOwner) returns (bool) {
             _approveGems(_dragonOwner, _spender, _amount);
             return true;
         } 

    /// @dev Sets a new allowance to Previous allowance + _value
    /// @param _dragonId Id of dragon who holds gems
    /// @param _spender Approved address to use gems
    /// @param _value Value of gems to increase allowance on
    function increaseAllowance(uint256 _dragonId, address _spender, uint256 _value) external
        _ownerOfDragon(_dragonId) returns (bool) {
            _approveGems(_dragonId, _spender, _allowances[_dragonId][_spender].add(_value));
            return true;
    }

    /// @dev Sets a new allowance to Previous allowance - _value
    /// @param _dragonId Id of dragon who holds gems
    /// @param _spender Approved address to use gems
    /// @param _value Value of gems to increase allowance on
    function decreaseAllowances(uint256 _dragonId, address _spender, uint256 _value) external
         _ownerOfDragon(_dragonId) returns (bool) {
        _approveGems(_dragonId, _spender, _allowances[_dragonId][_spender].sub(_value));
        return true;
    }

    /// @dev Allows owner of dragon to send gems to another dragon
    /// @param _dragonSender Id of dragon who holds gems
    /// @param _dragonReceiver Id of dragon to send gems to
    /// @param _amount Amount of gems to send
    function transferGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) external 
            _ownerOfDragon(_dragonSender) returns (bool) {
                _transferGems(_dragonSender, _dragonReceiver, _amount);
                return true;
            }

    /// @dev Allows approved address to send gems to another dragon
    /// @param _dragonSender Id of dragon who holds gems
    /// @param _dragonReceiver Id of dragon to send gems to
    /// @param _amount Amount of gems to send
    function transferFromGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) external
               checkAllowance(_dragonSender, _amount) returns (bool) {
                   _transferGems(_dragonSender, _dragonReceiver, _amount);
                    _approveGems(_dragonSender, msg.sender, _allowances[_dragonSender][msg.sender].sub(_amount));
                    return true;
                }

    /// @dev Private function to transfer gems, checks that dragon exists and balance
    /// @param _dragonSender Id of dragon who holds gems
    /// @param _dragonReceiver Id of dragon to send gems to
    /// @param _amount Amount of gems to send
    function _transferGems(uint256 _dragonSender, uint256 _dragonReceiver, uint256 _amount) private {
        require(_dragonReceiver < dragons.length, "Dragon doesn't exist");
        require(_amount.add(_balances[_dragonReceiver]) <= dragons[_dragonReceiver].gemsMax, "Dragon cant hold so much gems");
        _balances[_dragonSender] = _balances[_dragonSender].sub(_amount);
        _balances[_dragonReceiver] = _balances[_dragonReceiver].add(_amount);
        emit Transfer(_dragonSender, _dragonReceiver, _amount);
    }

    /// @dev Private function which approves address to use amount of dragon's gems
    /// @param _dragonOwner Id of dragon who holds gems
    /// @param _spender Approved address to use gems
    /// @param _amount Amount of gems to use
    function _approveGems(uint256 _dragonOwner, address _spender, uint256 _amount) private {
            require (_spender != address(0), "Approve to the zero address");
             _allowances[_dragonOwner][_spender] = _amount;
             emit Approval(_dragonOwner, _spender, _amount);
    }

    /// @dev mints new gems to a newly created dragon
    /// @param _dragonId ID of a dragon to mint gems to
    /// @param _amount Amount of gems to mint
    function _mintGems(uint256 _dragonId, uint256 _amount) internal {
        require(_dragonId < dragons.length, "Dragon doesn't exist");
        _totalSupply = _totalSupply.add(_amount);
        _balances[_dragonId] = _balances[_dragonId].add(_amount);
    }

    /// @dev Burns gems, when dragon spends them
    /// @param _dragonId ID of a dragon to burn gems from
    /// @param _amount Amount of gems to burn
    function _burnGems(uint256 _dragonId, uint256 _amount) internal {
        _balances[_dragonId] = _balances[_dragonId].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);
    }
}