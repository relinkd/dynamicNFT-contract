// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// helper methods for sending ETH that do not consistently return true/false
library TransferHelper {function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}