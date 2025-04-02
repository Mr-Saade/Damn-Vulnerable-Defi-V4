using DamnValuableToken as token;

methods {
    function token.allowance(address, address) external returns (uint256) envfree;
       function _._ external => DISPATCH [
        token._, 
        currentContract._
    ] default NONDET;
        
}


invariant poolAllowanceIsAlwaysZero(address someUser)
    token.allowance(currentContract, someUser) == 0
    {
        preserved with (env e) 
        {
            require e.msg.sender != currentContract;
        }
    }
    

