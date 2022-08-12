const { expect } = require("chai");
const { BN } = require("@openzeppelin/test-helpers");
const { ethers, waffle } = require("hardhat");

let LotteryNft;
let RandomNumberGenerator;
let Lottery;
let owner;
let addr1;
let addr2;
let addrs;

describe("lottery Test", function () {
	beforeEach(async function () {
		[owner, addr1, addr2, ...addrs] = await ethers.getSigners();

		let randomNumberGenerator = await ethers.getContractFactory(
			"RandomNumberGenerator"
		);
		let RandomNumberGenerator = await randomNumberGenerator.deploy();
		await RandomNumberGenerator.deployed();
		let lottery = await ethers.getContractFactory("Lottery");
		Lottery = await lottery.deploy();
		await Lottery.deployed();
		const lotteryContractAddress = Lottery.address;
		let lotteryNFT = await ethers.getContractFactory("LotteryNft");
		LotteryNft = await lotteryNFT.deploy(lotteryContractAddress);
		await LotteryNft.deployed();
	});
	it("");
});
