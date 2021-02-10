pragma solidity ^0.6.12;

import "./Dragonbattle.sol";

// TODO tests

contract DragonTokenERC721 is DragonBattle {
    string private _name = "DragonToken";
    string private _symbol = "DRGN";
    mapping (uint256 => address) private _tokenApprovals;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function balanceOf(address _owner) public view returns (uint256) {
        return ownerDragonsCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return ownerById[_tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return dragons.length;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerDragonsCount[_to]++;
        ownerDragonsCount[_from]--;
        ownerById[_tokenId] = _to;
        _tokenApprovals[_tokenId] = address(0);
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        require (_from != _to, "Cannot send token to yourself!");
        require (_from != address(0));
        require (_to != address(0));
        require (ownerById[_tokenId] == _from);
        require (ownerById[_tokenId] == msg.sender || _tokenApprovals[_tokenId] == msg.sender, 
                    "You must be owner of a token or be approved to transfer token");
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public payable _ownerOfDragon(_tokenId) {
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}