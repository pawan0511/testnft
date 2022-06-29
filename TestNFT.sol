 // SPDX-License-Identifier: MIT
     pragma solidity ^0.8.7;

     import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
     import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
     import "@openzeppelin/contracts/access/Ownable.sol";
     import "@openzeppelin/contracts/utils/Strings.sol";
     import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
     import "@openzeppelin/contracts/utils/Counters.sol";
  
   library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}


      contract TestNFT is ERC721URIStorage, Ownable {
    //using Strings for uint256;
    event Minted(uint256 tokenId);
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;

    string v;
    uint256 a;
    uint256 b;
    uint256 c;
    uint256 d;
    uint256 e;
    uint256 f;
    uint256 g;

    constructor() ERC721("PTestNFT", "PTN") {}

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        //string memory baseURL = "data:image/svg+xml;base64,";
        string memory baseURL = "ipfs://";
        //string memory svgBase64Encoded = Base64.encode(bytes(svg));
        string memory svgBase64Encoded = svg;
        /* 
        abi.encodePacked is a function provided by Solidity which
        is used to concatenate two strings, similar to a `concat()`
        function in JavaScript.
        */
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }


    function simplifiedFormatTokenURI(string memory imageURI, string memory _v, uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e, uint256 _f, uint256 _g)
    public
    pure  
    returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "', 
                _v,'", "description": "A simple SVG based on-chain NFT", "image":"', 
                  imageURI, 
                '", "attributes": [ { "trait_type": "A", "value": "', uint2str(_a),'" },  { "trait_type": "B", "value": "', uint2str(_b),'" },  { "trait_type": "C", "value": "', uint2str(_c),'" },  { "trait_type": "D", "value": "', uint2str(_d),'" },  { "trait_type": "E", "value": "', uint2str(_e),'" }, { "trait_type": "F", "value": "', uint2str(_f),'" },  { "trait_type": "G", "value": "', uint2str(_g),'" } ]}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }


    function mint(string memory svg, string memory _v, uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e, uint256 _f, uint256 _g) public {
    /* Encode the SVG to a Base64 string and then generate the tokenURI */
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = simplifiedFormatTokenURI(imageURI, _v, _a, _b, _c, _d, _e, _f, _g);

        /* Increment the token id everytime we call the mint function */
        _tokenIds.increment();
        
        uint256 newItemId = _tokenIds.current();

        /* Mint the token id and set the token URI */
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        /* Emit an event that returns the newly minted token id */
        emit Minted(newItemId);
    }
     function walletOfOwner(address contractAddress, address owner_) public view returns (uint256[] memory){

    uint256 _tokenCount = IERC721Enumerable(contractAddress).balanceOf(owner_);
    uint256[] memory _tokens = new uint256[](_tokenCount);
    for(uint256 i=0; i < _tokenCount; i++){
        _tokens[i] = (IERC721Enumerable(contractAddress).tokenOfOwnerByIndex(owner_, i));
    }
       return _tokens;
        }
    
  
      }

