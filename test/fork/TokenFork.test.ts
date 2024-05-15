import type { SnapshotRestorer } from "@nomicfoundation/hardhat-network-helpers";
import { takeSnapshot, setBalance } from "@nomicfoundation/hardhat-network-helpers";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { eth, toBN } from "../helpers";
const { AddressZero } = ethers.constants;

import type { MyToken, UniswapV2Router02 } from "../../typechain-types";

import config from "../../hardhat.config";
const oneUsd = 1000000;

if (config.networks?.hardhat?.forking?.enabled) {
    describe("Token: Fork test...", function () {
        let snapshotA: SnapshotRestorer;
        let users: any = [];

        // Signers.
        let deployer: SignerWithAddress, owner: SignerWithAddress;
        let user1: SignerWithAddress, user2: SignerWithAddress, user3: SignerWithAddress;

        let routerAddress;
        let uni: any;
        let myToken: MyToken;

        before(async () => {
            users = await ethers.getSigners();
            deployer = users[0];
            user1 = users[1];
            user2 = users[2];
            user3 = users[3];

            routerAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
            // constructor(uint256 fee_, address feeReceiver_, address routerAddress_)
            const fee_ = 1000; // 10%
            const feeReceiver_ = user3.address;

            const MyToken = await ethers.getContractFactory("MyToken", deployer);
            myToken = await MyToken.deploy(fee_, feeReceiver_, routerAddress);
            await myToken.deployed();
            // console.log("myToken: ", myToken.address);

            // get uniswap router at address
            uni = await ethers.getContractAt("UniswapV2Router02", routerAddress);
            console.log("uni: ", uni);




            snapshotA = await takeSnapshot();
        });

        afterEach(async () => await snapshotA.restore());

        describe("# Tests ", function () {
            it("Should --- ", async () => {
                console.log("PASS: Should ---");

                // const WETH = await uni.WETH();
                // console.log("WETH: ", WETH);
                
                // swap 1 eth to  myToken
                const ethAmount = eth(1);
                const deadline = 19560720*2
                // const path = [WETH, myToken.address];
                // const value = ethAmount;
                // const minTokens = 0;
                // const to = user1.address;
                // const tx = await uni.swapExactETHForTokens(0, path, to, deadline, { value, gasPrice: 0 });
            });
        });
    });
} else {
    console.log("FORK is Inactive");
    console.log("The Raffle.test.js assume the launch on the hardhat network only.");
}


            // referralAddress = referral.address;

            // // create usdt contract instance
            // const user1Address = "0x48EaeA019f7c261ee11C28B00FC3D333352F77AF";
            // const user2Address = "0x56b6730FbDaac504Ec47b6580Fa9D9F9CccdcC5C";

            // await helpers.impersonateAccount(user1Address);
            // user3 = await ethers.getSigner(user1Address);

            // await helpers.impersonateAccount(admin);
            // owner = await ethers.getSigner(admin);

            // // hardhat set balance
            // const newBalance = ethers.utils.parseEther("1000");
            // // set ETH balance to user1 by hardhat setter
            // await setBalance(worker.address, newBalance);
            // await setBalance(owner.address, newBalance);

            // usdt = await ethers.getContractAt("TetherToken", usdtAddress);
            // // consumer = await ethers.getContractAt("ChainlinkVRFConsumerMock", chainlinkVRFConsumerAddress);
            // subscriptionManager = await ethers.getContractAt("SubscriptionManager", managerAddress);
            // raffle = await ethers.getContractAt("Raffle", raffleAddress);
            // treasury = await ethers.getContractAt("Treasury", treasuryAddress);

            // // deployment of CoordinatorMock contract
            // const CoordinatorMock = await ethers.getContractFactory("CoordinatorMock", deployer);
            // coordinatorMock = await CoordinatorMock.deploy();
            // await coordinatorMock.deployed();

            // // deployment of ChainlinkVRFConsumer contract
            // const ChainlinkVRFConsumer = await ethers.getContractFactory("ChainlinkVRFConsumerMock", deployer);
            // consumer = await ChainlinkVRFConsumer.deploy(coordinatorMock.address, keyHash, mySubscriptionsId);
            // await consumer.deployed();

            // await coordinatorMock.connect(deployer).setConsumer(consumer.address);
            // await consumer.connect(deployer).setRaffle(raffle.address);
            // await raffle.connect(owner).setVrfConsumer(consumer.address);

            // const role = await raffle.WORKER();
            // const vfrRole = await raffle.VRF_CONSUMER();

            // await raffle.connect(owner).grantRole(role, worker.address);
            // await raffle.connect(owner).grantRole(vfrRole, consumer.address);

            // //  const latestBlock = await ethers.provider.getBlock("latest")
            // //  console.log("latestBlock: ", latestBlock.number);

