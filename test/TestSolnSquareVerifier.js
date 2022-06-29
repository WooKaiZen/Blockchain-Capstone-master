var Verifier = artifacts.require('Verifier');
var SolnSquareVerifier = artifacts.require('SolnSquareVerifier');
const proof = require('../../zokrates/code/square/proof.json');

contract('TestSolnSquareVerifier', accounts => {
    const account_one = accounts[0];
    const account_two = accounts[1];

    describe('check solution behavior', function () {
        before(async function () { 
            let verifier = await Verifier.new({from: account_one});
            this.contract = await SolnSquareVerifier.new(verifier.address,"Real Estate Token","RET");
        })
        // Test if an ERC721 token can be minted for contract - SolnSquareVerifier
        it('should be able to mint token and add solution', async function () { 
            let minted = true;
            let result;
            /*this.contract.mintToken (
                1,
                account_two,
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );*/
            /*let SolAddress = await this.contract.getSolutionAddress(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            console.log(SolAddress);
            let SolExists = await this.contract.doesSolutionExist(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            console.log(SolExists);*/
            try {
                result = await this.contract.mintToken (
                    1,
                    account_two,
                    proof.proof.a,
                    proof.proof.b,
                    proof.proof.c,
                    proof.inputs
                );
            } catch(e) {
                minted = false;
            }
            assert.equal(minted,true,"should be able to mint token");
            console.log(result.logs[0].event);
            assert.equal(result.logs[0].event, 'SolutionAdded', 'should be able to add solution')
        })

        // Test if a new solution can be added for contract - SolnSquareVerifier
        it('should not be able to mint a token using an already used solution', async function () { 
            let minted = true;
            // follow-up on previous test
            //let contractSolutions = await this.contract.solutions.call()
            //assert.equal(contractSolutions.length,1,"should be able to add solution");
            /*let SolAddress = await this.contract.getSolutionAddress(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            console.log(SolAddress);
            let SolExists = await this.contract.doesSolutionExist(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            console.log(SolExists);*/
            try {
                let result = await this.contract.mintToken (
                    2,
                    account_two,
                    proof.proof.a,
                    proof.proof.b,
                    proof.proof.c,
                    proof.inputs
                );
            } catch(e) {
                minted = false;
            }
            assert.equal(minted,false,"should not be able to mint token using an already used solution");                     
        })
    })
});