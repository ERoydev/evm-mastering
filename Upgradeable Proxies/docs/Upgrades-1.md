## OpenZeppelin Foundry Upgrades Library

The `Upgrades` library from OpenZeppelin Foundry Upgrades provides utilities for deploying and managing upgradeable smart contracts using proxy patterns in Foundry.

## Key Features

- **Proxy Deployment**
  - Deploy contracts behind a proxy (Transparent or UUPS) for upgradeability.
  - Example:
    ```solidity
    address proxy = Upgrades.deployTransparentProxy(
        "Box.sol",
        msg.sender,
        abi.encodeCall(Box.initialize, (42))
    );
    ```

- **Initialization**
  - Pass encoded initialization data to set up contract state when deploying the proxy.
  - Example:
    ```solidity
    abi.encodeCall(Box.initialize, (42))
    ```

- **Upgrade Management**
  - Upgrade the implementation behind a proxy.
  - Example:
    ```solidity
    Upgrades.upgradeProxy(
      proxy, 
      "BoxV2.sol", 
      abi.encodeCall(Box.initialize, (12)), 
      msg.sender
    );
    ```

- **Admin and Implementation Queries**
  - Query the proxy for its admin and current implementation addresses.
  - Example:
    ```solidity
    address admin = Upgrades.getAdminAddress(proxy);
    address implementation = Upgrades.getImplementationAddress(proxy);
    ```

## Why Use It?

- **Upgradeability**: Fix bugs or add features to your contracts after deployment.
- **Safety**: Performs upgrade safety checks to prevent breaking changes.
- **Convenience**: Integrates seamlessly with Foundry scripts and tests.

## Example Deployment Script

```solidity
import {Script} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Box} from "../src/Box.sol";

contract DeployBox is Script {
    function run() external {
        vm.startBroadcast();
        address proxy = Upgrades.deployTransparentProxy(
            "Box.sol",
            msg.sender,
            abi.encodeCall(Box.initialize, (42))
        );
        Box box = Box(proxy);
        console.log("Box proxy deployed at:", address(proxy));
        console.log("Initial value:", box.retrieve());
        vm.stopBroadcast();
    }
}
```

## Resources
- [OpenZeppelin Foundry Upgrades Documentation](https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades)
