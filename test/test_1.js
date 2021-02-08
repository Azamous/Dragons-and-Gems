const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const DragonManager = artifacts.require('DragonManager');

const name = 'Pukich';

describe('Testset for Dragon and Gems', () => {
    let deployer;
    let user1, user2;
    let contractInstance;
    let snapshotId;

    before(async() => {
        [
            deployer,
            user1, user2
        ] = await web3.eth.getAccounts();
        contractInstance = await DragonManager.new({from: deployer});
    });


describe('DragonManager Test', () => {
    beforeEach(async() => {
        // Create a snapshot
        const snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
      });

      afterEach(async() => await timeMachine.revertToSnapshot(snapshotId));

      it('Should create dragon type 0 and show him', async () => {
        await contractInstance.CreateGreenWelschDragon(name, {from: user1});
        const result = await contractInstance.ShowDragon(0, {from: user1});
        assert.equal(result[0], name);
        assert.equal(result[1], 0);
        assert.equal(result[2], 0);
        assert.equal(result[3], 1);
        assert.equal(result[4], 0);
        assert.equal(result[5], 0);
      });

      it('Should show all of owner\'s dragons', async () => {
         await contractInstance.CreateGreenWelschDragon('1', {from: user2});
         await timeMachine.advanceTime(86400);
         await contractInstance.CreateGreenWelschDragon('2', {from: user2});
         const result = await contractInstance.ShowOwnerDragons(user2, {from: user2});
         assert.equal(result[0], 0);
         assert.equal(result[0], 1);
      });

      it('Should create another dragon after 1 day', async () => {
        await contractInstance.CreateGreenWelschDragon(name, {from: user1});
        await timeMachine.advanceTime(86400);
        await contractInstance.CreateGreenWelschDragon('123', {from: user1});
        const result = await contractInstance.ShowDragon(1, {from: user1});
        assert.equal(result[0], '123');
      });

      it('Should not allow to create another dragon until 1 day passes', async () => {
        await contractInstance.CreateGreenWelschDragon(name, {from: user1});
        try {
            await contractInstance.CreateGreenWelschDragon(name, {from: user1});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
      });

      it('Should update dragon', async () => {
        await contractInstance.CreateGreenWelschDragon('1', {from: user2});
        await timeMachine.advanceTime(3*86400);
        await contractInstance.GetNextStage(0, {from: user2});
        const result = await contractInstance.ShowDragon(0, {from: user2});
        assert.equal(result[3], 2);
      });

      it ('Should not let another person update dragon', async () => {
        await contractInstance.CreateGreenWelschDragon('1', {from: user1});
        await timeMachine.advanceTime(3*86400);
        try {
            await contractInstance.GetNextStage(0, {from: user2});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
      });

      it ('Should not let update dragon until 3 days pass', async () => {
        await contractInstance.CreateGreenWelschDragon('1', {from: user1});
        await timeMachine.advanceTime(2*86400);
        try {
            await contractInstance.GetNextStage(0, {from: user1});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
      });

      it('Should not update dragon higher than stage 5', async () => {
        await contractInstance.CreateGreenWelschDragon('1', {from: user1});
        for(let i = 0; i < 4; ++i){
            await timeMachine.advanceTime(3*86400);
            await contractInstance.GetNextStage(0, {from: user1});
        }
        await timeMachine.advanceTime(3*86400);
        try {
            await contractInstance.GetNextStage(0, {from: user1});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
      });
});
});