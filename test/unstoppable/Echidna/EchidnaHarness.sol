//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../src/DamnValuableToken.sol";
import "../../../src/unstoppable/UnstoppableMonitor.sol";
import "../../../src/unstoppable/UnstoppableVault.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract EchidnaHarness is IERC3156FlashBorrower {
    uint256 constant TOKENS_IN_VAULT = 1_000_000e18;
    uint256 constant INITIAL_ATTACKER_BALANCE = 10e18;

    event FlashLoanStatus(bool success);

    DamnValuableToken token;
    UnstoppableVault vault;

    constructor() {
        token = new DamnValuableToken();
        vault = new UnstoppableVault({_token: token, _owner: address(msg.sender), _feeRecipient: address(msg.sender)});
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, msg.sender);
        token.transfer(msg.sender, INITIAL_ATTACKER_BALANCE);
        token.transfer(address(this), 30000e18); //Fees
    }

    function onFlashLoan(address initiator, address _token, uint256 amount, uint256 fee, bytes calldata)
        external
        returns (bytes32)
    {
        require(initiator == address(this) && msg.sender == address(vault) && _token == address(vault.asset()));

        token.approve(address(vault), amount + fee);

        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

    function invariant_testFlashLoan(uint256 amount) public {
        amount = amount % TOKENS_IN_VAULT;
        require(amount > 0 && amount < vault.maxFlashLoan(address(token)));

        try vault.flashLoan(this, address(vault.asset()), amount, bytes("")) {
            emit FlashLoanStatus(true);
            assert(true);
        } catch {
            emit FlashLoanStatus(false);
            assert(false);
        }
    }
}
