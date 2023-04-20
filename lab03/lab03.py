from operator import add, mul

square = lambda x: x * x

identity = lambda x: x

triple = lambda x: 3 * x

increment = lambda x: x + 1


def ordered_digits(x):
    """Return True if the (base 10) digits of X>0 are in non-decreasing
    order, and False otherwise.

    >>> ordered_digits(5)
    True
    >>> ordered_digits(11)
    True
    >>> ordered_digits(127)
    True
    >>> ordered_digits(1357)
    True
    >>> ordered_digits(21)
    False
    >>> result = ordered_digits(1375) # Return, don't print
    >>> result
    False

    """
    "*** YOUR CODE HERE ***"
    if x < 10:
        return True
    else:
        # 最后一位
        digit = x % 10
        # 剩余全部数字
        other_digit = x // 10
        # 最后一位的前一位
        next_digit = other_digit % 10
        while other_digit > 0:
            if digit < next_digit:
                return False
            else:
                digit = other_digit % 10
                other_digit //= 10
                next_digit = other_digit % 10
        return True


def get_k_run_starter(n, k):
    """Returns the 0th digit of the kth increasing run within n.
    >>> get_k_run_starter(123444345, 0) # example from description
    3
    >>> get_k_run_starter(123444345, 1)
    4
    >>> get_k_run_starter(123444345, 2)
    4
    >>> get_k_run_starter(123444345, 3)
    1
    >>> get_k_run_starter(123412341234, 1)
    1
    >>> get_k_run_starter(1234234534564567, 0)
    4
    >>> get_k_run_starter(1234234534564567, 1)
    3
    >>> get_k_run_starter(1234234534564567, 2)
    2
    """
    # 1轮没做出来，复习注意。老想着调用上面的函数
    i = 0
    final = None
    while i <= k:
        while n > 10 and (n % 10) > ((n // 10) % 10):
            n //= 10
            # 是这里没弄清
        final = n % 10
        i = i + 1
        n = n // 10
    return final


def make_repeater(func, n):
    """Return the function that computes the nth application of func.

    >>> add_three = make_repeater(increment, 3)
    >>> add_three(5)
    8
    >>> make_repeater(triple, 5)(1) # 3 * 3 * 3 * 3 * 3 * 1
    243
    >>> make_repeater(square, 2)(5) # square(square(5))
    625
    >>> make_repeater(square, 4)(5) # square(square(square(square(5))))
    152587890625
    >>> make_repeater(square, 0)(5) # Yes, it makes sense to apply the function zero times!
    5
    """
    "*** YOUR CODE HERE ***"

    if n > 0:
        i = 3
        func1, func2 = func, func
        while i <= n:
            func2 = composer(func1, func2)
            composer(func1, func2)
            i += 1
        return composer(func1, func2)  # 比如这里可以直接返回func2
    else:
        # 如何使0次有意义？订正👇
        return identity

    # # ⭐写得太麻烦了，没有注意到identity函数。订正：
    # func2 = identity
    # while n > 0:
    #     func2 = composer(func, func2)
    #     n -= 1
    # # 订正2
    # return func2


def composer(func1, func2):
    """Return a function f, such that f(x) = func1(func2(x))."""

    def f(x):
        return func1(func2(x))

    return f


def apply_twice(func):
    """Return a function that applies func twice.

    func -- a function that takes one argument

    >>> apply_twice(square)(2)
    16
    """
    "*** YOUR CODE HERE ***"
    # 错误，没有写return
    # 知识点：
    # 不管 apply_twice 是否加上 return，
    # make_repeater 函数都会被调用并返回一个函数对象。
    # 但是，如果不加上 return，那么 apply_twice 的返回值将会是 None，而不是 make_repeater 函数返回的函数对象。
    # 因此，必须加上 return 来返回 make_repeater 函数返回的值，也就是 apply_twice 的返回值。
    return make_repeater(func, 2)


def div_by_primes_under(n):
    """
    >>> div_by_primes_under(10)(11)
    False
    >>> div_by_primes_under(10)(121)
    False
    >>> div_by_primes_under(10)(12)
    True
    >>> div_by_primes_under(5)(1)
    False
    """
    #     TypeError: 'int' object is not callable
    checker = lambda x: False
    i = 2
    while i < n:
        if not checker(i):
            # 订正:不太懂
            checker = (lambda f, i: lambda x: x % i == 0 or f(x))(checker, i)
            # checker = (lambda f, i: lambda x: x % i)(checker, i)
        i = i + 1
    return checker


def div_by_primes_under_no_lambda(n):
    """
    >>> div_by_primes_under_no_lambda(10)(11)
    False
    >>> div_by_primes_under_no_lambda(10)(121)
    False
    >>> div_by_primes_under_no_lambda(10)(12)
    True
    >>> div_by_primes_under_no_lambda(5)(1)
    False
    """

    def checker(x):
        i = 2
        while i < n:
            if x % i == 0:
                return True
            else:
                i += 1
        return False

    return checker

    # def checker(x):
    #     return False
    # i = 2
    # while i<=n:
    #     if not checker(i):
    #         def outer(____________________________):
    #             def inner(x):
    #                 return

    #             return ____________________________

    #         checker = ____________________________
    #     i = ____________________________
    # return ____________________________
