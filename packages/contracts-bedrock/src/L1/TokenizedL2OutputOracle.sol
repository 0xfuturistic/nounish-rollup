// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { L2OutputOracle } from "./L2OutputOracle.sol";
import { Token as NounsERC721 } from "nouns-protocol/token/Token.sol";

contract TokenizedL2OutputOracle is NounsERC721, L2OutputOracle {
    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _finalizationPeriodSeconds,
        address _tokenManager
    ) L2OutputOracle(_submissionInterval, _l2BlockTime, _finalizationPeriodSeconds) NounsERC721(_tokenManager) {}

    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        public
        payable
        override
    {
        uint tokenId = nextOutputIndex();

        if (owners[tokenId] == address(0)){
            /// @dev the token hasn't been minted, so only allow default proposer to propose
            super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
        } else {
            /// @dev the token has been minted, so only allow the owner to propose. override
            ///      the proposer so that it's picked up by L2OutputOracle and then reset it
            ///      to the default proposer so we don't lose the latter.
            address defaultProposer = proposer;
            proposer = owners[tokenId];
            super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
            proposer = defaultProposer;
            _burn(tokenId);
        }
    }
}
