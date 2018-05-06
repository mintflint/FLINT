pragma solidity ^0.4.21;
import './MintableToken.sol';
import 'openzeppelin-solidity/contracts//ownership/Ownable.sol';

contract MTF is MintableToken, Ownable {

    using SafeMath for uint256;
    //The name of the  token
    string public constant name = "MintFlint Token";
    //The token symbol
    string public constant symbol = "MTF";
    //The precision used in the balance calculations in contract
    uint8 public constant decimals = 18;
    //maximum allocation for team
    uint256 constant MAXCAPICO = 1500000000e18;
    //to save total number of ethers received
    uint256 public totalWeiReceived;

    //time when the sale starts
    uint256 public startTime;
    //time when the presale ends
    uint256 public endTime;
    //to check the sale status
    bool public paused;

    //events
    event StateChanged(bool);

    function MTF() public {
        startTime = 1529798400; //UTC: Sunday 24th June 2018 12:00:00 AM
        endTime = 1533859200; //UTC: Friday 10th August 2018 12:00:00 AM
        paused = false;
        totalSupply_ = 0;
    }

    modifier onlyUnlocked() {
        require(now >= 1533859200); //GMT: Friday, August 10, 2018 12:00:00 AM
        _;
    }

    /**
     * @dev to determine the timeframe of sale
     */
    modifier validTimeframe() {
        require(!paused && now >=startTime && now < endTime);
        _;
    }

    /**
     * @dev Allocate tokens to team members
     */
    function initialAllocation() public onlyOwner {
        // Receiver1 3.0%
        uint256 part1 = 3*MAXCAPICO/400;
        balances[0xe29C245aB41041aA8BE0ef9F7dF3FFe6fc684b33] = part1;
        balances[0xa35CA6412aDb2458905620C941705EBf74C48533] = part1;
        balances[0x33F12B9A7bF9bd9b3F278f418856f6601381551c] = part1;
        balances[0x45687dE002ed612CB47FDDd7BA2F289d1d6390eE] = part1;

        // Receiver2 19.5%
        uint256 part2 = 195*MAXCAPICO/4000;
        balances[0x064440197CF23AEFeb0ff972485368a02Bb30625] = part2;
        balances[0x4a8C5Ea0619c40070f288c8aC289ef2f6Bb87cff] = part2;
        balances[0x947251376EeAFb0B0CD1bD47cC6056A5162bEaF4] = part2;
        balances[0x39A49403eFB1e85F835A9e5dc82706B970D112e4] = part2;

        // Receiver3 2.0% 0x733bc7201261aC3c9508D20a811D99179304240a
        balances[0x733bc7201261aC3c9508D20a811D99179304240a] = 2*MAXCAPICO/100;

        // Receiver4 8.0% 0x4b6716bd349dC65d07152844ed4990C2077cF1a7
        balances[0x4b6716bd349dC65d07152844ed4990C2077cF1a7] = 8*MAXCAPICO/100;

        // Receiver5 6% 0xEf628A29668C00d5C7C4D915F07188dC96cF24eb
        uint256 part5 = 6*MAXCAPICO/400;
        balances[0xEf628A29668C00d5C7C4D915F07188dC96cF24eb] = part5;
        balances[0xF28a5e85316E0C950f8703e2d99F15A7c077014c] = part5;
        balances[0x0c8C9Dcfa4ed27e02349D536fE30957a32b44a04] = part5;
        balances[0x0A86174f18D145D3850501e2f4C160519207B829] = part5;

        // Receiver6 1.50%
        // 0.75% in 0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728 and
        // 0.75% in 0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5
        balances[0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728] = 75*MAXCAPICO/10000;
        balances[0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5] = 75*MAXCAPICO/10000;
    }

    function transfer(address _to, uint _value) onlyUnlocked public returns(bool _success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Calculate number of tokens that will be received in one ether
    *
    */
    function getPrice() public pure returns(uint256) {
        uint256 price = 100000;
        return price;
    }

    /**
    * @dev to enable pause sale for break in ICO and Pre-ICO
    *
    */
    function pauseSale() public onlyOwner {
        assert(!paused && startTime > 0 && now <= endTime);
        paused = true;
    }

    /**
    * @dev to resume paused sale
    *
    */
    function resumeSale() public onlyOwner {
        assert(paused && startTime > 0 && now <= endTime);
        paused = false;
    }

    function buyTokens(address beneficiary) internal validTimeframe {
        uint256 tokensBought = msg.value.mul(getPrice());
        totalWeiReceived = totalWeiReceived.add(msg.value);
        owner.transfer(msg.value);
    }

    function () public payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev Failsafe drain.
    */
    function drain() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}
