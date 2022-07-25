// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Base64 } from "base64/base64.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { Owned } from "solmate/auth/Owned.sol";
import { Strings } from "openzeppelin-contracts/contracts/utils/Strings.sol";


contract GroupCard is ERC721, Owned {
    error Unauthorized();
    error NameTooShort();
    error MessageTooShort();
    error TokenDoesNotExist(uint256 id);
    error CardFinalized();

    event CardSigned(address from, string message, string signedBy);

    struct Message {
        string message;
        string signedBy;
    }

    mapping (uint256 => mapping (address => bool)) public authorizedSigners;
    mapping (uint256 => Message[]) public messages;
    mapping (uint256 => bool) public finalized;
    mapping (uint256 => string) public cardNames;

    uint256 currentId = 1;

    constructor(address _owner)
        Owned(_owner)
        ERC721("GroupCard", "CARD")
    { }

    modifier onlyNFTOwner(uint256 id) {
        require(msg.sender == _ownerOf[id]);
        _;
    }

    modifier tokenExists(uint256 id) {
        if (_ownerOf[id] == address(0)) {
            revert TokenDoesNotExist(id);
        }
        _;
    }


    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(string calldata cardName, address[] calldata signers) public returns (uint256 id) {
        id = currentId;

        _safeMint(msg.sender, id);

        cardNames[id] = cardName;

        uint signersLength = signers.length;
        for (uint256 i = 0; i < signersLength; ) {
            authorizedSigners[id][signers[i]] = true;
            unchecked {
                ++i;
            }
        }

        unchecked {
            ++currentId;
        }
    }

    function burn(uint256 id) public onlyNFTOwner(id) {
        _burn(id);
    }


    /*//////////////////////////////////////////////////////////////
                            SIGNER MGMT LOGIC
    //////////////////////////////////////////////////////////////*/

    function auth(uint256 id, address signer) public onlyNFTOwner(id) {
        authorizedSigners[id][signer] = true;
    }

    function etch(uint256 id, string calldata message, string calldata signedBy) public tokenExists(id) {
        if (msg.sender != _ownerOf[id] && !authorizedSigners[id][msg.sender]) {
            revert Unauthorized();
        }

        if (finalized[id]) {
            revert CardFinalized();
        }

        if (bytes(signedBy).length == 0) {
            revert NameTooShort();
        }

        if (bytes(message).length < 3) {
            revert MessageTooShort();
        }

        messages[id].push(Message(message, signedBy));

        emit CardSigned(msg.sender, message, signedBy);
    }

    function seal(uint256 id, bool _sealed) public onlyNFTOwner(id) {
        finalized[id] = _sealed;
    }


    /*//////////////////////////////////////////////////////////////
                            RENDERING LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 id) public view override tokenExists(id) returns (string memory) {
        Message[] storage _messages = messages[id];
        uint length = _messages.length;

        string memory output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />';
        string[] memory parts = new string[](5);

        for (uint i = 0; i < length; ) {
            parts[0] = string(abi.encodePacked('<text x="10" y="', Strings.toString((2 * i + 1) * 20), '" class="base">'));
            parts[1] = _messages[i].message;
            parts[2] = string(abi.encodePacked('</text><text x="10" y="', Strings.toString((2 * i + 2) * 20), '" class="base">'));
            parts[3] = _messages[i].signedBy;
            parts[4] = '</text>';

            output = string(abi.encodePacked(output, parts[0], parts[1], parts[2], parts[3], parts[4]));
            unchecked {
                ++i;
            }
        }
        output = string(abi.encodePacked(output, '</svg>'));

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', cardNames[id], unicode'", "description": "Group cards for all occasions, signed by your friends ♥️", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }
}
