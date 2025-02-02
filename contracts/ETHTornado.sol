// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

pragma solidity 0.5.17;

import "./Tornado.sol";
import "./Interfaces/IManager.sol";
import "./Interfaces/IERC20.sol";

contract ETHTornado is Tornado {
  address public manager;
  uint256 public feesCollected;

  constructor(
    IVerifier _verifier,
    uint256 _denomination,
    uint32 _merkleTreeHeight,
    address _operator,
    address _manager
  ) Tornado(_verifier, _denomination, _merkleTreeHeight, _operator) public {
    manager = _manager;
  }

  function collectFees() public {
    (bool success, ) = manager.call.value(feesCollected)("");
    require(success, "payment to _manager did not go thru");
    feesCollected = 0;
  }  


  function _processDeposit() internal {
    require(msg.value == denomination, "Please send `mixDenomination` ETH along with transaction");
  }

  function _processWithdraw(address payable _recipient, address payable _relayer, uint256 _fee, uint256 _refund) internal {
    // sanity checks
    require(msg.value == 0, "Message value is supposed to be zero for ETH instance");
    require(_refund == 0, "Refund value is supposed to be zero for ETH instance");

    (bool success, ) = _recipient.call.value(denomination - _fee)("");
    require(success, "payment to _recipient did not go thru");
    if (_fee > 0) {
      (uint256 systemFeePct, uint256 farmingRewardMultiplier) = IManager(manager).getPoolInfo(address(this));
      if( systemFeePct > 0 ) {
        uint256 systemFee = _fee / 10000 * systemFeePct;
        feesCollected += systemFee;
        _fee -= systemFee;
      }
      (success, ) = _relayer.call.value(_fee)("");
      require(success, "payment to _relayer did not go thru");
      if( farmingRewardMultiplier > 0 ) {
        IManager(manager).addFarmingReward(_recipient, _fee);
        IManager(manager).addFarmingReward(_relayer, _fee);
      }
    }
  }

  function rescueFunds(address _token) public {
    require( msg.sender == operator, "Not permitted" );
    if( _token ==  address(0)){
      uint256 balance = address(this).balance;
      (bool success, ) = operator.call.value(balance)("");
      require(success, "payment to _operator did not go thru");
    }else{
      uint256 balance = IERC20(_token).balanceOf(address(this));
      _safeErc20Transfer(_token, operator, balance);
    }
  }  


  function _safeErc20Transfer(address _token, address _to, uint256 _amount) internal {
    (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb /* transfer */, _to, _amount));
    require(success, "not enough tokens");

    // if contract returns some data lets make sure that is `true` according to standard
    if (data.length > 0) {
      require(data.length == 32, "data length should be either 0 or 32 bytes");
      success = abi.decode(data, (bool));
      require(success, "not enough tokens. Token returns false.");
    }
  }

}
