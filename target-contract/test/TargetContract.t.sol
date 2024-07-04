// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TargetContract.sol";

contract TargetContractTest is Test {
    TargetContract targetContractInstance;
    Target target;

    function setUp() public {
        target = new Target();
        targetContractInstance = new TargetContract(address(target));
    }

    function testCallBack() public {
        string memory expected = "The call is Received";
        string memory result = targetContractInstance.callBack();
        assertEq(result, expected);
    }
}
