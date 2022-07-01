// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../interface/CurveFindBestRate.sol";
import "../interface/DODOSwap.sol";
import "../interface/UniswapV3Pool.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Arb1Test is Test {
    CurveFindBestRate curve = CurveFindBestRate(0x316d06Dd6644AD630C73cD3A6a2c7AE0D22f939e); // Curve contract to find best exchange rate
    DODOSwap dodoSwap = DODOSwap(0x88CBf433471A0CD8240D2a12354362988b4593E5); // DODO: Proxy 02 V2
    UniswapV3Pool uniswapV3Pool = UniswapV3Pool(0xF8E5a77a4f187cFb455663B37619257565439F6A); // USDT-eFIL 0.3% fee
    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    function setUp() public {
        // USDT approve to "approve contract" of DODOSwap to swap USDT in DODOSwap
        USDT.approve(0xA867241cDC8d3b0C07C85cC06F25a0cD3b5474d8, type(uint).max);
        USDC.approve(address(curve), type(uint).max);
    }

    function testArbitrage() public {
        // Initialize Uniswap V3 flashswap with USDT-eFIL pool to loan 6k USDT
        uniswapV3Pool.flash(address(this), 0, 6000e6, bytes(abi.encode(6000e6)));
        // console.log(USDT.balanceOf(address(this))); // 2_099_015.518076, profit
    }

    function uniswapV3FlashCallback(uint fee0, uint fee1, bytes calldata data) external {
        address[] memory dodoPairs = new address[](1);
        dodoPairs[0] = 0xe4B2Dfc82977dd2DCE7E8d37895a6A8F50CbB4fB; // DODO: USDT-USDC Pair V1
        // Swap USDT for USDC with DODOSwap
        dodoSwap.dodoSwapV1(address(USDT), address(USDC), USDT.balanceOf(address(this)), 1, dodoPairs, 0, true, block.timestamp);
        // console.log(USDC.balanceOf(address(this))); // 5940.805842
        // Exchange USDC for USDT with Curve 2CRV pool by Curve contract which help to find best exchange rate
        curve.exchange_with_best_rate(address(USDC), address(USDT), USDC.balanceOf(address(this)), 0);
        // console.log(USDT.balanceOf(address(this))); // 2_105_033.518076
        // Repay flashswap (initial loan amount + 0.3% fee)
        USDT.transfer(msg.sender, abi.decode(data, (uint)) + fee1);
        fee0; // Unused variable
    }
}
