def falling(n, k):
    """Compute the falling factorial of n to depth k.

    >>> falling(6, 3)  # 6 * 5 * 4
    120
    >>> falling(4, 3)  # 4 * 3 * 2
    24
    >>> falling(4, 1)  # 4
    4
    >>> falling(4, 0)
    1
    """
    "*** YOUR CODE HERE ***"
    # 好乱啊aaaaa

    m = n-k+1
    accum = 1
    if k > 0:
        while n >= m:
            accum = accum*n
            n -= 1
        return accum
    else:
        return 1


# print('DEBUG:falling(6,3)的值是', falling(6, 3))


def divisible_by_k(n, k):
    """
    >>> a = divisible_by_k(10, 2)  # 2, 4, 6, 8, and 10 are divisible by 2
    2
    4
    6
    8
    10
    >>> a
    5
    >>> b = divisible_by_k(3, 1)  # 1, 2, and 3 are divisible by 1
    1
    2
    3
    >>> b
    3
    # There are no integers up to 6 divisible by 7
    >>> c = divisible_by_k(6, 7)
    >>> c
    0
    """
    "*** YOUR CODE HERE ***"
    m = 1
    b = 0
    if k > n:
        return b
    else:
        while n-m >= 0:
            if m % k == 0:
                print(m)
                m += 1
                b += 1
            else:
                m += 1
        return b


# print(divisible_by_k(3, 1))

# 深深理解，为什么报错比算错好多了！


def sum_digits(y):
    """Sum all the digits of y.

    >>> sum_digits(10) # 1 + 0 = 1
    1
    >>> sum_digits(4224) # 4 + 2 + 2 + 4 = 12
    12
    >>> sum_digits(1234567890)
    45
    # make sure that you are using return rather than print
    >>> a = sum_digits(123)
    >>> a
    6
    """
    "*** YOUR CODE HERE ***"
    # # 首先要知道y 一共有几位数

    # length = len("y")
    # 单独拆开每一位,从个位开始
    if y >= 10:
        # 个位特殊，单独计算
        a = 1
        t = y % 10
        yuanlaishu = t
        sum = t
        w = y
        while y-yuanlaishu > 0:
            # 第a位数
            a += 1
            w = w//10
            # 该位数是
            t = w % 10
            # 已算出的各位数原数
            yuanlaishu = t*(10**(a-1))+yuanlaishu
            # 相加
            sum = sum + t
        return sum
    # 只有1位
    else:
        return y


# print(sum_digits(1234567890))


def double_eights(n):
    """Return true if n has two eights in a row.
    >>> double_eights(8)
    False
    >>> double_eights(88)
    True
    >>> double_eights(2882)
    True
    >>> double_eights(880088)
    True
    >>> double_eights(12345)
    False
    >>> double_eights(80808080)
    False
    """
    "*** YOUR CODE HERE ***"
    # 和上一个似乎有相同的点
   # 单独拆开每一位,从个位开始
    if n >= 88:
        # 个位特殊，单独计算
        a = 1
        # 第一个个位数
        t = n % 10
        if t == 8:
            # 定义8的数量
            totle = 1
        else:
            totle = 0
        # 已判断的位数组成的数的和
        yuanlaishu = t
        # 剩余位数组成的数
        w = n
        while n-yuanlaishu > 0:
            # 第a位数
            a += 1
            w = w//10
            # 该位数是p,上一位数是t
            p = w % 10
            # 已算出的各位数原数
            yuanlaishu = p*(10**(a-1))+yuanlaishu
            if p / 8 == 1:  # 没有考虑到p是0
                if t == 8:
                    return True
            t = p
        return False
    # 只有1位
    else:
        return False


print(double_eights(88023))
