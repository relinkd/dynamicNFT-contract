// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RScore is ERC721, Ownable {

    struct ProtocolState {
        string metadataEndpoint;
        bool isPaused;
        uint256 price;
    }

    ProtocolState private _protocolState;

    struct TokenInfo {
        uint256 tokenId;
        bool hasToken;
    }

    mapping(address => TokenInfo) private _ownedTokens; 

    uint256 private _counter = 0;

    constructor(ProtocolState memory protocolState) ERC721("rScore", "rs") {
        _protocolState = protocolState;
    }

    function setProtocolState(
        string memory metadataEndpoint,
        bool isPaused,
        uint256 price
    ) external onlyOwner {
        _protocolState = ProtocolState({
            metadataEndpoint: metadataEndpoint,
            isPaused: isPaused,
            price: price
        });
    }

    function getProtocolState() external view returns (ProtocolState memory) {
        return _protocolState;
    }

    function mint(address receiver) external payable {
        require(!_protocolState.isPaused || _msgSender() == owner(), "Contract is paused");
        require(!_ownedTokens[receiver].hasToken || _msgSender() == owner(), "Address already owns a token");

        if (_protocolState.price > 0 && _msgSender() != owner()) {
            require(
                msg.value == _protocolState.price,
                "Value is not enough"
            );
        }

        _safeMint(receiver, _counter);
        _ownedTokens[receiver] = TokenInfo(_counter, true);
        _counter++;
    }

    function bulkMint(address[] memory receivers) external onlyOwner {

        for (uint256 i = 0; i < receivers.length; i++) {
            address receiver = receivers[i];

            _safeMint(receiver, _counter);
            _ownedTokens[receiver] = TokenInfo(_counter, true);
            _counter++;
        }

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        string memory tokenIdString = Strings.toString(tokenId);
        string memory addressOfOwner = Strings.toHexString(uint160(ownerOf(tokenId)), 20);
        
        return string(abi.encodePacked(_protocolState.metadataEndpoint, "?tokenId=", tokenIdString, "&owner=", addressOfOwner));
    }

    function withdrawFunds(address withdrawAddress) external onlyOwner() {
        uint256 balance = address(this).balance;
        if (balance > 0) TransferHelper.safeTransferETH(withdrawAddress, balance);
    }
  
}