// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DeployFundMe} from '../../script/DeployFundMe.s.sol';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';
import {FundMe} from '../../src/FundMe.sol';
import {HelperConfig} from '../../script/HelperConfig.s.sol';
import {Test, console} from 'forge-std/Test.sol';

contract IntegrationsTest is Test {
   FundMe public fundMe;
   HelperConfig public helperConfig;

   uint256 public constant SEND_VALUE = 0.1 ether;
   uint256 public constant STARTING_USER_BALANCE = 10 ether;
   uint256 public constant GAS_PRICE = 1;

   address public constant USER = address(1);

   function setUp() external {
      DeployFundMe deployFundMe = new DeployFundMe();
      (fundMe, helperConfig) = deployFundMe.run();
      vm.deal(USER, STARTING_USER_BALANCE);
   }

   function testUserCanFundAndOwnerWithdraw() public {
      FundFundMe fundFundMe = new FundFundMe();
      fundFundMe.fundFundMe(address(fundMe));

      WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
      withdrawFundMe.withdrawFundMe(address(fundMe));

      assertEq(address(fundMe).balance, 0);
   }
}
