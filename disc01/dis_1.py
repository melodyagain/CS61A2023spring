def is_prime(n):
    """ 
    >>> is_prime(10)
    False
    >>> is_prime(7)
    True
    >>> is_prime(1) # one is not a prime number!!
    False
    """
    "*** YOUR CODE HERE ***"

    if n == 1:
        return False
    else:
        k = 2
        while k < n:
            if n % k > 0:
                k += 1
            else:
                return False
        return True


# print(is_prime(7))


def wears_jacket_with_if(temp, raining):
    """
    >>> wears_jacket_with_if(90, False)
    False
    >>> wears_jacket_with_if(40, False)
    True
    >>> wears_jacket_with_if(100, True)
    True
    """
    "*** YOUR CODE HERE ***"

    return True if temp < 60 or raining else False


def fizzbuzz(n):
    """
    >>> result = fizzbuzz(16)
    1
    2
    fizz
    4
    buzz
    fizz
    7
    8
    fizz
    buzz
    11
    fizz
    13
    14
    fizzbuzz
    16
    >>> result is None  # No return value
    True
    """
    "*** YOUR CODE HERE ***"

    k = 1
    while k <= n:
        if k % 3 == 0 or k % 5 == 0:
            if k % 5 == 0 and k % 3 == 0:
                print("fizzbuzz")
            elif k % 3 == 0:
                print("fizz")
            else:
                print("buzz")
        else:
            print(k)
        k += 1


def unique_digits(n):
    """Return the number of unique digits in positive integer n.

    >>> unique_digits(8675309) # All are unique
    7
    >>> unique_digits(1313131) # 1 and 3
    2
    >>> unique_digits(13173131) # 1, 3, and 7
    3
    >>> unique_digits(10000) # 0 and 1
    2
    >>> unique_digits(101) # 0 and 1
    2
    >>> unique_digits(10) # 0 and 1
    2
    """
    "*** YOUR CODE HERE ***"
    unique = 0
    while n > 0:
        last = n % 10
        n = n//10
        if has_digit(n, last) == False:
            unique += 1
    return unique

    # if n < 10:
    #     return 1
    # else:
    #     # 每次取出一位数，和剩余的数比较，判断剩余数中有没有这个数。如果没有，则记1
    #     y = 1
    #     number = 0
    #     x = 0
    #     while x < n:
    #         # 取余，被取出的数
    #         x = n % (10**y)
    #         # 取整，单拎出这个数
    #         z = x//(10**(y-1))
    #         # 剩下的数
    #         other_digits = n//(10**y)
    #         # 判断
    #         if has_digit(other_digits, z) == False:
    #             number += 1
    #         y += 1
    # return number


def has_digit(n, k):
    """Returns whether K is a digit in N.
    >>> has_digit(10, 1)
    True
    >>> has_digit(12, 7)
    False
    """
    "*** YOUR CODE HERE ***"
# 方法一
    # # 判断n<10
    # if n < 10:
    #     return n-k == 0
    # # 判断n>=10
    # else:
    #     m = 1
    #     choose_digit = 0
    #     while choose_digit < n:
    #         # 已被选择的所有数字
    #         choose_digit = n % (10**m)
    #         # 每一位数逐一判断,向下取整
    #         a_digit = choose_digit // (10**(m-1))
    #         if a_digit-k == 0:
    #             return True
    #         m += 1
    #     return False
    while n > 0:
        last = n % 10
        n = n // 10
        if last-k == 0:
            return True
    return False
