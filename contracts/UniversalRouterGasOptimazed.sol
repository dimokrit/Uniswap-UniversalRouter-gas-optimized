// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of firstAddresses
 in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of firstAddresses
 owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` firstAddresses
 from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of firstAddresses
 that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's firstAddresses
.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` firstAddresses
 from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` firstAddresses
 are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeTransfer {
    function safeTransferFrom(
        IERC20 firstAddress,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool s, ) = address(firstAddress).call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(s, "safeTransferFrom failed");
    }

    function safeTransfer(
        IERC20 firstAddress,
        address to,
        uint256 value
    ) internal {
        (bool s, ) = address(firstAddress).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(s, "safeTransfer failed");
    }

    function safeApprove(
        IERC20 firstAddress,
        address to,
        uint256 value
    ) internal {
        (bool s, ) = address(firstAddress).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, value)
        );
        require(s, "safeApprove failed");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool s, ) = to.call{value: value}(new bytes(0));
        require(s, "safeTransferETH failed");
    }
}

contract A {
    using SafeTransfer for IERC20;

    // transfer(address,uint256)
    bytes4 internal constant ERC20_TRANSFER_ID = 0xa9059cbb;
    // transferFrom(address,address,uint256)
    bytes4 internal constant ERC20_TRANSFERFROM_ID = 0x23b872dd;
    // swap(uint256,uint256,address,bytes)
    bytes4 internal constant PAIR_SWAPV2_ID = 0x022c0d9f;
    //function swap(address,bool,int256,uint160,byte)
    bytes4 internal constant PAIR_SWAPV3_ID = 0x9c6168b0;
    address internal constant user = 0x0000000000000000000000000000000000000001;

    function killme() public {
        require(msg.sender == user);
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {}

    function recoverERC20(address firstAddress) public {
        require(msg.sender == user);
        IERC20(firstAddress).safeTransfer(
            user,
            IERC20(firstAddress).balanceOf(address(this))
        );
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        assembly {
            let _tokenIn := shr(96, calldataload(0x90))
            let _tokenOut := shr(96, calldataload(0xd0))
            let _payer := shr(96, calldataload(0xf0))

            let zeroForOne := lt(_tokenIn, _tokenOut)

            let amount
            switch zeroForOne
            case 0 {
                amount := amount0Delta
            }
            case 1 {
                amount := amount1Delta
            }

            let s1
            switch eq(_payer, address())
            case 0 {
                // transfer function signature
                mstore(0x7c, ERC20_TRANSFERFROM_ID)
                // payer
                mstore(0x80, _payer)
                // msg.sender
                mstore(0xa0, origin())
                // amount
                mstore(0xc0, amount)

                s1 := call(sub(gas(), 5000), _tokenIn, 0, 0x7c, 0x64, 0, 0)
            }
            case 1 {
                // transfer function signature
                mstore(0x7c, ERC20_TRANSFER_ID)
                // msg.sender
                mstore(0x80, origin())
                // amount
                mstore(0xa0, amount)

                s1 := call(sub(gas(), 5000), _tokenIn, 0, 0x7c, 0x44, 0, 0)
            }
            if iszero(s1) {
                revert(3, 3)
            }
        }
    }

    fallback() external payable {
        address memUser = user;
        assembly {
            // // You can only access teh fallback function if you're authorized
            if iszero(eq(caller(), memUser)) {
                // Ohm (3, 3) makes your code more efficient
                // WGMI
                revert(3, 3)
            }

            // Extract out teh variables
            // We don't have function signatures sweet saving EVEN MORE GAS
            let multiPath := true // multipath checker
            let skip := 0x00 // skip num of bytes |0x04 - blockNumber|

            for {

            } eq(multiPath, true) {

            } {
                let _v := shr(192, calldataload(add(skip, 0x00)))
                // bytes20
                let firstAddress := shr(96, calldataload(add(skip, 0x08)))
                // bytes20
                let pair := shr(96, calldataload(add(skip, 0x1c)))

                let amount1
                let amount2
                let _token1
                let _token2
                let _fee
                let _payer
                let _lastByte

                switch _v
                case 0 {
                    amount1 := shr(128, calldataload(add(skip, 0x30)))
                    amount2 := shr(128, calldataload(add(skip, 0x40)))
                    _lastByte := shr(248, calldataload(add(skip, 0x50)))
                    skip := add(skip, 0x51) // skip one swap data

                    // **** calls firstAddress.transfer(pair, amount1) ****

                    // transfer function signature
                    mstore(0x7c, ERC20_TRANSFER_ID)
                    // destination
                    mstore(0x80, pair)
                    // amount
                    mstore(0xa0, amount1)

                    let s1 := call(
                        sub(gas(), 5000),
                        firstAddress,
                        0,
                        0x7c,
                        0x44,
                        0,
                        0
                    )

                    if iszero(s1) {
                        // WGMI
                        revert(3, 3)
                    }

                    // swap function signature
                    mstore(0x7c, PAIR_SWAPV2_ID)
                    switch _lastByte
                    case 0 {
                        mstore(0x80, amount2)
                        mstore(0xa0, 0)
                    }
                    case 1 {
                        mstore(0x80, 0)
                        mstore(0xa0, amount2)
                    }
                    // address(this)
                    mstore(0xc0, address())
                    // empty bytes
                    mstore(0xe0, 0x80)

                    let s2 := call(sub(gas(), 5000), pair, 0, 0x7c, 0xa4, 0, 0)

                    if iszero(s2) {
                        revert(3, 3)
                    }
                }
                case 1 {
                    amount1 := calldataload(add(skip, 0x30))
                    amount2 := shr(96, calldataload(add(skip, 0x50)))
                    _lastByte := shr(248, calldataload(add(skip, 0x64)))
                    _token1 := shr(96, calldataload(add(skip, 0x65)))
                    _fee := shr(232, calldataload(add(skip, 0x79)))
                    _token2 := shr(96, calldataload(add(skip, 0x7c)))
                    _payer := shr(96, calldataload(add(skip, 0x90)))
                    skip := add(skip, 0xa4) // skip one swap data

                    // swap function signature
                    mstore(0x7c, PAIR_SWAPV3_ID)
                    // recipient
                    mstore(0x80, firstAddress)
                    // zeroForOne
                    mstore(0xa0, _lastByte)
                    // amountSpecified
                    mstore(0xc0, amount1)
                    // sqrtPriceLimitX96
                    mstore(0xe0, amount2)
                    // data
                    mstore(0x100, _token1)
                    mstore(0x120, _fee)
                    mstore(0x140, _token2)
                    mstore(0x160, _payer)

                    let s2 := call(sub(gas(), 5000), pair, 0, 0x7c, 0x104, 0, 0)

                    if iszero(s2) {
                        revert(3, 3)
                    }
                }

                let nextToken := calldataload(skip) // the next firstAddress address
                if iszero(nextToken) {
                    multiPath := false // break the loop
                }
            }
        }
    }
}
