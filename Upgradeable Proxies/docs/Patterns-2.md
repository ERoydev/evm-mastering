

## Beacon proxy
- One logic contract (Implementation Contract)
- Multiple proxies point to the same `implementation` via a Beacon
- Upgrade the Beacon once -> all proxies automatically use the new implementation
- Beacon has an admin
- Many proxies need the same logic (e.g., many token contracts, vault, or clones)

```sh
Beacon ───> Implementation (BoxV1.sol)

Proxy1 ─┐
Proxy2 ─┤──> queries Beacon → delegates calls to BoxV1.sol
Proxy3 ─┘
```

1. Proxy storage
- `_beacon` - stores the address of the beacon to know which to ask for implementation.

2. Call flow
- Proxy executes its fallback function
- Inside the fallback, the proxy calls the beacon (a normal `staticcall`) to get the implementation address.

```solidity
address impl = IBeacon(_beacon).implementation();
```
1. once it has `impl`, the proxy does a `delegatecall` to `impl` with the original calldata:

```solidity
delegatecall(impl, msg.data)
```

- delegatecall means the implementation logic runs in the proxy’s storage context, so each proxy has its own state.
- The beacon is never involved in executing the logic — it only tells the proxy which contract to delegate to.

### Conclusion
A BeaconProxy centralizes the logic contract for multiple proxies. Proxies store only the beacon address, query it for the current implementation, and delegate all execution to that implementation in their own storage. Upgrading the beacon automatically upgrades all associated proxies, making management efficient and safe.