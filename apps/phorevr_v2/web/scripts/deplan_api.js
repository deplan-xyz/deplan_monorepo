let client;

async function signIn() {
  client = client || new DePlanClient('Hgxbh8HpmWyQaznkFo1tj1xs5gwdHsNtbhU6amaWzbaw');
  const res = await client.signIn();
  return JSON.stringify(res);
}

async function signTransaction(transaction) {
  client = client || new DePlanClient('Hgxbh8HpmWyQaznkFo1tj1xs5gwdHsNtbhU6amaWzbaw');
  const res = await client.signTransaction({ transaction });
  return JSON.stringify(res);
}

async function getKey() {
  const res = await window.deplan.getKey();
  return res.response.key;
}