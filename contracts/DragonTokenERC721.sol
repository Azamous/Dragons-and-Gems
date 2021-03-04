pragma solidity ^0.6.12;

import "./Dragonbattle.sol";


contract DragonTokenERC721 is DragonBattle {
    string private _name = "DragonToken";
    string private _symbol = "DRGN";
    mapping (uint256 => address) private _tokenApprovals;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function nameDragon() external view returns (string memory) {
        return _name;
    }

    function symbolDragon() external view returns (string memory) {
        return _symbol;
    }

    function balanceOfDragon(address _owner) external view returns (uint256) {
        return ownerDragonsCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(_tokenId < dragons.length, "Dragon doesn't exist");
        return ownerById[_tokenId];
    }

    function totalSupplyDragon() external view returns (uint256) {
        return dragons.length;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transferDragon(_from, _to, _tokenId);
    }

    function safeTransferFromDragon(address _from, address _to, uint256 _tokenId) external payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (_from != address(0));
        require (_to != address(0));
        require (ownerById[_tokenId] == _from);
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transferDragon(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable _ownerOfDragon(_tokenId) {
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view returns(address) {
        return _tokenApprovals[_tokenId];
    }

    function _transferDragon(address _from, address _to, uint256 _tokenId) private {
        ownerDragonsCount[_to] = ownerDragonsCount[_to].add(1);
        ownerDragonsCount[_from] = ownerDragonsCount[_from].sub(1);
        ownerById[_tokenId] = _to;
        _tokenApprovals[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }
}