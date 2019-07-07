pragma solidity ^0.5.0;
import './MintableToken.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract FLINT is MintableToken, Ownable, Pausable {

    using SafeMath for uint256;
    //The name of the  token
    string public constant name = "MintFlint Token";
    //The token symbol
    string public constant symbol = "FLINT";
    //The precision used in the balance calculations in contract
    uint8 public constant decimals = 18;
    // DEV fund address that holds the 21.9152% of total FLINT supply
    address public devFund = 0xD674719E383Dab1626c83a5D5A1956dA2F5b3b05;
    // Sambhav's address that holds the 20.06% of total FLINT supply
    address public sambhav = 0xcFc43257606C6a642d9438dCd82bf5b39A17dbAB;
    // Pondsea's address that holds the 6.0174% of total FLINT supply
    address public pondsea = 0xEf628A29668C00d5C7C4D915F07188dC96cF24eb;
    // Austin's address that holds the 1% of total FLINT supply
    address public austin = 0x6801c3f0BdCA16E0B3206b8c804e94F5d01cA835;
    // Artem's address that holds the 1% of total FLINT supply
    address public artem = 0x3C7AAD7b693E94f13b61d4Be4ABaeaf802b2E3B5;
    // Kiran's address that holds the 0.0074% of total FLINT supply
    address public kiran = 0x3a312D7D725BB257b725c2EC5F945304E9EcF17B;

    constructor() public {

    }

    // Standard mint that doesn't increase the balance of "special" holders
    function mintStandard(address _to, uint256 _amount) public whenNotPaused onlyOwner canMint returns (bool) {
        return mint(_to, _amount);
    }

    // Standard mint that increase the balance of "special" holders according to their total share of FLINT tokens
    function mintSpecial(address _to, uint256 _amount) public whenNotPaused onlyOwner canMint returns (bool) {
        // to keep the proper share of special addresses we should calculate the resulting_amount of total supply increase
        // to do this we should mul the amount by 2, total special holders share is 50%, so it's result of equation
        // resulting_amount = _amount + 0,5 * resulting_amount, which turns to resulting_amount = 2 * _amount
        uint256 resulting_amount = _amount.mul(2);
        require(mint(devFund, resulting_amount.mul(219152).div(1000000)));
        require(mint(sambhav, resulting_amount.mul(2006).div(10000)));
        require(mint(pondsea, resulting_amount.mul(60174).div(1000000)));
        require(mint(austin, resulting_amount.div(100)));
        require(mint(artem, resulting_amount.div(100)));
        require(mint(kiran, resulting_amount.mul(74).div(1000000)));
        return mint(_to, _amount);
    }

    // Finish minting in case we'd like to stop it
    function finishMint() public onlyOwner canMint returns (bool) {
        return finishMinting();
    }

    function setDevFund(address _new) public onlyOwner {
        devFund = _new;
    }

    function setSambhav(address _new) public onlyOwner {
        sambhav = _new;
    }

    function setPondsea(address _new) public onlyOwner {
        pondsea = _new;
    }

    function setAustin(address _new) public onlyOwner {
        austin = _new;
    }

    function setArtem(address _new) public onlyOwner {
        artem = _new;
    }

    function setKiran(address _new) public onlyOwner {
        kiran = _new;
    }

    function transfer(address recipient, uint256 amount) whenNotPaused public returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) whenNotPaused public returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
}
