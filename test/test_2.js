const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const timeMachine = require('ganache-time-traveler');
const truffleAssert = require('truffle-assertions');

const dragonBattle = artifacts.require('DragonTokenERC721');

const name = 'Aleksei';

describe('Testset for Dragon and Gems #2', () => {
    let deployer;
    let user1, user2;
    let contractInstance;
    let snapshotId;

    

    before(async() => {
        [
            deployer,
            user1, user2
        ] = await web3.eth.getAccounts();
        contractInstance = await dragonBattle.new({from: deployer});
    });

    describe('DragonBattle Test', () => {
        beforeEach(async() => {
            // Create a snapshot
            const snapshot = await timeMachine.takeSnapshot();
            snapshotId = snapshot['result'];
          });
    
          afterEach(async() => await timeMachine.revertToSnapshot(snapshotId));

          it('Should attack another dragon', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            const result = await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            expect(result.receipt.status).to.equal(true);
          });

          it('Should not let not owner of a dragon use function', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            await truffleAssert.reverts(
              contractInstance.AttackDragon(0, 1, 1, {from: user2}),
              "You are not an owner of the dragon"
            );
          });

          it('Should let attack after a day of cooldown', async() =>{
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            await timeMachine.advanceTime(86400);
            const result = await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            expect(result.receipt.status).to.equal(true);
          });

          it('Should not let attack before one day passes', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            await timeMachine.advanceTime(20000);
            await truffleAssert.reverts(
              contractInstance.AttackDragon(0, 1, 1, {from: user1}),
              "Dragon is not ready to attack"
            );
          });

          it('Should let dragon stage 5 attack dragon the same stage', async () =>{
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            for (let i = 0; i < 4; ++i) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(0, {from: user1});
                await contractInstance.GetNextStage(1, {from: user2});
            }
            const result = await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            expect(result.receipt.status).to.equal(true);
          });

          it('Should let dragon stage 5 attack dragon stage 3', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            for (let i = 0; i < 4; ++i) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(0, {from: user1});
            }
            for (let j = 0; j < 2; ++j) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(1, {from: user2});
            }
            const result = await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            expect(result.receipt.status).to.equal(true);
          });

          it('Should let dragon stage 1 attack dragon stage 5', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            for (let i = 0; i < 4; ++i) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(1, {from: user2});
            }
            const result = await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            expect(result.receipt.status).to.equal(true);
          });

          it ('Should not let dragon stage 5 attack dragon stage 2', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            for (let i = 0; i < 4; ++i) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(0, {from: user1});
            }
            await timeMachine.advanceTime(3*86400);
            await contractInstance.GetNextStage(1, {from: user2});
            await truffleAssert.reverts(
              contractInstance.AttackDragon(0, 1, 1, {from: user1}),
              "Can't attack smaller dragons"
            )
          });

          it ('Should let dragon win and give him 15 gems', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            await contractInstance.AttackDragon(0, 1, 0, {from: user1});
            const amount1 = await contractInstance.BalanceOfGems(0, {from: user1});
            const amount2 = await contractInstance.BalanceOfGems(1, {from: user2});
            expect(amount1.toNumber()).to.equal(115);
            expect(amount2.toNumber()).to.equal(85);
          });

          it ('Should set and get dragon defence type', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.SetDefence(0, 1, {from: user1});
            const result = await contractInstance.GetDefence(0, {from: user1});
            expect(result.toNumber()).to.equal(1);
          });

          it ('Should change win count for dragon1 and loss count for dragon2 in case of dragon1\'s win', async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            await timeMachine.advanceTime(3*86400);
            await contractInstance.GetNextStage(0, {from: user1});
            await contractInstance.AttackDragon(0, 1, 0, {from: user1});
            const dragon1 = await contractInstance.ShowDragon(0, {from: user1});
            const dragon2 = await contractInstance.ShowDragon(1, {from: user2});
            expect(dragon1[4].toNumber()).to.equal(1);
            expect(dragon2[5].toNumber()).to.equal(1);
          });

          it ('Should change loss count for dragon1 and win count for dragon2 in case of dragon1\'s loss(10% chance this wont happen)',
          async () => {
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user1});
            await contractInstance.CreateGreenWelschDragon(name, 0, {from: user2});
            for (let i = 0; i < 2; i++) {
                await timeMachine.advanceTime(3*86400);
                await contractInstance.GetNextStage(1, {from: user2});
            }
            await contractInstance.AttackDragon(0, 1, 1, {from: user1});
            const dragon1 = await contractInstance.ShowDragon(0, {from: user1});
            const dragon2 = await contractInstance.ShowDragon(1, {from: user2});
            expect(dragon1[5].toNumber()).to.equal(1);
            expect(dragon2[4].toNumber()).to.equal(1);
          });
     });
});