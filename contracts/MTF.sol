pragma solidity ^0.4.21;
import './MintableToken.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract MTF is MintableToken, Ownable {

    using SafeMath for uint256;
    //The name of the  token
    string public constant name = "MintFlint Token";
    //The token symbol
    string public constant symbol = "MTF";
    //The precision used in the balance calculations in contract
    uint8 public constant decimals = 18;

    //maximum cap to be sold on ICO
    uint256 public constant maxCap = 1500000000e18;
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
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);

    function MTF(uint256 _startTime, uint256 _endTime) public {
        startTime = _startTime;
        endTime = _endTime;
        paused = false;
        totalSupply_ = 0;
    }

    modifier whenSaleEnded() {
        require(now >= endTime);
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
    function teamAllocation(address _airdropAddress) public onlyOwner whenSaleEnded {
        uint256 toDistribute = totalSupply_.mul(2);
        // Receiver1 3.0%
        uint256 part1 = toDistribute.mul(3).div(400);
        mint(0x1117Db9F1bf18C91233Bff3BF2676137709463B3, part1);
        mint(0x6C137b489cEE58C32fd8Aec66EAdC4B959550198, part1);
        mint(0x450023b2D943498949f0A9cdb1DbBd827844EE78, part1);
        mint(0x89080db76A555c42D7b43556E40AcaAFeB786CDD, part1);

        // Receiver2 19.5%
        uint256 part2 = toDistribute.mul(195).div(4000);
        mint(0xcFc43257606C6a642d9438dCd82bf5b39A17dbAB, part2);
        mint(0x4a8C5Ea0619c40070f288c8aC289ef2f6Bb87cff, part2);
        mint(0x947251376EeAFb0B0CD1bD47cC6056A5162bEaF4, part2);
        mint(0x39A49403eFB1e85F835A9e5dc82706B970D112e4, part2);

        // Receiver3 2.0% 0x733bc7201261aC3c9508D20a811D99179304240a
        mint(0x733bc7201261aC3c9508D20a811D99179304240a, toDistribute.mul(2).div(100));

        // Receiver4 18.0% 0x4b6716bd349dC65d07152844ed4990C2077cF1a7
        mint(0x4b6716bd349dC65d07152844ed4990C2077cF1a7, toDistribute.mul(18).div(100));

        // Receiver5 6% 0xEf628A29668C00d5C7C4D915F07188dC96cF24eb
        uint256 part5 = toDistribute.mul(6).div(400);
        mint(0xEf628A29668C00d5C7C4D915F07188dC96cF24eb, part5);
        mint(0xF28a5e85316E0C950f8703e2d99F15A7c077014c, part5);
        mint(0x0c8C9Dcfa4ed27e02349D536fE30957a32b44a04, part5);
        mint(0x0A86174f18D145D3850501e2f4C160519207B829, part5);

        // Receiver6 1.50%
        // 0.75% in 0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728 and
        // 0.75% in 0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5
        mint(0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728, toDistribute.mul(75).div(10000));
        mint(0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5, toDistribute.mul(75).div(10000));

        mint(_airdropAddress, 175000000 ether);

        finishMinting();
    }

    function transfer(address _to, uint _value) whenSaleEnded public returns(bool _success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) whenSaleEnded public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Calculate number of tokens that will be received in one ether
    *
    */
    function getPrice() public pure returns(uint256) {
        return 100000;
    }

    /**
    * @dev to enable pause sale for break in ICO and Pre-ICO
    *
    */
    function pauseSale() public onlyOwner {
        require(!paused);
        paused = true;
    }

    /**
    * @dev to resume paused sale
    *
    */
    function resumeSale() public onlyOwner {
        require(paused);
        paused = false;
    }

    function buyTokens(address beneficiary) internal validTimeframe {
        uint256 tokensBought = msg.value.mul(getPrice());
        totalWeiReceived = totalWeiReceived.add(msg.value);
        emit TokenPurchase(beneficiary, msg.value, tokensBought);
        mint(beneficiary, tokensBought);
        require(totalSupply_ <= maxCap);
    }

    function () public payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev Failsafe drain.
    */
    function drain() public onlyOwner whenSaleEnded {
        owner.transfer(address(this).balance);
    }
}
