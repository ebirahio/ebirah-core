/* global artifacts */
const Manager = artifacts.require('Manager')

module.exports = function(deployer) {
  deployer.deploy(Manager, "0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F", "0xEae68564C96b1e1c471093A539836ae8Bf7C1B65", "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c");
}
