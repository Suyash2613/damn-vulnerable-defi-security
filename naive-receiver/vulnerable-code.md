
Naive Receiver — Vulnerable Code Analysis


1. Vulnerable Flash Loan Fee Logic
 
 ```javascript
  function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
        external
        returns (bool)
    {
        if (token != address(weth)) revert UnsupportedCurrency();

        // Transfer WETH and handle control to receiver
        weth.transfer(address(receiver), amount);
        totalDeposits -= amount;  

        if (receiver.onFlashLoan(msg.sender, address(weth), amount, FIXED_FEE, data) != CALLBACK_SUCCESS) {
            revert CallbackFailed();
        }

        uint256 amountWithFee = amount + FIXED_FEE;
        weth.transferFrom(address(receiver), address(this), amountWithFee);
        totalDeposits += amountWithFee;

        deposits[feeReceiver] += FIXED_FEE;

        return true;
    }
```

Security observation:

The pool charges a fixed fee for flash loans, including zero-amount loans. The fee logic becomes an attack surface when the receiver can be repeatedly charged without meaningful authorization or protection.

Impact: An attacker can repeatedly invoke flash loans and drain the receiver's funds through accumulated fees.

2. Withdrawal Function
 ```javascript

function withdraw(
    uint256 amount,
    address payable receiver
) external {
    deposits[_msgSender()] -= amount;
    totalDeposits -= amount;
    weth.transfer(receiver, amount);
}

 ```

Security observation:

Withdrawal authorization depends on _msgSender() rather than directly using msg.sender.

This makes the correctness of the custom sender-resolution mechanism security-critical.
 

3. Custom Sender Resolution

Source: src/naive-receiver/NaiveReceiverPool.sol

 ```javascript
function _msgSender()
    internal
    view
    override
    returns (address)
{
    if (
        msg.sender == trustedForwarder &&
        msg.data.length >= 20
    ) {
        return address(
            bytes20(msg.data[msg.data.length - 20:])
        );
    } else {
        return super._msgSender();
    }
}
 
 ```
Security observation:

When a trusted forwarder calls the pool, the final 20 bytes of the current calldata are interpreted as the sender.

This creates an important trust assumption: the contract must ensure that the forwarded sender information is handled correctly across all execution paths.

4. Multicall uses 'delegatecall'

```javascript

function multicall(
    bytes[] calldata data
)
    external
    virtual
    returns (bytes[] memory results)
{
    results = new bytes[](data.length);

    for (uint256 i = 0; i < data.length; i++) {
        results[i] = Address.functionDelegateCall(
            address(this),
            data[i]
        );
    }
}
  ```
Security observation:

The multicall implementation uses delegatecall to execute multiple operations against the same contract.

During delegated execution:

The original msg.sender is preserved.

The storage context remains the target contract's storage.

The current execution frame receives the inner calldata.

The interaction between this behavior and the custom _msgSender() implementation is particularly important.

5. Forwarder Execution

Source: src/naive-receiver/BasicForwarder.sol

Relevant payload construction:

 ```javascript
 
bytes memory payload = abi.encodePacked(
    request.data,
    request.from
);

Relevant low-level call:

success = target.call{gas: request.gas}(
    payload
);
 ```
Security observation:

The forwarder appends the authenticated request signer to the request calldata before forwarding it.

This mechanism is intended to provide sender information to the recipient contract. However, its interaction with multicall and delegated execution must be examined carefully.

6. Combined Attack Surface

The exploit investigation focuses on the interaction of four components:

Fixed flash loan fees.

Trusted-forwarder sender resolution.

Multicall using delegatecall.

Withdrawal accounting based on _msgSender().

Individually, these components have specific purposes. Their interaction creates the security issue investigated in this challenge.

Important Note

The snippets above are selected portions of the original challenge contracts, not complete source files.

Original source code remains attributed to the Damn Vulnerable DeFi project. The security observations and exploit investigation are my own research and implementation.