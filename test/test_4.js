const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const DragonManager = artifacts.require('DragonTokenERC721');
const name = 'Drakosha';

describe('Testset for Dragon and Gems #4', () => {
    let deployer;
    let user1, user2, user3, user4, user5;
    let contractInstance;
    let snapshotId;

    before(async() => {
        [
            deployer,
            user1, user2, user3, user4, user5
        ] = await web3.eth.getAccounts();
        contractInstance = await DragonManager.new({from: deployer});
    });


describe('DragonToken Test', () => {
    beforeEach(async() => {
        // Create a snapshot
        const snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
      });

    afterEach(async() => await timeMachine.revertToSnapshot(snapshotId));

    it('Should show balance of an address', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await timeMachine.advanceTime(86400);
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await timeMachine.advanceTime(86400);
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        let result = await contractInstance.balanceOfDragon(user1, {from: user2});
        expect(result.toNumber()).to.equal(3);
    });

    it('Should show owner of dragon', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        let result = await contractInstance.ownerOf(0, {from: user1});
        expect(result).to.equal(user1);
        result = await contractInstance.ownerOf(1, {from: user1});
        expect(result).to.equal(user2);
    });

    it('Should show total amount of dragons', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        let result = await contractInstance. totalSupplyDragon();
        expect(result.toNumber()).to.equal(2);
    });

    it('Should let owner of dragon transfer token', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.transferFrom(user1, user2, 0, {from: user1});
        let result = await contractInstance.ownerOf(0, {from: user1});
        expect(result).to.equal(user2);
        result = await contractInstance.balanceOfDragon(user1, {from: user1});
        expect(result.toNumber()).to.equal(0);
        result = await contractInstance.balanceOfDragon(user2, {from: user1});
        expect(result.toNumber()).to.equal(1);
    });

    it('Should let approved transfer token', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.approve(user2, 0, {from: user1});
        await contractInstance.transferFrom(user1, user3, 0, {from: user2});
        let result = await contractInstance.ownerOf(0, {from: user1});
        expect(result).to.equal(user3);
        result = await contractInstance.getApproved(0, {from: user3});
        expect(result).to.equal("0x0000000000000000000000000000000000000000");
    });

    it('Should not let send token to yourself', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await truffleAssert.reverts(
            contractInstance.transferFrom(user1, user1, 0, {from: user2}),
            "Cannot send token to yourself!"
        );
    });

    it('Should not let send token neither not owner nor not approved', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.approve(user2, 0, {from: user1});
        await truffleAssert.reverts(
            contractInstance.transferFrom(user1, user3, 0, {from: user3}),
            "You must be owner of a token or be approved to transfer token"
        );
    });
    });
});