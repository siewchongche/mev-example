// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../interface/Balancer.sol";
import "../interface/GMX.sol";
import "../interface/CurvePool.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Arb2Test is Test {
    Balancer balancer = Balancer(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    GMX gmx = GMX(0x489ee077994B6658eAfA855C308275EAd8097C4A);
    CurvePool curve = CurvePool(0x2ce5Fd6f6F4a159987eac99FF5158B7B62189Acf);
    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    function setUp() public {
        USDT.approve(address(gmx), type(uint).max);
        USDC.approve(address(curve), type(uint).max);
    }

    function testArbitrage() public {
        address[] memory tokens = new address[](1);
        tokens[0] = address(USDT);
        uint[] memory amounts = new uint[](1);
        amounts[0] = 20000e6;
        // Flashloan 20k USDT from Balancer
        balancer.flashLoan(address(this), tokens, amounts, bytes(""));
    }

    function receiveFlashLoan(address[] memory tokens, uint[] memory amounts, uint[] memory feeAmounts, bytes memory userData) external {
        require(msg.sender == address(balancer));
        // Swap USDT for USDC with GMX, GMX require transfer token into its contract first to perform swap 
        USDT.transfer(address(gmx), amounts[0]);
        gmx.swap(address(USDT), address(USDC), address(this));
        // console.log(USDC.balanceOf(address(this))); // 19749.113018
        // Exchange USDC for USDT with Curve dForce pool
        curve.exchange_underlying(1, 2, USDC.balanceOf(address(this)), 0);
        // console.log(USDT.balanceOf(address(this))); // 3_089_264.422215
        // Payback 20k USDT to Balancer
        IERC20(tokens[0]).transfer(address(balancer), amounts[0]);
        feeAmounts; // Unused variable
        userData; // Unused variable
    }
}
