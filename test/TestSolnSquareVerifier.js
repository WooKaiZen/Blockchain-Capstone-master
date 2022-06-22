var SquareVerifier = artifacts.require('SquareVerifier');
var SolnSquareVerifier = artifacts.require('SolnSquareVerifier');
const proof = require('../../zokrates/code/square/proof.json');

contract('TestSolnSquareVerifier', accounts => {
    const account_one = accounts[0];
    const account_two = accounts[1];

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            const verifier = await SquareVerifier.new({from: account_one});
            this.contract = await SolnSquareVerifier.new(verifier.address,"Real Estate Token","RET",{from: account_one});
            // Test if an ERC721 token can be minted for contract - SolnSquareVerifier
            it('should be able to mint token', async function () { 
                let minted = true;
                try {
                    this.contract.mintToken (
                        1,
                        account_two,
                        proof.a,
                        proof.b,
                        proof.c,
                        proof.inputs
                    );
                } catch(e) {
                    minted = false;
                }
                assert.equal(minted,true,"should be able to mint token");
            })

            // Test if a new solution can be added for contract - SolnSquareVerifier
            it('should be able to add new solution to the contract', async function () { 
                // follow-up on previous test
                let contractSolutions = await this.contract.solutions.call()
                assert.equal(contractSolutions.length,1,"should be able to add solution");
            })
        })
    })
});
