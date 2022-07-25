// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import { GroupCard } from "src/GroupCard.sol";

contract GroupCardTest is Test {
    GroupCard internal groupCard;

    address cardOwner;
    address cardRecipient;
    address signer1;
    address signer2;

    function mkaddr(string memory name) public returns (address addr) {
        addr = address(uint160(uint256(keccak256(bytes(name)))));
        vm.label(addr, name);
    }

    function setUp() public {
        groupCard = new GroupCard(address(this));

        cardOwner = mkaddr("cardOwner");
        cardRecipient = mkaddr("cardRecipient");
        signer1 = mkaddr("signer1");
        signer2 = mkaddr("signer2");
    }

    function testSimple() public {
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        vm.startPrank(cardOwner);
        uint256 id = groupCard.mint("Happy 25th Birthday", signers);
        vm.stopPrank();

        vm.prank(signer1);
        groupCard.etch(id, "Happy Birthday!", unicode"♥️ karma");


        vm.prank(signer2);
        groupCard.etch(id, "Remember to wear your sweater", unicode"👵 mom");

        vm.prank(cardOwner);
        groupCard.safeTransferFrom(cardOwner, cardRecipient, id);

        emit log(groupCard.tokenURI(id));
    }
}
