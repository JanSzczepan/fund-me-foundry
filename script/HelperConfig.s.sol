// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from '../lib/forge-std/src/Script.sol';
import {MockV3Aggregator} from '../test/mock/MockV3Aggragator.sol';

contract HelperConfig is Script {
   struct NetworkConfig {
      address priceFeed;
   }

   NetworkConfig public activeNetworkConfig;

   uint8 public constant DECIMALS = 8;
   int256 public constant INITIAL_PRICE = 2000e8;

   event HelperConfig__CreatedMockPriceFeed(address priceFeed);

   constructor() {
      if (block.chainid == 80001) {
         activeNetworkConfig = getMumbaiEthConfig();
      } else {
         activeNetworkConfig = getOrCreateAnvilEthConfig();
      }
   }

   function getMumbaiEthConfig() public pure returns (NetworkConfig memory mumbaiNetworkConfig) {
      mumbaiNetworkConfig = NetworkConfig({priceFeed: 0x0715A7794a1dc8e42615F059dD6e406A6594651A});
   }

   function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
      if (activeNetworkConfig.priceFeed != address(0)) {
         return activeNetworkConfig;
      }

      vm.startBroadcast();
      MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
      vm.stopBroadcast();

      emit HelperConfig__CreatedMockPriceFeed(address(mockPriceFeed));

      anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
   }
}
