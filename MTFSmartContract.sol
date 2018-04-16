pragma solidity 0.4.18;

/**
 * @title SafeMath for performing valid mathematics.
 */
library SafeMath {
 
  function Mul(uint a, uint b) internal pure returns (uint) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function Div(uint a, uint b) internal pure returns (uint) {
    //assert(b > 0); // Solidity automatically throws when Dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function Sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  } 

  function Add(uint a, uint b) internal pure returns (uint) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  } 
}

/**
 * Contract "Ownable"
 * Purpose: Defines Owner for contract and provide functionality to transfer ownership to another account
 */
contract Ownable {
    
    //owner variable to store contract owner account
    address public owner;
    
    //Constructor for the contract to store owner's account on deployement
    function Ownable() public {
        owner = msg.sender;
    }
    
    //modifier to check transaction initiator is only owner
    modifier onlyOwner() {
    require (msg.sender == owner);
      _;
    }

    function transferOwnership (address _NewOwner) public onlyOwner {
        require (_NewOwner != address(0));
        owner = _NewOwner;
    }
    
}

/**
 * @title ERC20 interface
 */
contract ERC20 is Ownable {
    uint256 public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool _success);
    function allowance(address owner, address spender) public view returns (uint256 _value);
    function transferFrom(address from, address to, uint256 value) public returns (bool _success);
    function approve(address spender, uint256 value) public returns (bool _success);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}

