pragma solidity ^0.8.10;

interface UniswapV3Pool {
    function flash(address recipient, uint amount0, uint amount1, bytes memory data) external;
}