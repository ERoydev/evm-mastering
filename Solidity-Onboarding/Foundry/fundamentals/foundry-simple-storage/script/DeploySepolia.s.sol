// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Script, console} from "forge-std/Script.sol";


/*
Deploy with the following command in terminal:
    - `forge script script/deploy/DeploySepolia.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast`
    - Make sure you have set SEPOLIA_RPC => https://sepolia.infura.io/v3/....from infura or alchemy code here 
    - And Private Key for example exported from your metamask => Account details
*/


// Example to deploy on sepolia with two contracts that are linked together


// contract DeploySepolia is Script {
//     ShipmentManager public shipmentManager;
//     ShipmentToken public shipmentToken;
//     address adminAddress = vm.envAddress("ADMIN_ADDRESS");  // The DEFAULT_ADMIN owner of this contract

//     function run() external {
//         vm.startBroadcast();
        
//         ShipmentManager manager = new ShipmentManager();

//         ShipmentToken token = new ShipmentToken();

//         manager.initialize(adminAddress, address(token), adminAddress);
//         token.initialize(address(manager));

//         console.log("SHIPMENT_MANAGER_CONTRACT_ADDR=%s", address(manager));
//         console.log("SHIPMENT_TOKEN_CONTRACT_ADDR=%s", address(token));

//         vm.stopBroadcast();
//     }
// }