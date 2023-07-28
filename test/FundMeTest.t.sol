// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from '../lib/forge-std/src/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
   FundMe public fundMe;

   uint256 public constant STARTING_BALANCE = 10 ether;
   uint256 public constant SEND_VALUE = 0.1 ether;

   address public constant USER = address(1);

   modifier fund() {
      vm.prank(USER);
      fundMe.fund{value: SEND_VALUE}();
      assert(address(fundMe).balance > 0);

      _;
   }

   function setUp() external {
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(USER, STARTING_BALANCE);
   }

   function testMinimumDollarAmount() public {
      assertEq(fundMe.getMinimumUsd(), 10e18);
   }

   function testOwner() public {
      assertEq(fundMe.getOwner(), msg.sender);
   }

   function testFundFailsWithoutEnoughEth() public {
      bytes4 selector = bytes4(keccak256('FundMe_NotEnoughEth()'));
      vm.expectRevert(abi.encodeWithSelector(selector));
      fundMe.fund();
   }

   function testFundUpdatedFundersArray() public fund {
      address funder = fundMe.getFunder(0);
      assertEq(funder, USER);
   }

   function testFundUpdatesFundedDataStructure() public fund {
      uint256 amountFunded = fundMe.getFunderAmountFunded(USER);
      assertEq(amountFunded, SEND_VALUE);
   }

   function testWithdrawFailsIfNotOwner() public fund {
      bytes4 selector = bytes4(keccak256('FundMe__OnlyOwner()'));

      vm.prank(USER);
      vm.expectRevert(abi.encodeWithSelector(selector));
      fundMe.withdraw();
   }

   function testWithdrawFromASingleFunder() public fund {
      address owner = fundMe.getOwner();
      uint256 ownerStartingBalance = owner.balance;
      uint256 contractStartingBalance = address(fundMe).balance;

      vm.startPrank(owner);
      fundMe.withdraw();
      vm.stopPrank();

      uint256 ownerEndingBalance = owner.balance;
      uint256 contractEndingBalance = address(fundMe).balance;

      assertEq(contractEndingBalance, 0);
      assertEq(ownerStartingBalance + contractStartingBalance, ownerEndingBalance);
   }

   function testWithdrawFromMultipleFunders() public {
      address owner = fundMe.getOwner();
      uint160 fundersAmount = 10;
      uint160 funderStartingIndex = 1;

      for (uint160 i = funderStartingIndex; i < fundersAmount + funderStartingIndex; i++) {
         hoax(address(i), STARTING_BALANCE);
         fundMe.fund{value: SEND_VALUE}();
      }

      uint256 ownerStartingBalance = owner.balance;
      uint256 contractStartingBalance = address(fundMe).balance;

      vm.startPrank(owner);
      fundMe.withdraw();
      vm.stopPrank();

      uint256 ownerEndingBalance = owner.balance;
      uint256 contractEndingBalance = address(fundMe).balance;

      assertEq(contractEndingBalance, 0);
      assertEq(ownerStartingBalance + contractStartingBalance, ownerEndingBalance);
      assertEq(fundersAmount * SEND_VALUE, fundMe.getOwner().balance - ownerStartingBalance);
   }
}