contract MTF is ERC20 {

    using SafeMath for uint256;
    //The name of the  token
    string public constant name = "MintFlint Token";
    //The token symbol
    string public constant symbol = "MTF";
    //The precision used in the balance calculations in contract
    uint8 public constant decimals = 18;
    //maximum number of tokens
    uint256 constant MAXCAP = 2500000000e18;
    //maximum allocation for team
    uint256 constant MAXCAPICO = 1500000000e18;
    //to save total number of ethers received
    uint256 public totalWeiReceived;

    //Mapping to relate owner and spender to the tokens allowed to transfer from owner
    mapping(address => mapping(address => uint256)) allowed;
    //Mapping to relate number of  token to the account
    mapping(address => uint256) balances;

    //time when the sale starts
    uint256 public startTime;
    //time when the presale ends
    uint256 public endTime;
    //to check the sale status
    bool public paused;
    bool allocated;

    //events
    event StateChanged(bool);

    function MTF() public{
        owner = msg.sender;
        startTime = 1529798400; //UTC: Sunday 24th June 2018 12:00:00 AM
        endTime = 1533859200; //UTC: Friday 10th August 2018 12:00:00 AM
        paused = false;
        allocated = false;
    }

    modifier onlyUnlocked(){
        require(now >= 1533859200);//GMT: Friday, August 10, 2018 12:00:00 AM
        _;
    }

    /**
     * @dev to determine the timeframe of sale
     */
    modifier validTimeframe(){
        require(!paused && now >=startTime && now < endTime);
        _;
    }

    
    /**
     * @dev Allocate tokens to team members
     */
    function initialAllocation()public onlyOwner{
        require(!allocated);
        
        // Receiver1 3.0% 
        uint256 part1 = 3*MAXCAPICO/400;
        balances[0xe29C245aB41041aA8BE0ef9F7dF3FFe6fc684b33] = part1;
        balances[0xa35CA6412aDb2458905620C941705EBf74C48533] = part1;
        balances[0x33F12B9A7bF9bd9b3F278f418856f6601381551c] = part1;
        balances[0x45687dE002ed612CB47FDDd7BA2F289d1d6390eE] = part1;
        
        Transfer(0x0, 0xe29C245aB41041aA8BE0ef9F7dF3FFe6fc684b33, part1);
        Transfer(0x0, 0xa35CA6412aDb2458905620C941705EBf74C48533, part1);
        Transfer(0x0, 0x33F12B9A7bF9bd9b3F278f418856f6601381551c, part1);
        Transfer(0x0, 0x45687dE002ed612CB47FDDd7BA2F289d1d6390eE, part1);

        // Receiver2 19.5%
        uint256 part2 = 195*MAXCAPICO/4000;
        balances[0x064440197CF23AEFeb0ff972485368a02Bb30625] = part2;
        balances[0x4a8C5Ea0619c40070f288c8aC289ef2f6Bb87cff] = part2;
        balances[0x947251376EeAFb0B0CD1bD47cC6056A5162bEaF4] = part2;
        balances[0x39A49403eFB1e85F835A9e5dc82706B970D112e4] = part2;
        Transfer(0x0, 0x064440197CF23AEFeb0ff972485368a02Bb30625, part2);
        Transfer(0x0, 0x4a8C5Ea0619c40070f288c8aC289ef2f6Bb87cff, part2);
        Transfer(0x0, 0x947251376EeAFb0B0CD1bD47cC6056A5162bEaF4, part2);
        Transfer(0x0, 0x39A49403eFB1e85F835A9e5dc82706B970D112e4, part2);
        
        // Receiver3 2.0% 0x733bc7201261aC3c9508D20a811D99179304240a
        balances[0x733bc7201261aC3c9508D20a811D99179304240a] = 2*MAXCAPICO/100;
        Transfer(0x0, 0x733bc7201261aC3c9508D20a811D99179304240a, 2*MAXCAPICO/100);
        
        // Receiver4 8.0% 0x4b6716bd349dC65d07152844ed4990C2077cF1a7
        balances[0x4b6716bd349dC65d07152844ed4990C2077cF1a7] = 8*MAXCAPICO/100;
        Transfer(0x0, 0x4b6716bd349dC65d07152844ed4990C2077cF1a7, 8*MAXCAPICO/100);

        // Receiver5 6% 0xEf628A29668C00d5C7C4D915F07188dC96cF24eb
        uint256 part5 = 6*MAXCAPICO/400;
        balances[0xEf628A29668C00d5C7C4D915F07188dC96cF24eb] = part5;
        balances[0xF28a5e85316E0C950f8703e2d99F15A7c077014c] = part5;
        balances[0x0c8C9Dcfa4ed27e02349D536fE30957a32b44a04] = part5;
        balances[0x0A86174f18D145D3850501e2f4C160519207B829] = part5;
        Transfer(0x0, 0xEf628A29668C00d5C7C4D915F07188dC96cF24eb, part5);
        Transfer(0x0, 0xF28a5e85316E0C950f8703e2d99F15A7c077014c, part5);
        Transfer(0x0, 0x0c8C9Dcfa4ed27e02349D536fE30957a32b44a04, part5);
        Transfer(0x0, 0x0A86174f18D145D3850501e2f4C160519207B829, part5);

        // Receiver6 1.50%
        // 0.75% in 0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728 and
        // 0.75% in 0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5
        balances[0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728] = 75*MAXCAPICO/10000;
        balances[0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5] = 75*MAXCAPICO/10000;
        Transfer(0x0, 0x35eeb3216E2Ff669F2c1Ff90A08A22F60e6c5728, 75*MAXCAPICO/10000);
        Transfer(0x0, 0x28dcC9Af670252A5f76296207cfcC29B4E3C68D5, 75*MAXCAPICO/10000);
        
        // sum of all tokens supplied in this function which is 40% of MAXCAPICO
        totalSupply = 4*MAXCAPICO/10;
        allocated = true;
    }

    /**
    * @dev Check balance of given account address
    *
    * @param _owner The address account whose balance you want to know
    * @return balance of the account
    */
    function balanceOf(address _owner) public view returns (uint256 _value){
        return balances[_owner];
    }

    /**
    * @dev Transfer sender's token to a given address
    *
    * @param _to The address which you want to transfer to
    * @param _value the amount of tokens to be transferred
    * @return A bool if the transfer was a success or not
    */
    function transfer(address _to, uint _value) public onlyUnlocked returns(bool _success) {
        require( _to != address(0) );
        if((balances[msg.sender] >= _value) && _value > 0 && _to != address(0)){
            balances[msg.sender] = balances[msg.sender].Sub(_value);
            balances[_to] = balances[_to].Add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else{
            return false;
        }
    }

    /**
    * @dev Transfer tokens from one address to another, for ERC20.
    *
    * @param _from The address which you want to send tokens from
    * @param _to The address which you want to transfer to
    * @param _value the amount of tokens to be transferred
    * @return A bool if the transfer was a success or not 
    */
    function transferFrom(address _from, address _to, uint256 _value)public onlyUnlocked returns (bool){
        if((_value > 0)
           && (_to != address(0))
           && (_from != address(0))
           && (allowed[_from][msg.sender] >= _value )){
           balances[_from] = balances[_from].Sub(_value);
           balances[_to] = balances[_to].Add(_value);
           allowed[_from][msg.sender] = allowed[_from][msg.sender].Sub(_value);
           Transfer(_from, _to, _value);
           return true;
       }
       else{
           return false;
       }
    }

    /**
    * @dev Function to check the amount of tokens that an owner has allowed a spender to recieve from owner.
    *
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender to spend.
    */
    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool){
        if( (_value > 0) && (_spender != address(0)) && (balances[msg.sender] >= _value)){
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
        else{
            return false;
        }
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
    function pauseSale() public onlyOwner{
        assert(!paused && startTime > 0 && now <= endTime);
        paused = true;
    }

    /**
    * @dev to resume paused sale
    *
    */
    function resumeSale() public onlyOwner{
        assert(paused && startTime > 0 && now <= endTime);
        paused = false;
    }

    function buyTokens(address beneficiary) internal validTimeframe {
        uint256 tokensBought = msg.value.Mul(getPrice());
        balances[beneficiary] = balances[beneficiary].Add(tokensBought);
        Transfer(0x0, beneficiary ,tokensBought);
        totalSupply = totalSupply.Add(tokensBought);

        assert(totalSupply <= MAXCAP);
        totalWeiReceived = totalWeiReceived.Add(msg.value);
        owner.transfer(msg.value);
    }

    function () public payable {
        buyTokens(msg.sender);
    }

    /**
    * @dev Failsafe drain.
    */
    function drain() public onlyOwner {
        owner.transfer(this.balance);
    }
}
