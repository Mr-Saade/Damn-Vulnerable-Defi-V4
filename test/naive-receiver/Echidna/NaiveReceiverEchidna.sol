//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../src/naive-receiver/NaiveReceiverPool.sol";
import "../../../src/naive-receiver/FlashLoanReceiver.sol";
import "../../../src/naive-receiver/BasicForwarder.sol";

import {WETH} from "solmate/tokens/WETH.sol";

contract NaiveReceiverEchidna {
    event PoolBalance(uint256 amount);
    event DeployerBalance(uint256 amount);

    NaiveReceiverPool pool;
    FlashLoanReceiver receiver;
    BasicForwarder forwarder;
    WETH weth;

    uint256 constant WETH_IN_RECEIVER = 10e18;
    uint256 echidnaDeposit;
    address echidna;

    constructor() payable {
        echidna = msg.sender;
        forwarder = new BasicForwarder();
        weth = new WETH();
        pool = new NaiveReceiverPool(
            address(forwarder),
            payable(address(weth)),
            echidna
        );
        pool.deposit{value: 1e18}();
        echidnaDeposit = pool.deposits(echidna);

        receiver = new FlashLoanReceiver(address(pool));
        weth.deposit{value: WETH_IN_RECEIVER}();
        weth.transfer(address(receiver), WETH_IN_RECEIVER);
    }

    function echidna_test_receiver_balance() public view returns (bool) {
        //Inavaroant 1:
        //check if the receiver contract balance can be drained

        return weth.balanceOf(address(receiver)) >= WETH_IN_RECEIVER;
    }

    //WIIP
    // function echidna_test_contract_balance() public view returns (bool) {
    //     //Invariant 2:
    //     //check if the pool contract can be drained
    //     return pool.deposits(echidna) >= echidnaDeposit;
    // }
}
