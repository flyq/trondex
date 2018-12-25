var Migrations = artifacts.require("./Migrations.sol");
var Cryptomeetup = artifacts.require("./Exchange.sol");

module.exports = function(deployer) {
    deployer.deploy(Migrations);
    deployer.deploy(Cryptomeetup);
};
