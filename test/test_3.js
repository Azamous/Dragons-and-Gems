const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const DragonManager = artifacts.require('DragonManager');
const name = 'Drakosha';

describe('Testset for Dragon and Gems #3', () => {
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


describe('Dragon Manager & GemsERC20 Test', () => {
    beforeEach(async() => {
        // Create a snapshot
        const snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
      });

      afterEach(async() => await timeMachine.revertToSnapshot(snapshotId));

    it('Should send gems from dragon 0 to dragon 1, create Wyvern dragon and burn 200 gems from dragon1'
        , async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        await contractInstance.transferGems(0, 1, 100, {from: user1});
        let result = await contractInstance.BalanceOfGems(1, {from: user2});
        assert.equal(result, 200);
        await timeMachine.advanceTime(86400);
        await contractInstance.CreatePaidDragon(name, 1, 1, 0, {from: user2});
        result = await contractInstance.ShowDragon(2, {from: user2});
        assert.equal(result[1], 1);
        result = await contractInstance.BalanceOfGems(1, {from: user2});
        assert.equal(result, 0);
    });

    it('Should not let create paid dragon because of lack of gems', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await timeMachine.advanceTime(86400);
        try {
            await contractInstance.CreatePaidDragon(name, 0, 1, 0, {from: user1});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
    });

    it('Should not let not owner of dragon spend gems to create a paid dragon', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        await contractInstance.transferGems(0, 1, 100, {from: user1});
        try {
            await contractInstance.CreatePaidDragon(name, 1, 1, 0, {from: user1});
            assert(true);
        }
        catch(err){
            return;
        }
        assert(false, "The contract did not throw.");
    });

    it('Should spend 200 gems to expand dragon\'s gemsMax for 100', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        await contractInstance.transferGems(0, 1, 100, {from: user1});
        await contractInstance.expandGemsMax(1, {from: user2});
        let result = await contractInstance.BalanceOfGems(1, {from: user2});
        assert.equal(result, 0);
        result = await contractInstance.ShowDragon(1, {from: user2});
        assert.equal(result[2], 300);
    });

    it('Should rename dragon', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user3});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user4});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user5});
        for(let i = 0; i < 2; ++i) {
            await timeMachine.advanceTime(3*86400);
            await contractInstance.GetNextStage(4, {from: user5});
        }
        await contractInstance.transferGems(0, 4, 100, {from: user1});
        await contractInstance.transferGems(1, 4, 100, {from: user2});
        await contractInstance.transferGems(2, 4, 100, {from: user3});
        await contractInstance.transferGems(3, 4, 100, {from: user4}); 
        
        await contractInstance.renameDragon(4, "newName", {from: user5});
        const result = await contractInstance.ShowDragon(4, {from:user1});
        assert.equal(result[0], "newName");
    });

    it('Should show total supply of gems', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user3});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user4});
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user5});
        const result = await contractInstance.totalSupplyGems({from: user1});
        assert.equal(result, 500);
    });

    it('Should approve another address to use 100 gems', async () => {
        await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
        await contractInstance.approveGems(0, user2, 100, {from: user1});
        const result = await contractInstance.allowance(0, user2, {from: user2});
        assert.equal(result, 100);
    });
});
});