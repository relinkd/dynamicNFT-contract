// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RScore is ERC721, Ownable {

    uint256 private _counter;
    

    constructor() ERC721("rScore", "rs") {}


    function mint(
        address receiver
    ) external {
        _safeMint(receiver, _counter);
        _counter++;
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