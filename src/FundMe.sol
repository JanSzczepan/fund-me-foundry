// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import {PriceConverter} from './PriceConverter.sol';

error FundMe__OnlyOwner();
error FundMe__TransferFailed();
error FundMe_NotEnoughEth();

contract FundMe {
   using PriceConverter for uint256;

   address[] private s_funders;
   mapping(address funder => uint256 amount) private s_addressToAmountFunded;

   address private immutable i_owner;
   AggregatorV3Interface private immutable i_aggregatorV3Interface;

   uint256 private constant MINIMUM_USD = 10e18;

   constructor(address _aggregatorV3InterfaceAddress) {
      i_owner = msg.sender;
      i_aggregatorV3Interface = AggregatorV3Interface(_aggregatorV3InterfaceAddress);
   }

   modifier onlyOwner() {
      if (msg.sender != i_owner) {
         revert FundMe__OnlyOwner();
      }

      _;
   }

   modifier minimumUsd() {
      if (MINIMUM_USD.convertToEth(i_aggregatorV3Interface) > msg.value) {
         revert FundMe_NotEnoughEth();
      }

      _;
   }

   function fund() public payable minimumUsd {
      s_funders.push(msg.sender);
      s_addressToAmountFunded[msg.sender] = msg.value;
   }

   function withdraw() public onlyOwner {
      uint256 fundersLength = s_funders.length;

      for (uint256 i = 0; i < fundersLength; i++) {
         s_addressToAmountFunded[s_funders[i]] = 0;
      }

      s_funders = new address[](0);

      (bool isSuccess, ) = payable(i_owner).call{value: address(this).balance}('');

      if (!isSuccess) {
         revert FundMe__TransferFailed();
      }
   }

   fallback() external payable {
      fund();
   }

   receive() external payable {
      fund();
   }

   function getFunder(uint256 _index) external view returns (address) {
      return s_funders[_index];
   }

   function getFunderAmountFunded(address _funderAddress) external view returns (uint256) {
      return s_addressToAmountFunded[_funderAddress];
   }

   function getOwner() external view returns (address) {
      return i_owner;
   }

   function getPriceFeed() external view returns (AggregatorV3Interface) {
      return i_aggregatorV3Interface;
   }

   function getMinimumUsd() external pure returns (uint256) {
      return MINIMUM_USD;
   }
}
