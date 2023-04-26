HW_SOURCE_FILE = __file__


def num_eights(n):
    """Returns the number of times 8 appears as a digit of n.

    >>> num_eights(3)
    0
    >>> num_eights(8)
    1
    >>> num_eights(88888888)
    8
    >>> num_eights(2638)
    1
    >>> num_eights(86380)
    2
    >>> num_eights(12345)
    0
    >>> num_eights(8782089)
    3
    >>> from construct_check import check
    >>> # ban all assignment statements
    >>> check(HW_SOURCE_FILE, 'num_eights',
    ...       ['Assign', 'AnnAssign', 'AugAssign', 'NamedExpr', 'For', 'While'])
    True
    """
    "*** YOUR CODE HERE ***"
    if n % 10 == 8 and n > 8:
        return num_eights(n // 10) + 1
    elif n == 8:
        return 1
    elif n < 8:
        return 0
    else:
        return num_eights(n // 10)


def pingpong(n):
    """Return the nth element of the ping-pong sequence.

    >>> pingpong(8)
    8
    >>> pingpong(10)
    6
    >>> pingpong(15)
    1
    >>> pingpong(21)
    -1
    >>> pingpong(22)
    -2
    >>> pingpong(30)
    -2
    >>> pingpong(68)
    0
    >>> pingpong(69)
    -1
    >>> pingpong(80)
    0
    >>> pingpong(81)
    1
    >>> pingpong(82)
    0
    >>> pingpong(100)
    -6
    >>> from construct_check import check
    >>> # ban assignment statements
    >>> check(HW_SOURCE_FILE, 'pingpong',
    ...       ['Assign', 'AnnAssign', 'AugAssign', 'NamedExpr'])
    True
    """
    "*** YOUR CODE HERE ***"

    # 普通方法/a way of using assignment statements and a while statement
    # turn = 1
    # i = 0
    # times = 1
    # while times <= n:
    #     if turn % 2 > 0:
    #         i += 1
    #     elif turn % 2 == 0:
    #         i -= 1
    #     if num_eights(times) > 0 or times % 8 == 0:
    #         turn += 1
    #     times += 1
    # return i
    """以下为递归方法"""

    # 递归实在想不出来了，订正：
    def helper(result, i, step):
        # 确实没想到i为n时的base case 可以这样定义
        if i == n:
            return result
        elif i % 8 == 0 or num_eights(i) > 0:
            return helper(result - step, i + 1, -step)
        else:
            return helper(result + step, i + 1, step)

    # 从最小向目标递归，方向直接在函数内靠result-step解决
    return helper(1, 1, 1)


# 碎碎念：我绕不出来啊啊啊啊啊啊啊啊啊


def next_larger_coin(coin):
    """Returns the next larger coin in order.
    >>> next_larger_coin(1)
    5
    >>> next_larger_coin(5)
    10
    >>> next_larger_coin(10)
    25
    >>> next_larger_coin(2) # Other values return None
    """
    if coin == 1:
        return 5
    elif coin == 5:
        return 10
    elif coin == 10:
        return 25


def next_smaller_coin(coin):
    """Returns the next smaller coin in order.
    >>> next_smaller_coin(25)
    10
    >>> next_smaller_coin(10)
    5
    >>> next_smaller_coin(5)
    1
    >>> next_smaller_coin(2) # Other values return None
    """
    if coin == 25:
        return 10
    elif coin == 10:
        return 5
    elif coin == 5:
        return 1


def count_coins(change):
    """Return the number of ways to make change using coins of value of 1, 5, 10, 25.
    >>> count_coins(15)
    6
    >>> count_coins(10)
    4
    >>> count_coins(20)
    9
    >>> count_coins(100) # How many ways to make change for a dollar?
    242
    >>> count_coins(200)
    1463
    >>> from construct_check import check
    >>> # ban iteration
    >>> check(HW_SOURCE_FILE, 'count_coins', ['While', 'For'])
    True
    """
    "*** YOUR CODE HERE ***"

    def count_par(change, coin):
        # 2、base case
        if change == 0:
            return 1
        elif change < 0:
            return 0
        elif coin == 1:
            return 1
        # 1、确认递归方式
        return count_par(change - coin, coin) + count_par(
            change, next_smaller_coin(coin)
        )

    # ⭐问题出在这：coin要确定为25，不能用if判断，否则就会出现int+none type的情况
    return count_par(change, 25)


"""以下为参考答案"""
# def count_small(change, largest_coin):
#     if change == 0:
#         return 1
#     elif change < 0:
#         return 0
#     # 这里，最后的情况是none
#     elif largest_coin == None:
#         return 0
#     without_coin = count_small(change, next_smaller_coin(largest_coin))
#     with_coin = count_small(change - largest_coin, largest_coin)
#     return without_coin + with_coin

# return count_small(change, 25)
