const dragonManager = artifacts.require('DragonManager');

module.exports = function(deployer) {
  deployer.deploy(dragonManager);
};