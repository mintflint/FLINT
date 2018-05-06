const MTF = artifacts.require('MTF');

const EVMThrow = 'VM Exception while processing transaction';

function increaseTime (increaseAmount) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: '2.0',
      method: 'evm_increaseTime',
      id: Date.now(),
      params: [increaseAmount]
    }, (err, res) => {
      return err ? reject(err) : resolve(res);
    });
  });
}

function currentEvmTime() {
  const block = web3.eth.getBlock("latest");
  return block.timestamp;
}

require('chai')
  .use(require('chai-as-promised'))
  .should();

let icoStart;
let icoEnd;

async function advanceToIcoStart() {
  const timeDelta = icoStart - currentEvmTime() + 1;
  await increaseTime(timeDelta);
}

async function advanceToIcoEnd() {
  const timeDelta = icoEnd - currentEvmTime() + 1;
  await increaseTime(timeDelta);
}

contract('MTF', function(accounts) {
  beforeEach(async function () {
    icoStart = currentEvmTime() + 1000;
    icoEnd = currentEvmTime() + 10000;
    this.mtf = await MTF.new(icoStart, icoEnd);
  });

  it('Should create MTF with correct decimals, name, etc.', async function () {
    assert.equal(await this.mtf.name(), 'MintFlint Token');
    assert.equal(await this.mtf.symbol(), 'MTF');
    assert.equal(await this.mtf.decimals(), 18);
    assert.equal(await this.mtf.totalSupply(), 0);
    assert.equal(await this.mtf.owner(), accounts[0]);
    assert.equal(await this.mtf.paused(), false);
    assert.equal(await this.mtf.startTime(), icoStart);
    assert.equal(await this.mtf.endTime(), icoEnd);
    assert.equal(await this.mtf.softCapReached(), false);
  });

  it('Should not allow token purchase before ICO is started', async function () {
    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.rejectedWith(EVMThrow);
  });

  it('Should not allow token purchase after ICO is ended', async function () {
    await advanceToIcoEnd();
    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.rejectedWith(EVMThrow);
  });

  it('Should mint new tokens on purchase', async function () {
    await advanceToIcoStart();

    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.fulfilled;

    const tokenBalance = await this.mtf.balanceOf(accounts[0]);
    const totalSupply = await this.mtf.totalSupply();
    const weiReceived = await this.mtf.weiReceived(accounts[0]);
    assert.equal(web3.fromWei(tokenBalance), '100000');
    assert.equal(web3.fromWei(totalSupply), '100000');
    assert.equal(web3.fromWei(weiReceived), '1');
  });

  it('Should allow token transfers only after ICO is finished', async function () {
    await advanceToIcoStart();

    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.fulfilled;
    await this.mtf.transfer(accounts[1], web3.toWei('1')).should.be.rejectedWith(EVMThrow);

    await this.mtf.approve(accounts[1], web3.toWei('1')).should.be.fulfilled;
    await this.mtf.transferFrom(accounts[0], accounts[1], web3.toWei('1'),  { from: accounts[1] }).should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();

    await this.mtf.transfer(accounts[1], web3.toWei('1')).should.be.fulfilled;
    await this.mtf.transferFrom(accounts[0], accounts[1], web3.toWei('1'), { from: accounts[1] }).should.be.fulfilled;
  });

  it('Should set flag when softcap is reached', async function () {
    await advanceToIcoStart();

    await this.mtf.sendTransaction({value: web3.toWei('50')}).should.be.fulfilled;
    assert.equal(await this.mtf.softCapReached(), true);
  });

  it('Should not allow to exceed hardcap', async function () {
    await advanceToIcoStart();

    await this.mtf.sendTransaction({value: web3.toWei('15001')}).should.be.rejectedWith(EVMThrow);
  });

  it('Should allow only owner to pause Sale', async function () {
    await this.mtf.pauseSale({ from: accounts[1] }).should.be.rejectedWith(EVMThrow);
    await this.mtf.pauseSale().should.be.fulfilled;

    // should not allow to pause again
    await this.mtf.pauseSale().should.be.rejectedWith(EVMThrow);
  });

  it('Should allow only owner to resume Sale', async function () {
    await this.mtf.pauseSale().should.be.fulfilled;
    await this.mtf.resumeSale({ from: accounts[1] }).should.be.rejectedWith(EVMThrow);
    await this.mtf.resumeSale().should.be.fulfilled;

    // should not allow to resume again
    await this.mtf.resumeSale().should.be.rejectedWith(EVMThrow);
  });

  it('Should not allow to purchase when Sale is paused', async function () {
    await advanceToIcoStart();
    await this.mtf.pauseSale().should.be.fulfilled;
    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.rejectedWith(EVMThrow);

    await this.mtf.resumeSale().should.be.fulfilled;
    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.fulfilled;
  });

  it('Should allow to refund when softcap is not reached', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('1')}).should.be.fulfilled;

    // should not allow refund if Sale is not ended yet
    await this.mtf.refund().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();
    const balanceBefore = web3.eth.getBalance(accounts[0]);

    // default ganache-cli gas price
    const gasPrice = web3.toWei('100', 'gwei');
    const tx = await this.mtf.refund().should.be.fulfilled;
    const balanceAfter = web3.eth.getBalance(accounts[0]);

    const txFee = web3.toBigNumber(gasPrice).mul(web3.toBigNumber(tx.receipt.gasUsed));
    // check balance
    assert.equal(balanceAfter.sub(balanceBefore).add(txFee).toString(), web3.toWei('1'));

    // should not allow to refund again
    await this.mtf.refund().should.be.rejectedWith(EVMThrow);
  });

  it('Should not allow to refund when softcap is reached', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('51')}).should.be.fulfilled;

    // should not allow refund if Sale is not ended yet
    await this.mtf.refund().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();
    // should not allow to refund
    await this.mtf.refund().should.be.rejectedWith(EVMThrow);
  });

  it('Should allow drain when softcap is reached', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('51')}).should.be.fulfilled;

    // should not allow drain if Sale is not ended yet
    await this.mtf.drain().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();

    const balanceBefore = web3.eth.getBalance(accounts[0]);

    // default ganache-cli gas price
    const gasPrice = web3.toWei('100', 'gwei');
    const tx = await this.mtf.drain().should.be.fulfilled;
    const balanceAfter = web3.eth.getBalance(accounts[0]);

    const txFee = web3.toBigNumber(gasPrice).mul(web3.toBigNumber(tx.receipt.gasUsed));
    // check balance
    assert.equal(balanceAfter.sub(balanceBefore).add(txFee).toString(), web3.toWei('51'));
  });

  it('Should not allow drain when softcap is not reached', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('49.9')}).should.be.fulfilled;

    // should not allow drain if Sale is not ended yet
    await this.mtf.drain().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();

    await this.mtf.drain().should.be.rejectedWith(EVMThrow);
  });

  it('Should mint proper token amount to team', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('15000')}).should.be.fulfilled;

    // should not allow allocate until sale ends
    await this.mtf.teamAllocation().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();

    // should allow only owner to call it
    await this.mtf.teamAllocation({ from: accounts[1] }).should.be.rejectedWith(EVMThrow);

    await this.mtf.teamAllocation().should.be.fulfilled;

    // minting should be finished
    assert.equal(await this.mtf.mintingFinished(), true);

    // total supply must be 2.5 bil
    assert.equal(web3.fromWei(await this.mtf.totalSupply()), '2500000000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0xe29C245aB41041aA8BE0ef9F7dF3FFe6fc684b33')), '18750000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0xa35CA6412aDb2458905620C941705EBf74C48533')), '18750000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x33F12B9A7bF9bd9b3F278f418856f6601381551c')), '18750000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x45687dE002ed612CB47FDDd7BA2F289d1d6390eE')), '18750000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x064440197CF23AEFeb0ff972485368a02Bb30625')), '121875000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x4a8C5Ea0619c40070f288c8aC289ef2f6Bb87cff')), '121875000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x947251376EeAFb0B0CD1bD47cC6056A5162bEaF4')), '121875000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x39A49403eFB1e85F835A9e5dc82706B970D112e4')), '121875000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x733bc7201261aC3c9508D20a811D99179304240a')), '50000000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x4b6716bd349dC65d07152844ed4990C2077cF1a7')), '200000000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0xEf628A29668C00d5C7C4D915F07188dC96cF24eb')), '37500000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0xF28a5e85316E0C950f8703e2d99F15A7c077014c')), '37500000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x0c8C9Dcfa4ed27e02349D536fE30957a32b44a04')), '37500000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x0A86174f18D145D3850501e2f4C160519207B829')), '37500000');

    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728')), '18750000');
    assert.equal(web3.fromWei(await this.mtf.balanceOf('0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5')), '18750000');
  });

  it('Should not allow to call team allocation if soft cap is not reached', async function () {
    await advanceToIcoStart();
    await this.mtf.sendTransaction({value: web3.toWei('49')}).should.be.fulfilled;

    // should not allow allocate until sale ends
    await this.mtf.teamAllocation().should.be.rejectedWith(EVMThrow);

    await advanceToIcoEnd();

    // should allow only owner to call it
    await this.mtf.teamAllocation().should.be.rejectedWith(EVMThrow);
  });
});
