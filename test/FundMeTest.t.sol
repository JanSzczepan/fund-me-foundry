// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
   FundMe fundMe;

   function setUp() external {
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
   }

   function testMinimumDollarAmount() public {
      assertEq(fundMe.getMinimumUsd(), 10e18);
   }

   function testOwner() public {
      assertEq(fundMe.getOwner(), msg.sender);
   }
}
