// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { L2OutputOracle } from "./L2OutputOracle.sol";
import { Token as NounsERC721 } from "nouns-protocol/token/Token.sol";

contract TokenizedL2OutputOracle is NounsERC721, L2OutputOracle {
    address constant DEFAULT_PROPOSER = address(0); /// @dev harcoded value in L2OutputOracle initialization

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
            /// @dev the token hasn't been minted, so DEFAULT_PROPOSER is the proposer
            proposer = DEFAULT_PROPOSER;
        } else {
            /// @dev the token has been minted, so the token's owner is the proposer
            proposer = owners[tokenId];
            _burn(tokenId);
        }

        super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
    }
}
