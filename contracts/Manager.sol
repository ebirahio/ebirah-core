pragma solidity 0.5.17;

import "./Interfaces/IPancakeRouter01.sol";
import "./Interfaces/IERC20.sol";
import "./Interfaces/IWETH.sol";
import "./Interfaces/ITornado.sol";


contract Manager {

  function () external payable {}

  address public operator;
  uint256 public operatorFeePct;
  uint256 public systemFeePct;
  address public router;
  address public ebrh;
  address public wbnb;

  mapping(address => uint256) public farmingMultiplier;
  mapping(address => uint256) public farmingReward;
  uint256 public systemFee;

  modifier onlyOperator {
    require(msg.sender == operator, "Only operator can call this function.");
    _;
  }
  constructor (address _router, address _ebrh, address _wbnb) public {
      operator = msg.sender;
      router = _router;
      ebrh = _ebrh;
      wbnb = _wbnb;
  }

  function addFarmingReward(address _account, uint _base) public {
      farmingReward[_account] += _base * farmingMultiplier[msg.sender];
  }

  function collectFarmingReward() public {
      require(farmingReward[msg.sender] > 0, "No farming reward colelcted");
      IERC20(ebrh).transfer(msg.sender, farmingReward[msg.sender]);
      farmingReward[msg.sender] = 0;
  }

  function setSystemFeePct(uint256 _systemFeePct) public onlyOperator {
      require(_systemFeePct <= 10000, "Incorrect system fee percent value");
      systemFeePct = _systemFeePct;
  }

  function setOperatorFeePct(uint256 _operatorFeePct) public onlyOperator {
      require(_operatorFeePct <= 10000, "Incorrect operator fee percent value");
      operatorFeePct = _operatorFeePct;
  }

  function setFarmingMultiplier(address _pool, uint256 _multiplier) public onlyOperator {
      farmingMultiplier[_pool] = _multiplier;
  }

  function getPoolInfo(address _pool) public view returns(uint256, uint256) {
      return (systemFeePct, farmingMultiplier[_pool]);
  }

  function collectFees(address _pool) public {
      ITornado(_pool).collectFees();
  }

  //BUyRN function
  function buyrn(address _token) public {
      if( _token == address(0)){
          IWETH(wbnb).deposit.value(address(this).balance)();
          _token = wbnb;
      }
      uint256 balance = IERC20(_token).balanceOf(address(this));
      if(operatorFeePct > 0 ) {
          uint256 operatorFee = balance / 10000 * operatorFeePct;
          IERC20(_token).transfer(operator, operatorFee);
          balance -= operatorFee;
      } 
    
      IERC20(ebrh).approve(router, balance);
      address[] memory path =new address[](2);
      address token = _token;
      path[0] = token;
      path[1] = ebrh;
      uint256[] memory outAmounts = IPancakeRouter01(router).getAmountsOut(balance, path );
      uint256 outAmount = outAmounts[outAmounts.length-1];
      if( outAmount == 0 ){
          path =new address[](3); 
          path[0] = token;
          path[1] = wbnb;
          path[2] = ebrh;
          outAmounts = IPancakeRouter01(router).getAmountsOut(balance, path );
          outAmount = outAmounts[outAmounts.length-1];      
      } 
      require(outAmount > 0, "Cannot make a swap");
      IPancakeRouter01(router).swapExactTokensForTokens(balance, outAmount, path, address(this), block.number);
  }
}