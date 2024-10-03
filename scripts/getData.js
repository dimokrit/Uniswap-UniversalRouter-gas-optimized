const ethers = require('ethers');

buildData = (v, tokenIn, tokenOut, pair, amountIn, amountOut) => {
    const tokenOutNo = ethers.BigNumber.from(tokenOut).lt(ethers.BigNumber.from(tokenIn)) ? 0 : 1;
    const data = ethers.utils.solidityPack(
      ["bytes8", "address", "address", "uint128", "uint128", "uint8"],
      [
        v,
        tokenIn,      // - token: address        - Address of the token you're swapping
        pair,         // - pair: address         - Univ2 pair
        amountIn,     // - amountIn: uint128     - Amount you're giving via swap
        amountOut,    // - amountOut: uint128    - Amount you're receiving via swap
        tokenOutNo,   // - tokenOutNo: uint8     - Is the token you're giving token0 or token1? (On univ2 pair)
      ]
    );
    return data;
  }

const data = buildData("0x0000000000000000",
    '0x8888888888888888888888888888888888888888',
    '0x7777777777777777777777777777777777777777',
    '0x6666666666666666666666666666666666666666',
    5,
    4
)

console.log('data:', data);
