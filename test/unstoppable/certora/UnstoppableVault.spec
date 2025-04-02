using UnstoppableVault as lender;
using DamnValuableToken as token;

methods{
    function token.totalSupply() external returns (uint256) envfree;
   
}


// rule reachability(method f)
// {
// 	env e;
// 	calldataarg args;
// 	f(e,args);
// 	satisfy true;
// }

//Ghost variables

persistent ghost mathint sum_of_balances {
    init_state axiom sum_of_balances == 0;
}

persistent ghost mapping(address => mapping(address => uint256)) allowancesMirror;



hook Sstore token.balanceOf[KEY address a] uint256 new_value (uint old_value) {
    sum_of_balances = sum_of_balances + new_value - old_value;
}

hook Sload uint256 balance token.balanceOf[KEY address a] {
  require sum_of_balances >= to_mathint(balance);
}

hook Sstore token.allowance[KEY address owner][KEY address spender] uint256 newValue (uint256 oldValue) {
    require allowancesMirror[owner][spender] == oldValue;
    allowancesMirror[owner][spender] = newValue;
}

hook Sload uint256 value token.allowance[KEY address owner][KEY address spender] {
    require allowancesMirror[owner][spender] == value;
}


invariant totalSupplyIsSumOfBalances()
    to_mathint(token.totalSupply()) == sum_of_balances;





rule flashLoadDenialOfService()
{
    requireInvariant totalSupplyIsSumOfBalances();
    require forall address a. allowancesMirror[lender][a] == 0;
    
    // Show it's possible for someUser to take out a flash loan
    env e1;
    require e1.msg.sender != currentContract && e1.msg.sender != lender && e1.msg.sender != token;

    uint256 amount;

    storage init = lastStorage;

    checkFlashLoan(e1, amount);

    // simulate other user operation
    env e2;
    require e1.msg.sender != e2.msg.sender && e2.msg.sender != currentContract && e2.msg.sender != lender && e2.msg.sender != token;

    method f;
    calldataarg args;

    f(e2, args) at init;

    // User should still be able to perform the same flashloan
    checkFlashLoan@withrevert(e1, amount);
    assert !lastReverted;
}