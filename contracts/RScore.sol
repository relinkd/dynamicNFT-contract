// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RScore is ERC721Enumerable, Ownable {

    struct ProtocolState {
        string metadataEndpoint;
        bool isPaused;
        uint256 price;
        string version;
        uint256 maxTokensPerUser;
    }

    ProtocolState private _protocolState;

    mapping(address => uint256) private _ownedTokens; 

    uint256 private _counter = 0;

    constructor(ProtocolState memory protocolState) ERC721("rScore_beta", "rs_beta") {
        _protocolState = protocolState;
    }

    function setProtocolState(ProtocolState memory protocolState) external onlyOwner {
        _protocolState = protocolState;
    }

    function getProtocolState() external view returns (ProtocolState memory) {
        return _protocolState;
    }

    function mint(address receiver) external payable {
        require(!_protocolState.isPaused || _msgSender() == owner(), "Contract is paused");
        require(_ownedTokens[receiver] < _protocolState.maxTokensPerUser || _msgSender() == owner(), "Address already owns a token");

        if (_protocolState.price > 0 && _msgSender() != owner()) {
            require(
                msg.value == _protocolState.price,
                "Value is not enough"
            );
        }

        _safeMint(receiver, _counter);
        _ownedTokens[receiver] = _ownedTokens[receiver]+1;
        _counter++;
    }

    function bulkMint(address[] memory receivers) external onlyOwner {

        for (uint256 i = 0; i < receivers.length; i++) {
            address receiver = receivers[i];

            _safeMint(receiver, _counter);
            _ownedTokens[receiver] = _ownedTokens[receiver]+1;
            _counter++;
        }

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        string memory tokenIdString = Strings.toString(tokenId);
        string memory addressOfOwner = Strings.toHexString(uint160(ownerOf(tokenId)), 20);
        
        return string(abi.encodePacked(_protocolState.metadataEndpoint, "?tokenId=", tokenIdString, "&owner=", addressOfOwner, "&version=", _protocolState.version));
    }

    function withdrawFunds(address withdrawAddress) external onlyOwner() {
        uint256 balance = address(this).balance;
        if (balance > 0) TransferHelper.safeTransferETH(withdrawAddress, balance);
    }
  
}