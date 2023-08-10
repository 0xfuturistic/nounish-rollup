// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

type IntentApp is address;

library IntentAppLib {
    function run(IntentApp app, bytes memory data) internal {
        bytes memory callData = abi.encodeWithSignature("run(bytes calldata)", abi.encode(data));
        (bool success,) = IntentApp.unwrap(app).call(callData);
        assert(success);
    }
}

using IntentAppLib for IntentApp global;

abstract contract IntentAppAccount is Ownable {
    IntentApp[] private _apps;

    modifier apps(bytes memory data) {
        _;

        for (uint256 i = 0; i < _apps.length; i++) {
            _apps[i].run(data);
        }
    }

    function addApp(IntentApp app) external onlyOwner {
        _addApp(app);
    }

    function _addApp(IntentApp app) internal {
        _apps.push(app);
    }
}
