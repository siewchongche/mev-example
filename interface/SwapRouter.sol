pragma solidity ^0.8.10;

interface SwapRouter {
    struct ExactOutputParams { bytes a; address b; uint256 c; uint256 d; uint256 e; }
    struct ExactInputSingleParams { address tokenIn; address tokenOut; uint24 fee; address recipient; uint256 deadline; uint256 amountIn; uint256 amountOutMinimum; uint160 sqrtPriceLimitX96; }
    struct ExactInputParams { bytes a; address b; uint256 c; uint256 d; uint256 e; }
    struct ExactOutputSingleParams { address a; address b; uint24 c; address d; uint256 e; uint256 f; uint256 g; uint160 h; }

    function WETH9() view external returns (address);
    function exactInput(ExactInputParams memory params) payable external returns (uint256 amountOut);
    function exactInputSingle(ExactInputSingleParams memory params) payable external returns (uint256 amountOut);
    function exactOutput(ExactOutputParams memory params) payable external returns (uint256 amountIn);
    function exactOutputSingle(ExactOutputSingleParams memory params) payable external returns (uint256 amountIn);
    function factory() view external returns (address);
    function multicall(bytes[] memory data) payable external returns (bytes[] memory results);
    function refundETH() payable external;
    function selfPermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitAllowed(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitAllowedIfNecessary(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) payable external;
    function selfPermitIfNecessary(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) payable external;
    function sweepToken(address token, uint256 amountMinimum, address recipient) payable external;
    function sweepTokenWithFee(address token, uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient) payable external;
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes memory _data) external;
    function unwrapWETH9(uint256 amountMinimum, address recipient) payable external;
    function unwrapWETH9WithFee(uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient) payable external;
}
