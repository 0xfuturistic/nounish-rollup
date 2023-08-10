// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Token} from "nouns-protocol/token/Token.sol";
import {IERC6551Registry} from "erc6551/interfaces/IERC6551Registry.sol";

import {L2OutputOracle} from "./L2OutputOracle.sol";

contract TokenizedL2OutputOracle is L2OutputOracle, Token {
    address public immutable DEFAULT_PROPOSER;
    address public immutable ERC6551_REGISTRY;
    address public immutable PROPOSER_ACCOUNT_IMPL;

    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _finalizationPeriodSeconds,
        address _tokenManager,
        address _defaultProposer,
        address _erc6551Registry,
        address _proposerAccountImpl
    ) L2OutputOracle(_submissionInterval, _l2BlockTime, _finalizationPeriodSeconds) Token(_tokenManager) {
        DEFAULT_PROPOSER = _defaultProposer;
        ERC6551_REGISTRY = _erc6551Registry;
        PROPOSER_ACCOUNT_IMPL = _proposerAccountImpl;
    }

    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        public
        payable
        override
    {
        uint256 tokenId = nextOutputIndex();

        if (owners[tokenId] == address(0)) {
            /// @dev the token hasn't been minted, so DEFAULT_PROPOSER is the proposer
            proposer = DEFAULT_PROPOSER;
        } else {
            /// @dev the token has been minted, so the token's account is the proposer
            proposer = IERC6551Registry(ERC6551_REGISTRY).account(
                PROPOSER_ACCOUNT_IMPL, block.chainid, address(this), tokenId, 0
            );
            _burn(tokenId);
        }

        super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
    }
}
