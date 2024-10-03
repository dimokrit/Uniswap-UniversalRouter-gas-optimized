const ethers = require('ethers');

buildData = (v, zeroForOne, recipient, pair, amountSpecified, sqrtPriceLimitX96, path, payer) => {
    const data = ethers.utils.solidityPack(
      ["bytes8", "address", "address", "int256", "uint160","bool", "bytes", "address"],
      [
        v,
        recipient,
        pair,
        amountSpecified,
        sqrtPriceLimitX96,     
        zeroForOne,
        path,
        payer
      ]
    );
    return data;
  }

const data = buildData(
    "0x0000000000000001",
    true,
    '0x8888888888888888888888888888888888888888',
    '0x7777777777777777777777777777777777777777',
    6,
    5,
    "0x44444444444444444444444444444444444444440000023333333333333333333333333333333333333333",
    "0x1111111111111111111111111111111111111111"
)

console.log('data:', data);
