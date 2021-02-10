const dragonBattle = artifacts.require('DragonBattle');

module.exports = function(deployer) {
  deployer.deploy(dragonBattle);
};