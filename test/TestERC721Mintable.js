var ERC721Mintable = artifacts.require('ERC721Mintable');

contract('TestERC721Mintable', accounts => { // TODO: check, modify

    const account_one = accounts[0];
    const account_two = accounts[1];
    const account_three = accounts[2];

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            this.contract = await ERC721Mintable.new("RealEstateToken","RET",{from: account_one});

            // TODO: mint multiple tokens
            await this.contract.mint(account_two,1,{from: account_one});
            await this.contract.mint(account_two,2,{from: account_one});
            //this.contract.mint(account_two,3,{from: account_one});
        })
        
        it('should return total supply', async function () { 
            let ts = await this.contract.totalSupply();
            assert.equal(ts.toNumber(),2,"should be able to check total supply");
        })

        it('should get token balance', async function () { 
            let balance = await this.contract.balanceOf(account_two);
            assert.equal(balance.toNumber(),2,"should be able to get an account's token balance");
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
            let tokenUri = await this.contract.tokenURI(1);
            assert.equal(tokenUri,"https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1","should return correct token uri");
        })

        it('should transfer token from one owner to another', async function () { 
            await this.contract.transferFrom(account_two,account_three,2,{from: account_two}); 
            let newOwner = await this.contract.ownerOf(2);
            assert.equal(newOwner,account_three,"should be able to transfer token to another owner");
        })
    });

    describe('have ownership properties', function () {
        beforeEach(async function () { 
            this.contract = await ERC721Mintable.new("RealEstateToken","RET",{from: account_one});
        })

        it('should fail when minting when address is not contract owner', async function () { 
            let denied = false;
            try {
                await this.contract.mint(account_two,3,{from: account_two});
            } catch(e) {
                denied = true;
            }
            assert.equal(denied,true,"only owner should be able to mint new token");
        })
        
        it('should return contract owner', async function () { 
            let owner = await this.contract.getOwner();
            assert.equal(owner,account_one,"should be able to get contract owner");
        })

    });
})
