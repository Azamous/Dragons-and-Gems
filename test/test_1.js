const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const DragonManager = artifacts.require('DragonManager');

const name = 'Drakosha';

describe('Testset for Dragon and Gems #1', () => {
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


describe('Dragon Helper & Manager Test', () => {
    beforeEach(async() => {
        // Create a snapshot
        const snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
      });

      afterEach(async() => await timeMachine.revertToSnapshot(snapshotId));

      it('Should create dragon type 0 and show him', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        const result = await contractInstance.ShowDragon(0, {from: user1});
        expect(result[0]).to.equal(name);
        expect(result[1].toNumber()).to.equal(0);
        expect(result[2].toNumber()).to.equal(200);
        expect(result[3].toNumber()).to.equal(1);
        expect(result[4].toNumber()).to.equal(0);
        expect(result[5].toNumber()).to.equal(0);
      });

      it('Should show all of owner\'s dragons', async () => {
         await contractInstance.CreateGreenWelschDragon('1', 0, {from: user2});
         await timeMachine.advanceTime(86400);
         await contractInstance.CreateGreenWelschDragon('2', 0, {from: user2});
         let result = await contractInstance.ShowOwnerDragons(user2, {from: user2});
         expect(result[0].toNumber()).to.equal(0);
         expect(result[1].toNumber()).to.equal(1);
      });

      it('Should create another dragon after 1 day', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await timeMachine.advanceTime(86400);
        await contractInstance.CreateGreenWelschDragon('123', 0, {from: user1});
        const result = await contractInstance.ShowDragon(1, {from: user1});
        expect(result[0]).to.equal('123');
      });

      it('Should not allow to create another dragon until 1 day passes', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await truffleAssert.reverts(
          contractInstance.CreateGreenWelschDragon(name, 0, {from: user1}),
          "You have to wait 1 day in order to create a new dragon"
          );
      });

      it('Should update dragon and expand his gemsMax for 200 gems', async () => {
        await contractInstance.CreateGreenWelschDragon('1', 0, {from: user2});
        await timeMachine.advanceTime(3*86400);
        await contractInstance.GetNextStage(0, {from: user2});
        const result = await contractInstance.ShowDragon(0, {from: user2});
        expect(result[3].toNumber()).to.equal(2);
        expect(result[2].toNumber()).to.equal(400);
      });

      it ('Should not let another person update dragon', async () => {
        await contractInstance.CreateGreenWelschDragon('1', 0, {from: user1});
        await timeMachine.advanceTime(3*86400);
        await truffleAssert.reverts(
          contractInstance.GetNextStage(0, {from: user2}),
          "You are not an owner of the dragon"
        );
      });

      it ('Should not let update dragon until 3 days pass', async () => {
        await contractInstance.CreateGreenWelschDragon('1', 0, {from: user1});
        await timeMachine.advanceTime(2*86400);
        await truffleAssert.reverts(
          contractInstance.GetNextStage(0, {from: user1}),
          "Dragon is not ready to grow"
        );
      });

      it('Should not update dragon higher than stage 5', async () => {
        await contractInstance.CreateGreenWelschDragon('1', 0, {from: user1});
        for(let i = 0; i < 4; ++i){
            await timeMachine.advanceTime(3*86400);
            await contractInstance.GetNextStage(0, {from: user1});
        }
        await timeMachine.advanceTime(3*86400);
        await truffleAssert.reverts(
          contractInstance.GetNextStage(0, {from: user1}),
          "Dragon has reached the maximum stage"
        );
      });
});
});