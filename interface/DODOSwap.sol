pragma solidity ^0.8.10;

interface DODOSwap {
    event OrderHistory(address fromToken, address toToken, address sender, uint256 fromAmount, uint256 returnAmount);
    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _DODO_APPROVE_PROXY_() view external returns (address);
    function _DODO_SELL_HELPER_() view external returns (address);
    function _DPP_FACTORY_() view external returns (address);
    function _DVM_FACTORY_() view external returns (address);
    function _NEW_OWNER_() view external returns (address);
    function _OWNER_() view external returns (address);
    function _WETH_() view external returns (address);
    function addDVMLiquidity(address dvmAddress, uint256 baseInAmount, uint256 quoteInAmount, uint256 baseMinAmount, uint256 quoteMinAmount, uint8 flag, uint256 deadLine) payable external returns (uint256 shares, uint256 baseAdjustedInAmount, uint256 quoteAdjustedInAmount);
    function addLiquidityToV1(address pair, uint256 baseAmount, uint256 quoteAmount, uint256 baseMinShares, uint256 quoteMinShares, uint8 flag, uint256 deadLine) payable external returns (uint256 baseShares, uint256 quoteShares);
    function addWhiteList(address contractAddr) external;
    function bid(address cpAddress, uint256 quoteAmount, uint8 flag, uint256 deadLine) payable external;
    function claimOwnership() external;
    function createDODOPrivatePool(address baseToken, address quoteToken, uint256 baseInAmount, uint256 quoteInAmount, uint256 lpFeeRate, uint256 i, uint256 k, bool isOpenTwap, uint256 deadLine) payable external returns (address newPrivatePool);
    function createDODOVendingMachine(address baseToken, address quoteToken, uint256 baseInAmount, uint256 quoteInAmount, uint256 lpFeeRate, uint256 i, uint256 k, bool isOpenTWAP, uint256 deadLine) payable external returns (address newVendingMachine, uint256 shares);
    function dodoSwapV1(address fromToken, address toToken, uint256 fromTokenAmount, uint256 minReturnAmount, address[] memory dodoPairs, uint256 directions, bool, uint256 deadLine) payable external returns (uint256 returnAmount);
    function dodoSwapV2ETHToToken(address toToken, uint256 minReturnAmount, address[] memory dodoPairs, uint256 directions, bool, uint256 deadLine) payable external returns (uint256 returnAmount);
    function dodoSwapV2TokenToETH(address fromToken, uint256 fromTokenAmount, uint256 minReturnAmount, address[] memory dodoPairs, uint256 directions, bool, uint256 deadLine) external returns (uint256 returnAmount);
    function dodoSwapV2TokenToToken(address fromToken, address toToken, uint256 fromTokenAmount, uint256 minReturnAmount, address[] memory dodoPairs, uint256 directions, bool, uint256 deadLine) external returns (uint256 returnAmount);
    function externalSwap(address fromToken, address toToken, address approveTarget, address swapTarget, uint256 fromTokenAmount, uint256 minReturnAmount, bytes memory callDataConcat, bool, uint256 deadLine) payable external returns (uint256 returnAmount);
    function initOwner(address newOwner) external;
    function isWhiteListed(address) view external returns (bool);
    function mixSwap(address fromToken, address toToken, uint256 fromTokenAmount, uint256 minReturnAmount, address[] memory mixAdapters, address[] memory mixPairs, address[] memory assetTo, uint256 directions, bool, uint256 deadLine) payable external returns (uint256 returnAmount);
    function removeWhiteList(address contractAddr) external;
    function resetDODOPrivatePool(address dppAddress, uint256[] memory paramList, uint256[] memory amountList, uint8 flag, uint256 minBaseReserve, uint256 minQuoteReserve, uint256 deadLine) payable external;
    function transferOwnership(address newOwner) external;
}
