const dragonAndGems = artifacts.require('DragonTokenERC721');


module.exports = function(deployer) {
 deployer.deploy(dragonAndGems);
};