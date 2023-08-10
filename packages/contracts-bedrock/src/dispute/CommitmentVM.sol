// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IBigStepper} from "./interfaces/IBigStepper.sol";
import {IntentAppAccount} from "./IntentAppAccount.sol";

abstract contract CommitmentVM is IntentAppAccount, IBigStepper {
    function step(bytes calldata _stateData, bytes calldata _proof)
        external
        apps(abi.encode(_stateData, _proof))
        returns (bytes32 postState_)
    {
        (bytes32 preState, bytes memory proof) = abi.decode(_stateData, (bytes32, bytes));
        postState_ = _step(preState, proof);
    }

    function _step(bytes32 _preState, bytes memory _proof) internal virtual returns (bytes32);
}
