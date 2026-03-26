// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Relics} from "../src/Relics.sol";

/// @title RelicsTest
/// @author SockLove (socklove.eth)
/// @notice Minimal test suite for Relics contract
/// @dev Tests only custom logic - trusts OpenZeppelin dependencies
contract RelicsTest is Test, ERC1155Holder {
    Relics public relics;

    string private constant TEST_URI = "ipfs://bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi";
    uint256 private constant TEST_AMOUNT = 100;

    address private constant USER = address(0xBEEF);

    function setUp() public {
        relics = new Relics();
        vm.label(USER, "User");
    }

    /*//////////////////////////////////////////////////////////////
                            MINT TESTS (UNIT)
    //////////////////////////////////////////////////////////////*/

    function test_Mint_Success() public {
        uint256 id = relics.mint(TEST_URI, TEST_AMOUNT);

        assertEq(id, 1, "First token ID should be 1");
        assertEq(relics.balanceOf(address(this), 1), TEST_AMOUNT, "Balance should be 100");
        assertEq(relics.uri(1), TEST_URI, "URI should match TEST_URI");
    }

    function test_Mint_SequentialIds() public {
        assertEq(relics.mint("ipfs://1", 1), 1, "First mint should return ID 1");
        assertEq(relics.mint("ipfs://2", 1), 2, "Second mint should return ID 2");
        assertEq(relics.mint("ipfs://3", 1), 3, "Third mint should return ID 3");
    }

    function test_Mint_EmitsURIEvent() public {
        vm.expectEmit(true, false, false, true);
        emit IERC1155.URI(TEST_URI, 1);
        relics.mint(TEST_URI, TEST_AMOUNT);
    }

    function test_Mint_RevertWhen_CallerIsNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        relics.mint(TEST_URI, 1);
    }

    function test_Mint_RevertWhen_AmountIsZero() public {
        vm.expectRevert(Relics.MintAmountZero.selector);
        relics.mint(TEST_URI, 0);
    }

    /*//////////////////////////////////////////////////////////////
                            MINT TESTS (FUZZ)
    //////////////////////////////////////////////////////////////*/

    function testFuzz_Mint_AnyAmount(uint128 amount) public {
        vm.assume(amount > 0);
        uint256 id = relics.mint(TEST_URI, amount);

        assertEq(relics.balanceOf(address(this), id), amount, "Balance should match minted amount");
        assertEq(relics.uri(id), TEST_URI, "URI should match TEST_URI");
    }

    function testFuzz_Mint_AnyURI(string calldata uri) public {
        vm.assume(bytes(uri).length < 10000);
        uint256 id = relics.mint(uri, 1);

        assertEq(relics.uri(id), uri, "URI should match minted URI");
        assertEq(relics.balanceOf(address(this), id), 1, "Balance should be 1");
    }
}
