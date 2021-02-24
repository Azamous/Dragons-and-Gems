const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const DragonManager = artifacts.require('DragonManager');
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
        assert.equal(result, 3);
    });

    it('Should show owner of dragon', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        let result = await contractInstance.ownerOfDragon(0, {from: user1});
        assert.equal(result, user1);
        result = await contractInstance.ownerOfDragon(1, {from: user1});
        assert.equal(result, user2);
    });

    it('Should show total amount of dragons', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        let result = await contractInstance. totalSupplyDragon();
        assert.equal(result, 2);
    });

    it('Should let owner of dragon transfer token', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.transferFromDragon(user1, user2, 0, {from: user1});
        let result = await contractInstance.ownerOfDragon(0, {from: user1});
        assert.equal(result, user2);
        result = await contractInstance.balanceOfDragon(user1, {from: user1});
        assert.equal(result, 0);
        result = await contractInstance.balanceOfDragon(user2, {from: user1});
        assert.equal(result, 1);
    });

    it('Should let approved transfer token', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.approveDragon(user2, 0, {from: user1});
        await contractInstance.transferFromDragon(user1, user3, 0, {from: user2});
        let result = await contractInstance.ownerOfDragon(0, {from: user1});
        assert.equal(result, user3);
        result = await contractInstance.showApproved(0, {from: user3});
        assert.equal(result, 0);
    });

    it('Should not let send token to yourself', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        try {
            await contractInstance.transferFromDragon(user1, user1, 0, {from: user2});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
    });

    it('Should not let send token neither not owner nor not approved', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.approveDragon(user2, 0, {from: user1});
        try {
            await contractInstance.transferFromDragon(user1, user3, 0, {from: user3});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
    });
    });
});