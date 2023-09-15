// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

    uint256 private _counter;

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

    function mint(address receiver) external {
        require(!_protocolState.isPaused, "Contract is paused");
        require(_protocolState.price == 0 || _msgSender() == owner(), "Price required");
        require(!_ownedTokens[receiver].hasToken, "Address already owns a token");

        _safeMint(receiver, _counter);
        _ownedTokens[receiver] = TokenInfo(_counter, true);
        _counter++;
    }

    function bulkMint(address[] memory receivers) external onlyOwner {
        require(!_protocolState.isPaused, "Contract is paused");
        require(_protocolState.price == 0, "Price required");

        for (uint256 i = 0; i < receivers.length; i++) {
            address receiver = receivers[i];
            require(!_ownedTokens[receiver].hasToken, "Address already owns a token");

            _safeMint(receiver, _counter);
            _ownedTokens[receiver] = TokenInfo(_counter, true);
            _counter++;
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
      
            return
                string(
                    abi.encodePacked(
                        "data:application/json;base64,",
                        Base64.encode(
                            abi.encodePacked(
                                '{"name":"',
                                Strings.toString(_counter),
                                '","description":"',
                                Strings.toString(_counter),
                                ' test","image":"test',
                                '"}]}'
                            )
                        )
                    )
                );
    }
  
}