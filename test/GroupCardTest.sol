// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {GroupCard} from "src/GroupCard.sol";

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
        groupCard = new GroupCard();

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

        assertEq(groupCard.actualSigners(id, 0), signer1);
        assertEq(groupCard.actualSigners(id, 1), signer2);
        // assertEq(groupCard.actualSigners(id, 2), address(0));

        emit log(groupCard.tokenURI(id));
    }

        function testLongMessage() public {
        address[] memory signers = new address[](4);
        signers[0] = mkaddr("karma1");
        signers[1] = mkaddr("karma2");
        signers[2] = mkaddr("karma3");
        signers[3] = mkaddr("karma4");

        vm.prank(cardOwner);
        uint256 id = groupCard.mint("card name", signers);

        vm.prank(mkaddr("karma1"));
        groupCard.etch(id, "this is a message with 50 characters this is a mes", unicode"♥️ karma1");

        vm.prank(mkaddr("karma2"));
        groupCard.etch(id, "this is a message with 64 characters this is a message with 64 c", unicode"♥️ karma2");

        vm.prank(mkaddr("karma3"));
        groupCard.etch(id, "this is a message with 75 characters this is a message with 75 characters t", unicode"♥️ karma3");

        vm.prank(mkaddr("karma4"));
        groupCard.etch(id, "this is a message with 100 characters this is a message with 100 characters this is a message with 1", unicode"♥️ karma4");

        emit log(groupCard.tokenURI(id));
    }
}
