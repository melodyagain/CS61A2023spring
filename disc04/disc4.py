def count_stair_ways(n):
    """Returns the number of ways to climb up a flight of
    n stairs, moving either 1 step or 2 steps at a time.
    >>> count_stair_ways(4)
    5
    """
    "*** YOUR CODE HERE ***"
    if n == 1:
        return 1
    elif n == 2:
        return 2
    return count_stair_ways(n - 1) + count_stair_ways(n - 2)


def count_k(n, k):
    """Counts the number of paths up a flight of n stairs
    when taking up to and including k steps at a time.
    >>> count_k(3, 3) # 3, 2 + 1, 1 + 2, 1 + 1 + 1
    4
    >>> count_k(4, 4)
    8
    >>> count_k(10, 3)
    274
    >>> count_k(300, 1) # Only one step at a time
    1
    """
    "*** YOUR CODE HERE ***"
    # if k == 1 or n == 1:
    #     return 1
    # elif n == 0:
    #     return 1
    # # return count_k(n, k - 1) + count_k(n - k, k) + (n - k + 1) * count_k(n - k, k - 1)
    # return (
    #     count_k(n, k - 1)
    #     + (n - k + 1) * count_k(n - k, k - 1)
    #     + count_k(n - k, k - 1)
    #     - (n - k + 1)
    # )
    # 以为不能用 while 的.......
    # 真的要严格限制时间了,超过2h没想出来的果断看答案
    if n == 0:
        return 1
    elif n < 0:
        return 0
    else:
        total = 0
        i = 1
        while i <= k:
            total += count_k(n - i, k)
            i += 1
        return total


def even_weighted_loop(s):
    """
    >>> x = [1, 2, 3, 4, 5, 6]
    >>> even_weighted_loop(x)
    [0, 6, 20]
    """
    "*** YOUR CODE HERE ***"
    res = []
    for i in range(len(s)):
        if i % 2 == 0:
            res = res + [s[i] * i]
    return res


def even_weighted_comprehension(s):
    """
    >>> x = [1, 2, 3, 4, 5, 6]
    >>> even_weighted_comprehension(x)
    [0, 6, 20]
    """
    return [s[i] * i for i in range(len(s)) if i % 2 == 0]


def max_product(s):
    """Return the maximum product that can be formed using
    non-consecutive elements of s.
    >>> max_product([10,3,1,9,2]) # 10 * 9
    90
    >>> max_product([5,10,5,10,5]) # 5 * 5 * 5
    125
    >>> max_product([])
    1
    """
    # 双重循环?
    # total=1
    # max=1
    # for i in range(len(s)):
    #     s[i]
    if s == []:
        return 1
    else:
        # 这个递归写得可太干净了
        return max(max_product(s[1:]), s[0] * max_product(s[2:]))
    """At each step, we choose if we want to include the current number in our product or not:
        If we include the current number, we cannot use the adjacent number.
        If we don't use the current number, we try the adjacent number (and obviously ignore the current number).
    The recursive calls represent these two alternate realities. Finally, we pick the one that gives us the largest product."""
