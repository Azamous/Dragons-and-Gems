pragma solidity ^0.6.12;

import "./Dragonbattle.sol";


contract DragonTokenERC721 is DragonBattle {
    string private _name = "DragonToken";
    string private _symbol = "DRGN";
    mapping (uint256 => address) private _tokenApprovals;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev Returns name of token
    function nameDragon() external view returns (string memory) {
        return _name;
    }

    /// @dev Returns _symbol of token
    function symbolDragon() external view returns (string memory) {
        return _symbol;
    }

    /// @dev Returns balance of address
    /// @param _owner Address which holds tokens
    function balanceOfDragon(address _owner) external view returns (uint256) {
        return ownerDragonsCount[_owner];
    }

    /// @dev Returns owner of token
    /// @param _tokenId ID of token
    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(_tokenId < dragons.length, "Dragon doesn't exist");
        return ownerById[_tokenId];
    }

    /// @dev Returns total supply of tokens
    function totalSupplyDragon() external view returns (uint256) {
        return dragons.length;
    }

    /// @dev Allowed to owner or approved
    /// @dev Transfer token to another address
    /// @param _from Address of the owner
    /// @param _to Receiver of token
    /// @param _tokenId ID of token to be transfered
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transferDragon(_from, _to, _tokenId);
    }

    /// @dev Provides a safer function to transfer token
    /// @param _from Address of the owner
    /// @param _to Receiver of token
    /// @param _tokenId ID of token to be transfered
    function safeTransferFromDragon(address _from, address _to, uint256 _tokenId) external payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (_from != address(0));
        require (_to != address(0));
        require (ownerById[_tokenId] == _from);
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transferDragon(_from, _to, _tokenId);
    }

    /// @dev Approves address to use token
    /// @param _approved Address to be approved
    /// @param _tokenId ID of token
    function approve(address _approved, uint256 _tokenId) external payable _ownerOfDragon(_tokenId) {
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    /// @dev Returns approved address of token
    /// @param _tokenId ID of token
    function getApproved(uint256 _tokenId) external view returns(address) {
        return _tokenApprovals[_tokenId];
    }

    /// @dev private function which transfers tokens
    function _transferDragon(address _from, address _to, uint256 _tokenId) private {
        ownerDragonsCount[_to] = ownerDragonsCount[_to].add(1);
        ownerDragonsCount[_from] = ownerDragonsCount[_from].sub(1);
        ownerById[_tokenId] = _to;
        _tokenApprovals[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }
}