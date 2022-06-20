// migrating the appropriate contracts
//var ERC721Mintable = artifacts.require("./ERC721Mintable.sol");
var Verifier = artifacts.require("./Verifier.sol");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");

module.exports = function(deployer) {
  deployer.deploy(Verifier, { gas: 5000000 }).then(()=>deployer.deploy(SolnSquareVerifier,Verifier.address, { gas: 5000000 }));
};
