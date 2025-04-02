//WIP: Echidna could not discover the bug, YET.

//SPDX-License-Identifier: MIT

import "../../../src/truster/TrusterLenderPool.sol";
import "../../../src/DamnValuableToken.sol";

pragma solidity ^0.8.0;

contract EchidnaTruster {
    TrusterLenderPool pool;
    DamnValuableToken token;
    uint256 constant TOKENS_IN_POOL = 1_000_000e18;

    constructor() {
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);
        token.transfer(address(pool), TOKENS_IN_POOL);
    }

    function echidna_test_pool_balance_cannot_be_drained()
        public
        view
        returns (bool)
    {
        return token.balanceOf(address(pool)) >= TOKENS_IN_POOL;
    }

    function flashLoanWrapper(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) public {
        require(
            target == address(token) ||
                target == address(pool) ||
                isContract(target),
            "Target must be a contract"
        );
        amount = amount % TOKENS_IN_POOL;

        require(pool.flashLoan(amount, borrower, target, data));
    }

    //helper-contract

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
