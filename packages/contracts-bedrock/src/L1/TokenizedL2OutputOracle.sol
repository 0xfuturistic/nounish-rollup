// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { L2OutputOracle } from "./L2OutputOracle.sol";

contract TokenizedL2OutputOracle is L2OutputOracle, ERC721Upgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        uint256 _submissionInterval,
        uint256 _l2BlockTime,
        uint256 _finalizationPeriodSeconds
    ) L2OutputOracle(_submissionInterval, _l2BlockTime, _finalizationPeriodSeconds) {}

    function initialize(
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp,
        address _proposer,
        address _challenger
    ) public override reinitializer(2) {
        super.initialize(_startingBlockNumber, _startingTimestamp, _proposer, _challenger);

        __ERC721_init("L2OutputOracle", "PROPOSER");
        __AccessControl_init();

        _grantRole(MINTER_ROLE, msg.sender); // TODO: set as auctioneer's address
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function proposeL2Output(
        bytes32 _outputRoot,
        uint256 _l2BlockNumber,
        bytes32 _l1BlockHash,
        uint256 _l1BlockNumber
    ) public payable override {
        _handleNextProposerNotMinted();
        proposer = nextProposerAddress();

        super.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);

        _burn(nextOutputIndex());
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
    }

    function nextProposerAddress() public view returns (address) {
        return ownerOf(nextOutputIndex()); // todo: get erc6551 account address
    }

    function _handleNextProposerNotMinted() internal {
        uint256 l2OutputIndex = nextOutputIndex();
        if (!_exists(l2OutputIndex)) {
            _safeMint(proposer, l2OutputIndex);
        }
    }
}
