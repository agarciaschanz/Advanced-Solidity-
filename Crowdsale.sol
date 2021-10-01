pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

/* This crowdsale contract will manage the entire process, allowing users to send ETH and get back PUP (PupperCoin).
This contract will mint the tokens automatically and distribute them to buyers in one transaction.
*/

/* @TODO: Inherit the crowdsale contracts
It will need to inherit Crowdsale, CappedCrowdsale, TimedCrowdsale, RefundableCrowdsale, and MintedCrowdsale.
*/
contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, 
RefundablePostDeliveryCrowdsale {

    constructor(
        // @TODO: Fill in the constructor parameters!
        uint rate, // rate in TKNbits
        address payable wallet, // sale beneficiary
        PupperCoin token, // the PupperCoin token itself that the PupperCoinSale will work with
        uint fakenow,
        // In the original puppercoinsale, close = now + 24 weeks
        // For test purposes only, a) a variable "fakenow" is created and b) cloase = fakenow + 1 minutes
        uint close,
        uint goal
    )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(goal)
        //TimedCrowdsale(open = now, close = now + 1 minutes) in this case
        //        TimedCrowdsale(fakenow, fakenow + 1 minutes)
        //TimedCrowdsale(open = fakenow, close = fakenow + 24 weeks) in the original question
        TimedCrowdsale(now, now + 24 weeks)

        RefundableCrowdsale(goal)

        // @TODO: Pass the constructor parameters to the crowdsale contracts.
        public
    {
        // constructor can stay empty
    }
}


contract PupperCoinSaleDeployer {

    address public pupper_token_address;
    address public token_address;

    constructor(
        // @TODO: Fill in the constructor parameters!
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal
        //create a variable called fakenow
        //uint fakenow
    )
        public
    {
        // @TODO: create the PupperCoin and keep its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);
        token_address = address(token);

        // @TODO: create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        //PupperCoinSale pupper_token = new PupperCoinSale(1, wallet, token, goal, fakenow, fakenow + 2 minutes);
        PupperCoinSale pupper_token = new PupperCoinSale(
                            1, // 1 wei
                            wallet, // address collecting the tokens
                            token, // token sales
                            goal, // maximum supply of tokens 
                            now, 
                            now + 24 weeks);
        //replace now by fakenow to get a test function

        //To test the time functionality for a shorter period of time: use fake now for start time and close time to be 1 min, etc.
        //PupperCoinSale pupper_token = new PupperCoinSale(1, wallet, token, goal, fakenow, now + 5 minute);
        pupper_token_address = address(pupper_token);

        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(pupper_token_address);
        token.renounceMinter();
    }
}
