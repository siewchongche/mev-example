// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "../interface/NonfungiblePositionManager.sol";
import "../interface/UniswapV3Pool.sol";
import "../interface/SwapRouter.sol";

contract ContractTest is Test {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    NonfungiblePositionManager nonfungiblePositionManager = NonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    UniswapV3Pool pool = UniswapV3Pool(0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8); // USDC-WETH 0.3% fee
    SwapRouter swapRouter = SwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uint tokenId;

    function setUp() public {
        USDC.approve(address(nonfungiblePositionManager), type(uint).max);
        WETH.approve(address(nonfungiblePositionManager), type(uint).max);
        USDC.approve(address(swapRouter), type(uint).max);
    }

    function testMev() public {
        // First transaction: MEV bot
        // https://etherscan.io/tx/0x80e4abcb0b701e9d2c0d0fd216ef22eca5fc13904e8c7b3967bcad997480d638
        deal(address(USDC), address(this), 10_864_608.891029e6); // simulate amount USDC funded to bot
        deal(address(WETH), address(this), 11_523.578906537640459205 ether); // simulate amount WETH funded to bot
        // Calculate out the closest range
        (, int24 tick,,,,,) = pool.slot0();
        int24 tickLower = tick / 60 * 60;
        int24 tickUpper = tickLower + 60;
        // Mint Uniswap V3 position
        NonfungiblePositionManager.MintParams memory mintParams =
            NonfungiblePositionManager.MintParams({
                token0: address(USDC),
                token1: address(WETH),
                fee: 3000,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: USDC.balanceOf(address(this)),
                amount1Desired: WETH.balanceOf(address(this)),
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });
        (uint _tokenId,, uint amount0, uint amount1) = nonfungiblePositionManager.mint(mintParams);
        // console.log(amount0); // 10,864,608.891029
        // console.log(amount1); // 8,281.712219747858010668
        tokenId = _tokenId; // Record token id for remove liquidity use
        // console.log(USDC.balanceOf(address(this))); // 0
        // console.log(WETH.balanceOf(address(this))); // 3,241.866686789782448537
        deal(address(WETH), address(this), 0); // simulate MEV bot transfer out WETH balance


        // Second transaction: random swap on Uniswap V3
        // https://etherscan.io/tx/0x943131400defa5db902b1df4ab5108b58527e525da3d507bd6e6465d88fa079c
        uint USDCAmtToSwap = 1896817745609;
        deal(address(USDC), address(this), USDCAmtToSwap);
        SwapRouter.ExactInputSingleParams memory exactInputSingleParams = 
            SwapRouter.ExactInputSingleParams({
                tokenIn: address(USDC),
                tokenOut: address(WETH),
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: USDCAmtToSwap,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        swapRouter.exactInputSingle(exactInputSingleParams);
        // console.log(WETH.balanceOf(address(this))); // 408.818202022592862626
        deal(address(WETH), address(this), 0); // Reset WETH balance of this address to 0


        // Third transaction: MEV bot
        // https://etherscan.io/tx/0x12b3d1f0e29d9093d8f3c7cce2da95edbef01aaab3794237f263da85c37c7d27
        // Get liquidity balance
        (,,,,,,, uint128 liquidity,,,,) = nonfungiblePositionManager.positions(tokenId);
        // Remove liquidity: consists of "decrease liquidity" and "collect"
        NonfungiblePositionManager.DecreaseLiquidityParams memory params = 
            NonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });
        nonfungiblePositionManager.decreaseLiquidity(params);
        NonfungiblePositionManager.CollectParams memory collectParams =
            NonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                // type(uint128).max - collect removed liquidity + any available fee
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });
        nonfungiblePositionManager.collect(collectParams);
        console.log(USDC.balanceOf(address(this))); // 12,634,177.387879
        console.log(WETH.balanceOf(address(this))); // 7,900.319851971188832064
        // Burn the NFT (Uniswap V3 position) to reduce some gas fee
        nonfungiblePositionManager.burn(tokenId);

        // Profit / Loss
        // USDC accept by Uniswap 10,864,608.891029
        // WETH accept by Uniswap 8,281.712219747858010668
        // USDC remove from Uniswap 12,634,177.387879
        // WETH remove from Uniswap 7,900.319851971188832064
        // USDC + 1,769,568.49685
        // WETH - 381.392367777
        // WETH price at the moment: $4,668.7
        // 4,668.7 * 381.392367777 = 1,780,606.54744048
        // 1,769,568.49685 - 1,780,606.54744048 = −11038.05059048 loss??
    }
}
