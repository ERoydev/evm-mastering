

## Script execution
- When you try to deploy with a script like `forge script script/DeployBoxV1.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY`, you can encounter an error called:
  
```sh
error: a value is required for '--fork-url <URL>' but none was supplied
```

- That means you should just load the `.env` variables into the terminal like `source .env`