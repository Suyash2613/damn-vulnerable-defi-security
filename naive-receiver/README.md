# Naive Receiver — Damn Vulnerable DeFi

## 1. Challenge Overview

The Naive Receiver challenge demonstrates vulnerabilities in a flash loan system involving fixed loan fees and an incorrectly trusted forwarder.

The objective is to drain the funds held by the flash loan receiver and the pool.

## 2. Vulnerability Analysis

The challenge contains two important weaknesses:

### A. Fixed Flash Loan Fee

- The pool charges a fixed fee for every flash loan.
- The fee is charged even when the requested loan amount is zero.
- Repeated zero-amount flash loans can gradually drain the receiver's WETH balance.

### B. Trusted Forwarder and Multicall

- The pool trusts a designated forwarder to identify the original sender.
- Its `_msgSender()` implementation reads the last 20 bytes of calldata.
- The multicall implementation uses `delegatecall`, allowing crafted inner calldata to influence the sender resolution.
- This allows an attacker to manipulate whose deposit balance is used during withdrawal.

## 3. Attack Strategy

1. Deploy the pool with an initial deposit of 1,000 WETH.
2. Fund the flash loan receiver with 10 WETH.
3. Execute ten flash loans with an amount of zero.
4. Drain the receiver's 10 WETH through accumulated fixed fees.
5. Construct withdrawal calldata with carefully chosen trailing addresses.
6. Create and sign a valid EIP-712 forwarder request.
7. Execute the request through the trusted forwarder.
8. Use multicall and delegatecall to withdraw the deposit balances credited to the deployer and fee receiver.

## 4. Proof of Concept

The exploit is implemented using Foundry.

**Test file:** `naive-receiver.t.sol`

The test demonstrates both the repeated zero-amount flash loan attack and the trusted-forwarder/multicall exploit.

## 5. Run the Test

From the original Damn Vulnerable DeFi project environment:

```bash
forge test --match-test test_flashloan -vvvv
```

## 6. Expected Result

The test verifies that:

- The flash loan receiver's WETH balance becomes zero.
- The pool's WETH balance becomes zero.
- The attacker's WETH balance becomes 1,010 WETH.

## 7. What I Learned

- How fixed flash loan fees can create an unexpected attack vector.
- How EIP-712 signatures authenticate forwarded requests.
- How trusted forwarders influence `_msgSender()`.
- How `delegatecall` preserves the caller while changing the calldata context.
- How multicall can introduce security risks when combined with unsafe sender resolution.

## 8. Attribution

Challenge source: [Damn Vulnerable DeFi](https://github.com/theredguild/damn-vulnerable-defi)

The original challenge contracts and framework belong to their respective authors. The exploit PoC and analysis in this folder represent my own learning and implementation.