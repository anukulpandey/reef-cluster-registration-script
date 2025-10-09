import { ApiPromise, WsProvider, Keyring } from '@polkadot/api';

async function main() {
  // Read args
  const [,, MNEMONIC, RPC_URL, TARGET_ADDRESS, AMOUNT] = process.argv;

  if (!MNEMONIC || !RPC_URL || !TARGET_ADDRESS) {
    console.error('Usage: node faucet.js "<MNEMONIC>" "<RPC_URL>" "<TARGET_ADDRESS>" [AMOUNT]');
    process.exit(1);
  }

  // Default amount = 1000 REEF
  const amountToSend = AMOUNT ? BigInt(AMOUNT) * 10n ** 18n : 1000n * 10n ** 18n;

  console.log(`>>> Connecting to node at ${RPC_URL}`);
  const wsProvider = new WsProvider(RPC_URL);
  const api = await ApiPromise.create({ provider: wsProvider });

  const keyring = new Keyring({ type: 'sr25519' });

  // Derive faucet account
  const faucet = keyring.addFromUri(`${MNEMONIC}//2//stash`);
  console.log(`\n>>> Faucet Address: ${faucet.address}`);

  // Fetch faucet balance
  const faucetBal = await api.query.system.account(faucet.address);

  const formatBalance = (bal) => {
    const free = BigInt(bal.data.free.toString());
    return Number(free / 10n ** 18n).toLocaleString() + ' REEF';
  };

  console.log(`>>> Faucet Balance: ${formatBalance(faucetBal)}`);

  const faucetFree = BigInt(faucetBal.data.free.toString());
  if (faucetFree < amountToSend) {
    console.error('❌ Faucet does not have enough balance to send this amount.');
    process.exit(1);
  }

  console.log(`\n>>> Sending ${Number(amountToSend / 10n ** 18n).toLocaleString()} REEF to ${TARGET_ADDRESS}...`);

  const { nonce } = await api.query.system.account(faucet.address);
  const tx = api.tx.balances.transfer(TARGET_ADDRESS, amountToSend);

  const unsub = await tx.signAndSend(faucet, { nonce }, ({ status, dispatchError }) => {
    if (dispatchError) {
      if (dispatchError.isModule) {
        const decoded = api.registry.findMetaError(dispatchError.asModule);
        console.error(`❌ Transaction failed: ${decoded.section}.${decoded.name}`);
      } else {
        console.error(`❌ Transaction failed: ${dispatchError.toString()}`);
      }
      unsub();
      process.exit(1);
    }

    if (status.isInBlock) {
      console.log(`✅ Included in block: ${status.asInBlock}`);
    } else if (status.isFinalized) {
      console.log(`🎯 Finalized in block: ${status.asFinalized}`);
      unsub();
      process.exit(0);
    }
  });
}

main().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
