# EBIRAH - anonymous mixer for Binance Smart Chain 
based on Tornado Cash [Tornado readme](./Tornado.md)

## EBRH token 

Is designed as rewardable BEP20 token on Binance Smart Chain. WBNB-EBRH pair is listed on Pancake Swap.

## Manager contract

Manager contract is responsible for handling system-wide fees and farming rewards for pool participating in farming program. 

## BUyRN - Buy and Burn

Fees collected by the system go directly for purchaing EBRH tokens on Pancake Swap. EBRH tokens purchased this way are locked on Manager contract and can be distributed only as farming reward. 

## Fee structure
Relayer fee - fee, collected by relayer for sending withdrawal transaction. 

System fee - part of Relayer fee collected by Ebirah for further distibution

Operator fee - part of System fee transferred directly to Ebirah team. 


## Tokenomics

All fees are collected when withdrawal transaction happens. 

Relayer fee is immediately sent to relayer.

System fee is accumulated within the pool and can be collected by calling permissionless "collectFee" function in manager contract. 

All fees collected can be exchanged for EBRH tokens on Pancake Swap by calling permissionless "buyrn" function in manager contract.

## Farming 

Ebirah team will select pools rewarding participants with EBRH tokens for each transaction. Each withdrawal transaction rewards receipient and relayer with EBRH tokens. Collected rewards can be withdrawn from Manager contract by calling permissionless "collectFarmingReward" function.  




