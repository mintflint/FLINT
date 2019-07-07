const FLINT = artifacts.require('FLINT');

const EVMThrow = 'VM Exception while processing transaction';

require('chai')
  .use(require('chai-as-promised'))
  .should();

contract('FLINT', function(accounts) {
  beforeEach(async function () {
    this.flint = await FLINT.new();
  });

  it('Should create FLINT with correct decimals, name, etc.', async function () {
    assert.equal(await this.flint.name(), 'MintFlint Token');
    assert.equal(await this.flint.symbol(), 'FLINT');
    assert.equal(await this.flint.decimals(), 18);
    assert.equal(await this.flint.totalSupply(), 0);
    assert.equal(await this.flint.owner(), accounts[0]);
    assert.equal(await this.flint.devFund(), '0xD674719E383Dab1626c83a5D5A1956dA2F5b3b05');
    assert.equal(await this.flint.sambhav(), '0xcFc43257606C6a642d9438dCd82bf5b39A17dbAB');
    assert.equal(await this.flint.pondsea(), '0xEf628A29668C00d5C7C4D915F07188dC96cF24eb');
    assert.equal(await this.flint.austin(), '0x6801c3f0BdCA16E0B3206b8c804e94F5d01cA835');
    assert.equal(await this.flint.artem(), '0x3C7AAD7b693E94f13b61d4Be4ABaeaf802b2E3B5');
    assert.equal(await this.flint.kiran(), '0x3a312D7D725BB257b725c2EC5F945304E9EcF17B');
  });

  it('Should mintStandard properly', async function () {
    let amount = web3.utils.toWei('1');
    // should not allow to call mint by non-owner
    await this.flint.mintStandard(accounts[1], amount, {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should mint
    await this.flint.mintStandard(accounts[1], amount).should.be.fulfilled;
    // check the balance
    let balance = await this.flint.balanceOf(accounts[1]);
    assert.equal(balance.toString(), balance);
  });

  it('Should mintSpecial properly', async function () {
    let amount = web3.utils.toWei('1000000000');
    // should not allow to call mint by non-owner
    await this.flint.mintSpecial(accounts[1], amount, {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should mint
    await this.flint.mintSpecial(accounts[1], amount).should.be.fulfilled;
    // check the balance of minted address
    let balance = await this.flint.balanceOf(accounts[1]);
    assert.equal(balance.toString(), amount);
    let totalSupply = await this.flint.totalSupply();
    // dev fund should receive 21.9152% of new total supply
    let devFundBal = await this.flint.balanceOf(await this.flint.devFund());
    assert.equal(devFundBal, totalSupply * 219152 / 1000000);
    // Sambhav should receive 20.06% of new total supply
    let sambhavBal = await this.flint.balanceOf(await this.flint.sambhav());
    assert.equal(sambhavBal, totalSupply * 2006 / 10000);
    // Pondsea should receive 6.0174% of new total supply
    let pondseaBal = await this.flint.balanceOf(await this.flint.pondsea());
    assert.equal(pondseaBal, totalSupply * 60174 / 1000000);
    // Austin should receive 1% of new total supply
    let austinBal = await this.flint.balanceOf(await this.flint.austin());
    assert.equal(austinBal.toString(), totalSupply / 100);
    // Artem should receive 1% of new total supply
    let artemBal = await this.flint.balanceOf(await this.flint.artem());
    assert.equal(artemBal.toString(), totalSupply / 100);
    // Kiran should receive 0.0074% of new total supply
    let kiranBal = await this.flint.balanceOf(await this.flint.kiran());
    assert.equal(kiranBal.toString(), totalSupply * 74 / 1000000);
  });

  it('Should finishMint properly', async function () {
    let amount = web3.utils.toWei('100000');
    // should not allow to call finishMint by non-owner
    await this.flint.finishMint({from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to finish the mint
    await this.flint.finishMint().should.be.fulfilled;

    // should not allow mint after finish
    await this.flint.mintSpecial(accounts[1], amount).should.be.rejectedWith(EVMThrow);
    await this.flint.mintStandard(accounts[1], amount).should.be.rejectedWith(EVMThrow);
  });

  it('Should set new dev fund address', async function () {
    // should not allow to call by non-owner
    await this.flint.setDevFund(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setDevFund(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.devFund());
  });

  it('Should set new Sambhav address', async function () {
    // should not allow to call by non-owner
    await this.flint.setSambhav(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setSambhav(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.sambhav());
  });

  it('Should set new Pondsea address', async function () {
    // should not allow to call by non-owner
    await this.flint.setPondsea(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setPondsea(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.pondsea());
  });

  it('Should set new Austin address', async function () {
    // should not allow to call by non-owner
    await this.flint.setAustin(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setAustin(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.austin());
  });

  it('Should set new Artem address', async function () {
    // should not allow to call by non-owner
    await this.flint.setArtem(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setArtem(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.artem());
  });

  it('Should set new Kiran address', async function () {
    // should not allow to call by non-owner
    await this.flint.setKiran(accounts[1], {from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow owner to set
    await this.flint.setKiran(accounts[1]).should.be.fulfilled;

    // should not allow mint after finish
    assert.equal(accounts[1], await this.flint.kiran());
  });

  it('Should pause', async function () {
    await this.flint.mintStandard(accounts[0], web3.utils.toWei('100000'));
    await this.flint.approve(accounts[1], web3.utils.toWei('100000'));
    // should not allow to call by non-pauser
    await this.flint.pause({from: accounts[1]}).should.be.rejectedWith(EVMThrow);
    // should allow pauser to pause
    await this.flint.pause().should.be.fulfilled;
    // should disallow transfer when paused
    await this.flint.transfer(accounts[1], web3.utils.toWei('1')).should.be.rejectedWith(EVMThrow);
    // should disallow transferFrom when paused
    await this.flint.transferFrom(accounts[1], accounts[1], web3.utils.toWei('1')).should.be.rejectedWith(EVMThrow);
    // should disallow mintStandard when paused
    await this.flint.mintStandard(accounts[0], web3.utils.toWei('100000')).should.be.rejectedWith(EVMThrow);
    // should disallow mintSpecial when paused
    await this.flint.mintSpecial(accounts[0], web3.utils.toWei('100000')).should.be.rejectedWith(EVMThrow);
  });
});
