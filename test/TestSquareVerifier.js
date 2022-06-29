// define a variable to import the Verifier solidity contract generated by Zokrates
var Verifier = artifacts.require('Verifier');
const proof = require('../../zokrates/code/square/proof.json');
console.log(proof.proof.c,proof.proof.a,proof.proof.b,proof.inputs);
contract('TestVerifier', accounts => {
    const account_one = accounts[0];
    describe('check verifier behavior', function () {
        beforeEach(async function () { 
            this.contract = await Verifier.new({from: account_one});
        })
        // Test verification with correct proof
        // - use the contents from proof.json generated from zokrates steps
        it('should accept correct proof', async function () { 
            let result = await this.contract.verifyTx(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            console.log("result:",result);
            assert.equal(result,true,"should be able to accept correct proof");
        })
            
        // Test verification with incorrect proof
        it('should reject incorrect proof', async function () { 
            let result = await this.contract.verifyTx(
                proof.proof.c,
                proof.proof.b,
                proof.proof.a,
                proof.inputs
            );
            console.log("result:",result);
            assert.equal(result,false,"should be able to reject incorrect proof");
        })
    })
});

