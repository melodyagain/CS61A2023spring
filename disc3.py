
def merge(n1, n2):
    """ Merges two numbers by digit in decreasing order
    >>> merge(31, 42)
    4321
    >>> merge(21, 0)
    21
    >>> merge (21, 31) 
    3211
    """
    "*** YOUR CODE HERE ***"
    # 认真看题啊拜托......
    if n1==0:
        return n2
    elif n2==0:
        return n1
    elif n1%10<=n2%10:
        return merge(n1//10,n2)*10+n1%10
    else:
        return merge(n1,n2//10)*10+n2%10
    
    # 比较二者中最小的
    
    # def small(n):
    #     digit=n%10
    #     if digit==0:
    #         n=n//10
    #         return small(n)
    #     elif digit==n:
    #         return n
    #     else :
    #         return digit
    # if  small(n1)<=small(n2):
    #     # i+=1
    #     smallest=small(n1)*10
    #     # smallest=small(n1)*10(i-1)
    #     return merge(n1,n2)+smallest
    # else:
    #     smallest=small(n2)*10
    #     # smallest=small(n2)*10(i-1)
    #     return merge(n1,n2)+smallest
 
    
        

