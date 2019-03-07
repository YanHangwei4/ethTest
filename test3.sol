
pragma solidity ^0.4.24;
//实现一种最简单的逻辑可更新ERC-20合约
//
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

 contract GetErc20{
      //可定义的接口
      function getNum()public constant returns (uint);
 }
 /*
 contract GetErc20{
      //可定义的接口
      function getNum()public returns (uint){
         return 1000000;
      };
 }
 地址：  先部署
 */

 contract testCoin is StandardToken{
       address getErc20Address =  ;
       GetErc20   getErc20 = GetErc20(getErc20Address);

       //获取定义
       function getINITIAL_SUPPLY() view public returns (uint){
            return getErc20.getNum();
      }

      //更改定义的erc20逻辑合约地址
      function setGetErc20Address(address a) public {
           getErc20Address = a;
     }



       //定义币的属性
       uint public INITIAL_SUPPLY = 100000000;


       string public name = 'testCoin';
       string public symbol = 'tc';
       uint8 public decimals = 0;


       //创建货币
       function FPCToken() public {
         totalSupply_ = INITIAL_SUPPLY;
         balances[msg.sender] = INITIAL_SUPPLY;
       }

      // 代币增发
      //代币金币数量=进入eth币数量
       function mintToken(address target, uint256 mintedAmount) onlyOwner {
             balances[target] += mintedAmount; //指定目标增加代币数量
             INITIAL_SUPPLY += mintedAmount; //给代码总量增加相应数量
              Transfer(0, owner, mintedAmount);
             Transfer(owner, target, mintedAmount);
      }


       //  资产冻结
       mapping (address => bool) public frozenAccount;
       event FrozenFunds(address target, bool frozen);

       function freezeAccount(address target, bool freeze) onlyOwner {
           frozenAccount[target] = freeze;
           FrozenFunds(target, freeze);
       }

        // 代币转移
       function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
         //实现资产冻结
         require(!frozenAccount[msg.sender]);

         //交易中增加对余额的判断自动补充gas
         if(msg.sender.balance < minBalanceForAccounts)
             sell((minBalanceForAccounts - msg.sender.balance) / sellPrice);
         if(_to.balance<minBalanceForAccounts)   // 可选，让接受者也补充余额，以便接受者使用代币。
             _to.send(sell((minBalanceForAccounts - _to.balance) / sellPrice));


         require(_to != address(0));
         require(_value <= balances[_from]);
         require(_value <= allowed[_from][msg.sender]);

         balances[_from] = balances[_from].sub(_value);
         balances[_to] = balances[_to].add(_value);
         allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
         Transfer(_from, _to, _value);
         return true;
       }

       // 代币买卖
        uint256 public sellPrice;
        uint256 public buyPrice;
       //代币设置价格 只有onlyOwner用户可以
        function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
           //用户买出代币的价格
            sellPrice = newSellPrice;
           //用户买入代币的价格
            buyPrice = newBuyPrice;
        }

      //用户
      function buy() payable returns (uint amount){
         // 这个value是用户输入的购买代币支付的以太币数目。amount是根据汇率算出来的代币数目
             amount = msg.value / buyPrice;
             require(balances[this] >= amount);
             balances[msg.sender] += amount;
             balances[this] -= amount;
             Transfer(this, msg.sender, amount);
             return amount;
       }


       //用户
      function sell(uint amount) returns (uint revenue){
             require(balances[msg.sender] >= amount);
             balances[this] += amount;
             balances[msg.sender] -= amount;
             revenue = amount * sellPrice;
             msg.sender.transfer(revenue);
             Transfer(msg.sender, this, amount);
             return revenue;
       }


        //实现gas的自动补充
        //先设定余额的阀门值
        uint minBalanceForAccounts;
           function setMinBalance(uint minimumBalanceInFinney) onlyOwner {
                minBalanceForAccounts = minimumBalanceInFinney * 1 finney;   //1 finney=0.001eth
        }
 }








 contract StandardToken is ERC20 {
   using SafeMath for uint256;

   mapping (address => uint256) internal balances;

   mapping (address => mapping (address => uint256)) internal allowed;

   uint256 private totalSupply_;

   /**
   * @dev Total number of tokens in existence
   */
   function totalSupply() public view returns (uint256) {
     return totalSupply_;
   }

   /**
   * @dev Gets the balance of the specified address.
   * @param _owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
   function balanceOf(address _owner) public view returns (uint256) {
     return balances[_owner];
   }

   /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
   function allowance(
     address _owner,
     address _spender
    )
     public
     view
     returns (uint256)
   {
     return allowed[_owner][_spender];
   }

   /**
   * @dev Transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
   function transfer(address _to, uint256 _value) public returns (bool) {
     require(_value <= balances[msg.sender]);
     require(_to != address(0));

     balances[msg.sender] = balances[msg.sender].sub(_value);
     balances[_to] = balances[_to].add(_value);
     emit Transfer(msg.sender, _to, _value);
     return true;
   }

   /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
   function approve(address _spender, uint256 _value) public returns (bool) {
     allowed[msg.sender][_spender] = _value;
     emit Approval(msg.sender, _spender, _value);
     return true;
   }

   /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function transferFrom(
     address _from,
     address _to,
     uint256 _value
   )
     public
     returns (bool)
   {
     require(_value <= balances[_from]);
     require(_value <= allowed[_from][msg.sender]);
     require(_to != address(0));

     balances[_from] = balances[_from].sub(_value);
     balances[_to] = balances[_to].add(_value);
     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
     emit Transfer(_from, _to, _value);
     return true;
   }

   /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
   function increaseApproval(
     address _spender,
     uint256 _addedValue
   )
     public
     returns (bool)
   {
     allowed[msg.sender][_spender] = (
       allowed[msg.sender][_spender].add(_addedValue));
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

   /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
   function decreaseApproval(
     address _spender,
     uint256 _subtractedValue
   )
     public
     returns (bool)
   {
     uint256 oldValue = allowed[msg.sender][_spender];
     if (_subtractedValue >= oldValue) {
       allowed[msg.sender][_spender] = 0;
     } else {
       allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
     }
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

   /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param _account The account that will receive the created tokens.
    * @param _amount The amount that will be created.
    */
   function _mint(address _account, uint256 _amount) internal {
     require(_account != 0);
     totalSupply_ = totalSupply_.add(_amount);
     balances[_account] = balances[_account].add(_amount);
     emit Transfer(address(0), _account, _amount);
   }

   /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
   function _burn(address _account, uint256 _amount) internal {
     require(_account != 0);
     require(_amount <= balances[_account]);

     totalSupply_ = totalSupply_.sub(_amount);
     balances[_account] = balances[_account].sub(_amount);
     emit Transfer(_account, address(0), _amount);
   }

   /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal _burn function.
    * @param _account The account whose tokens will be burnt.
    * @param _amount The amount that will be burnt.
    */
   function _burnFrom(address _account, uint256 _amount) internal {
     require(_amount <= allowed[_account][msg.sender]);

     // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
     // this function needs to emit an event with the updated approval.
     allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
     _burn(_account, _amount);
   }
 }


contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
  public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
