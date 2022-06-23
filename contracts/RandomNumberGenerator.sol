//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.7/VRFConsumerBase.sol";
import "./Lottery.sol";

contract RandomNumberGenerator is VRFConsumerBase {
    address requester;
    bytes32 keyHash;
    uint256 fee;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        fee = _fee;
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        external
        override
    {
        Lottery(requester).numberDrawn(_requestId, _randomness);
    }

    function request(uint256 _seed) public returns (bytes32 requestId) {
        require(keyHash != bytes32(0), "Must have valid key hash");
        requester = msg.sender;
        return this.requestRandomness(keyHash, fee, _seed);
    }
}
