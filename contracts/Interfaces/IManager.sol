pragma solidity >=0.5.0;

interface IManager {
  function getPoolInfo(address _pool) external view returns(uint256, uint256);
  function addFarmingReward(address _account, uint _base) external;
}
