// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
   function convertToEth(
      uint256 _usdAmount,
      AggregatorV3Interface _aggregatorV3Interface
   ) internal view returns (uint256) {
      uint256 ethPrice = getEthPrice(_aggregatorV3Interface);
      uint256 ethAmount = (_usdAmount * 10 ** 18) / ethPrice;

      return ethAmount;
   }

   function getEthPrice(
      AggregatorV3Interface _aggregatorV3Interface
   ) private view returns (uint256) {
      (, int answer, , , ) = _aggregatorV3Interface.latestRoundData();
      uint8 decimals = _aggregatorV3Interface.decimals();

      return uint256(uint256(answer) * 10 ** (18 - decimals));
   }
}
