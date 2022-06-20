pragma solidity >=0.4.21 <0.6.0;
import './ERC721Mintable.sol';
//import './Verifier.sol';



// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable {

    Verifier verifier;
// TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 tokenId;
        address to;
    }

// TODO define an array of the above struct
    Solution[] solutions;

// TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) uniqueSolutions;


// TODO Create an event to emit when a solution is added
    event SolutionAdded(address from, uint256 tokenId);//TODO:check

    constructor(address VerifierAddress) ERC721Mintable("RealEstateToken","RET") public {
        verifier = Verifier(VerifierAddress);
    }

// TODO Create a function to add the solutions to the array and emit the event
    function addSolution(uint256 tokenId, address to, bytes32 key) internal {
        Solution memory solution = Solution(tokenId,to);
        uniqueSolutions[key] = solution;
        solutions.push(solution);
        emit SolutionAdded(msg.sender,solutions.length);
    }


// TODO Create a function to mint new NFT only after the solution has been verified

//  - make sure you handle metadata as well as tokenSupply
    function mintToken (
        uint256 tokenId,
        address to,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input
    ) public {
        //  - make sure the solution is unique (has not been used before)
        bytes32 key = keccak256(abi.encodePacked(a,b,c,input));
        require(uniqueSolutions[key].to == address(0),"Solution already submitted"); //TODO: check
        require(verifier.verifyTx(a,b,c,input),"Solution is incorrect");
        addSolution(tokenId,to,key);
        super.mint(to,tokenId);
    }
}


// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract Verifier {
    function verifyTx(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory inputs) public view returns (bool);
}

  


























