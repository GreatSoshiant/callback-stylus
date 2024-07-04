// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TargetInterface {
    function check(string calldata input) external returns (string memory);
}

contract TargetContract {
    address public targetAddress;

    constructor(address _targetAddress) {
        targetAddress = _targetAddress;
    }

    function callBack() external returns (string memory) {
        TargetInterface target = TargetInterface(targetAddress);
        string memory response = target.check("The call is Received");
        return response;
    }
}

// Example target contract to be called
contract Target {
    function check(string calldata input) external pure returns (string memory) {
        return input;
    }
}
