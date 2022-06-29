// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
/*Permission is hereby granted, free of charge, to any perso
n obtaining a copy of this software and associated documentat
ion files (the "Software"), to deal in the Software without r
estriction, including without limitation the rights to use, c
opy, modify, merge, publish, distribute, sublicense, and/or s
ell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following con
ditions:
// The above copyright notice and this permission notice shal
l be included in all copies or substantial portions of the So
ftware.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WA
RRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
 AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRI
GHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILI
TY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARIS
ING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE US
E OR OTHER DEALINGS IN THE SOFTWARE.*/
pragma solidity >=0.4.24;//^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]        
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {   
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {   
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success :=staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work     
            switch success case 0 { invalid() }
        }
        require(success);
    }
/// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work     
            switch success case 0 { invalid() }
        }
        require (success);
    }


    /// @return the result of computing the pairing check    
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1       
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work     
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x0688bd5f7dcbaa8804ddf3070af49b8dec6c80d812d6698c29e66e1acb5b863d), 
                    uint256(0x16ee71919fa91502d13e54efab97ebd09cdff3fb6f97abc18eae8838efe8865d));
        vk.beta = Pairing.G2Point([uint256(0x1681b6de323dcfb44a16e1f5c82f83782f12cc0178e95ed5ac13898a0d597756), 
                    uint256(0x2a7e63e054e861586cda35e265136afcdf9af6a766375fee45c00d25d664e9f3)], 
                    [uint256(0x0bcd3e58d9000fa5b4b5b42201ff313aa0d7438bf85295416e708b42f0704acf), 
                    uint256(0x2342827aa1869fed92b001607f1c9c0397cbecfa0f82c4273682197bd1af52e3)]);
        vk.gamma = Pairing.G2Point([uint256(0x1df42c8026de2cfa33502a8d62861e8d9f64ce67d38b9b6e2d7ec8bb5bcf8e5e), 
                    uint256(0x219d5a0717dd5c6937820972e3c96a048b32d5dd730e00427fae0df17e5cb3b8)], 
                    [uint256(0x06b7c8ddb12535f13fa109126029a76b73619c53f50363dfecf42a4603f92311), 
                    uint256(0x0f1b1d06977e2e552e7d60900cad54340aa8796d979f9ad33f5a4a689f67c1cc)]);
        vk.delta = Pairing.G2Point([uint256(0x26dc65a26fa5e3e1f8514cb30026739e76c240347a38751a45f35b4636f59706), 
                    uint256(0x07e4c21b738cb9a5bee2d01bba57f4355f7f153fec5c331163618f2a6517e119)], 
                    [uint256(0x06fbb917d5d5ef0972d0fa1a096d3428ca89919a1e9b5c2d678635418124ecf9), 
                    uint256(0x22006d422eda14ae4f4cc7343e767d471502dc2d683dbf272418406b22542726)]);
        vk.gamma_abc = new Pairing.G1Point[](2);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x16355cafc980a433a3f3c7fd278fa4e9ddae7f6ed3ef7dd7c6c7c49a79c7bbfb), 
        uint256(0x2499237fccbfd572d2e6bb831dceeb4c555f444046f452998cfbc1e941cd78d6));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2c907e114c43f1a403f54164ba33550cfd2eeef8506133861ee45440edf2e843), 
        uint256(0x11a930d16998e27324baca5b6b00ac55ebba7c487b12a1857345cd06c8f4f63a));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;       
        VerifyingKey memory vk = verifyingKey();
        require(input.length+1== vk.gamma_abc.length);  
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0); 
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);      
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input
        ) public view returns (bool r) {
        
        Proof memory proof;
        proof.a = Pairing.G1Point(a[0],a[1]);
        proof.b = Pairing.G2Point([b[0][0],b[0][1]],[b[1][0],b[1][1]]);
        proof.c = Pairing.G1Point(c[0],c[1]);

        uint[] memory inputValues = new uint[](input.length);

        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
        
        return false;
    }
}
