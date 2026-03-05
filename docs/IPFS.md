# Ipfs
https://ipfs.tech/

1. What is it ?
- Code/File/Data -> Hash that data to get unique output that only points to that data
- IPFS Node does that hashing for me
- So we hash our data on that node and then we `pin` that data on that node
- This node is connected to a network of IPFS nodes

So when i ask the network "Hey i want to get that hash", all the nodes are talking to each other until the node that has that hash is found.

So in IPFS nodes doesn't have execution layer, so basically i can just `store` data there.


2. How to work with it ?
Docs: https://ipfs.tech/developers/
Learning Resource: https://updraft.cyfrin.io/courses/advanced-foundry/how-to-create-an-NFT-collection/what-is-ipfs

- Tipically maybe the desktop version is the best.
- I can upload something to `Files` then copy its `CID` and then in browser `ipfs://<Paste_CID_Here>` or i can use ipfs gateway