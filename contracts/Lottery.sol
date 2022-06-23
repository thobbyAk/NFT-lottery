//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RandomNumberGenerator.sol";

contract Lottery is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    using SafeMath for uint256;

    enum LotteryState {
        Open,
        Closed,
        Completed
    }

    mapping(uint256 => EnumerableSet.AddressSet) entries;

    uint256[] numbers;

    LotteryState public state;
    uint256 public numberOfEntries;
    uint256 public entryFee;
    uint256 public ownerCut;
    uint256 public winningNumber;
    address randomNumberGenerator;
    bytes32 randomNumberRequestId;

    event LotteryStateChanged(LotteryState newState);
    event NewEntry(address player, uint256 number);
    event NumberRequested(bytes32 requestId);
    event NumberDrawn(bytes32 requestId, uint256 winningNumber);

    // modifiers
    modifier isState(LotteryState _state) {
        require(state == _state, "Wrong state for this action");
        _;
    }

    modifier onlyRandomGenerator() {
        require(
            msg.sender == randomNumberGenerator,
            "Must be correct generator"
        );
        _;
    }

    //constructor
    constructor(
        uint256 _entryFee,
        uint256 _ownerCut,
        address _randomNumberGenerator
    ) Ownable() {
        require(_entryFee > 0, "Entry fee must be greater than 0");
        require(
            _ownerCut < _entryFee,
            "Entry fee must be greater than owner cut"
        );
        require(
            _randomNumberGenerator != address(0),
            "Random number generator must be valid address"
        );
        require(
            _randomNumberGenerator.isContract(),
            "Random number generator must be smart contract"
        );
        entryFee = _entryFee;
        ownerCut = _ownerCut;
        randomNumberGenerator = _randomNumberGenerator;
        _changeState(LotteryState.Open);
    }

    //functions
    function submitNumber(uint256 _number)
        public
        payable
        isState(LotteryState.Open)
    {
        require(msg.value >= entryFee, "Minimum entry fee required");
        require(
            entries[_number].add(msg.sender),
            "Cannot submit the same number more than once"
        );
        numbers.push(_number);
        numberOfEntries++;
        payable(owner()).transfer(ownerCut);
        emit NewEntry(msg.sender, _number);
    }

    function drawNumber(uint256 _seed)
        public
        onlyOwner
        isState(LotteryState.Open)
    {
        _changeState(LotteryState.Closed);
        randomNumberRequestId = RandomNumberGenerator(randomNumberGenerator)
            .request(_seed);
        emit NumberRequested(randomNumberRequestId);
    }

    function rollover() public onlyOwner isState(LotteryState.Completed) {
        //rollover new lottery
    }

    function numberDrawn(bytes32 _randomNumberRequestId, uint256 _randomNumber)
        public
        onlyRandomGenerator
        isState(LotteryState.Closed)
    {
        if (_randomNumberRequestId == randomNumberRequestId) {
            winningNumber = _randomNumber;
            emit NumberDrawn(_randomNumberRequestId, _randomNumber);
            _payout(entries[_randomNumber]);
            _changeState(LotteryState.Finished);
        }
    }

    function _payout(EnumerableSet.AddressSet storage winners) private {
        uint256 balance = address(this).balance;
        for (uint256 index = 0; index < winners.length(); index++) {
            payable(winners.at(index)).transfer(balance.div(winners.length()));
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }
}
