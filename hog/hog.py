"""The Game of Hog."""

from dice import six_sided, make_test_dice
from ucb import main, trace, interact
from math import log2

GOAL = 100  # The goal of Hog is to score 100 points.

######################
# Phase 1: Simulator #
######################


def roll_dice(num_rolls, dice=six_sided):
    """Simulate rolling the DICE exactly NUM_ROLLS > 0 times. Return the sum of
    the outcomes unless any of the outcomes is 1. In that case, return 1.

    num_rolls:  The number of dice rolls that will be made.
    dice:       A function that simulates a single dice roll outcome.
    """
    # These assert statements ensure that num_rolls is a positive integer.
    assert type(num_rolls) == int, "num_rolls must be an integer."
    assert num_rolls > 0, "Must roll at least once."
    # BEGIN PROBLEM 1
    "*** YOUR CODE HERE ***"
    i = 1
    totle = 0
    sad = 0
    while i <= num_rolls:
        # tips! 这里的m不能省
        m = dice()
        if m == 1:
            # 如果没有这里直接return，dice()直接停留在=1的时候，下一次循环则无法出现在正确的位置
            sad = 1
        else:
            totle += m
        i += 1
    if sad == 1:
        return 1
    else:
        return totle


# END PROBLEM 1


def tail_points(opponent_score):
    """Return the points scored by rolling 0 dice according to Pig Tail.

    opponent_score:   The total score of the other player.

    """
    # BEGIN PROBLEM 2
    "*** YOUR CODE HERE ***"
    ones = opponent_score % 10
    tens = (opponent_score // 10) % 10
    return 2 * abs(tens - ones) + 1
    # END PROBLEM 2


def take_turn(num_rolls, opponent_score, dice=six_sided):
    """Return the points scored on a turn rolling NUM_ROLLS dice when the
    opponent has OPPONENT_SCORE points.

    num_rolls:       The number of dice rolls that will be made.
    opponent_score:  The total score of the other player.
    dice:            A function that simulates a single dice roll outcome.
    """
    # Leave these assert statements here; they help check for errors.
    assert type(num_rolls) == int, "num_rolls must be an integer."
    assert num_rolls >= 0, "Cannot roll a negative number of dice in take_turn."
    assert num_rolls <= 10, "Cannot roll more than 10 dice."
    # BEGIN PROBLEM 3
    "*** YOUR CODE HERE ***"
    if num_rolls == 0:
        return tail_points(opponent_score)
    else:
        return roll_dice(num_rolls, dice)
    # END PROBLEM 3


def simple_update(num_rolls, player_score, opponent_score, dice=six_sided):
    """Return the total score of a player who starts their turn with
    PLAYER_SCORE and then rolls NUM_ROLLS DICE, ignoring Square Swine.
    """
    return player_score + take_turn(num_rolls, opponent_score, dice)


def square_update(num_rolls, player_score, opponent_score, dice=six_sided):
    """Return the total score of a player who starts their turn with
    PLAYER_SCORE and then rolls NUM_ROLLS DICE, *including* Square Swine.
    """
    score = player_score + take_turn(num_rolls, opponent_score, dice)
    if perfect_square(score):  # Implement perfect_square
        return next_perfect_square(score)  # Implement next_perfect_square
    else:
        return score


# BEGIN PROBLEM 4
"*** YOUR CODE HERE ***"


def perfect_square(score):
    # log2咋用啊
    """⭐这里的a是个浮点数，如何变成一个整型？"""
    """也可以用sqrt(score)"""
    a = score ** (1 / 2)
    return a % 1 == 0


def next_perfect_square(score):
    return int((score ** (1 / 2) + 1) ** 2)


# END PROBLEM 4


def always_roll_5(score, opponent_score):
    """A strategy of always rolling 5 dice, regardless of the player's score or
    the oppononent's score.
    """
    return 5


def play(strategy0, strategy1, update, score0=0, score1=0, dice=six_sided, goal=GOAL):
    """Simulate a game and return the final scores of both players, with
    Player 0's score first and Player 1's score second.

    E.g., play(always_roll_5, always_roll_5, square_update) simulates a game in
    which both players always choose to roll 5 dice on every turn and the Square
    Swine rule is in effect.

    A strategy function, such as always_roll_5, takes the current player's
    score and their opponent's score and returns the number of dice the current
    player chooses to roll.

    An update function, such as square_update or simple_update, takes the number
    of dice to roll, the current player's score, the opponent's score, and the
    dice function used to simulate rolling dice. It returns the updated score
    of the current player after they take their turn.

    strategy0: The strategy for player0.
    strategy1: The strategy for player1.
    update:    The update function (used for both players).
    score0:    Starting score for Player 0
    score1:    Starting score for Player 1
    dice:      A function of zero arguments that simulates a dice roll.
    goal:      The game ends and someone wins when this score is reached.
    """
    who = 0  # Who is about to take a turn, 0 (first) or 1 (second)
    # BEGIN PROBLEM 5
    "*** YOUR CODE HERE ***"
    # ⭐最大的问题出在dice没定义
    # 当前回合实际得分
    # this_turn = take_turn(num_rolls,score1,dice=six_sided)
    while score0 < goal and score1 < goal:
        if who == 0:
            who = 1
            # print(strategy0)
            # score0 = roll_dice(a, dice=six_sided)
            # update(a, score0, score1, dice=six_sided)
            # 这样子就可以解决整型的问题了？！艹
            num_rolls = strategy0(score0, score1)
            # 当前回合得分

            score0 = update(num_rolls, score0, score1, dice)
        else:
            who = 0
            # score1 = roll_dice(b, dice=six_sided)
            # update(b, score1, score0, dice=six_sided)
            num_rolls = strategy1(score1, score0)
            # score1 = roll_dice(num_rolls, dice=six_sided)
            score1 = update(num_rolls, score1, score0, dice)
    # END PROBLEM 5
    return score0, score1


#######################
# Phase 2: Strategies #
#######################

# a higher-order function


def always_roll(n):
    """Return a player strategy that always rolls N dice.

    A player strategy is a function that takes two total scores as arguments
    (the current player's score, and the opponent's score), and returns a
    number of dice that the current player will roll this turn.

    >>> strategy = always_roll(3)
    >>> strategy(0, 0)
    3
    >>> strategy(99, 99)
    3
    """
    assert n >= 0 and n <= 10
    # BEGIN PROBLEM 6
    "*** YOUR CODE HERE ***"

    # return n 错误，无法调用int对象
    # ❓错误，'NoneType' object is not callable
    # def always_roll_n(score0, score1):
    #     return n
    def always_roll_n(score0, score1):
        return n

    # ⭐订正：我的天,加一个这个就行.....
    # 知识点：闭包？
    return always_roll_n


# ❓错误
# def num_rolls(score0,score1):
#     t=always_roll()
# return n
# END PROBLEM 6


def catch_up(score, opponent_score):
    """A player strategy that always rolls 5 dice unless the opponent
    has a higher score, in which case 6 dice are rolled.

    >>> catch_up(9, 4)
    5
    >>> strategy(17, 18)
    6
    """
    if score < opponent_score:
        return 6  # Roll one more to catch up
    else:
        return 5


def is_always_roll(strategy, goal=GOAL):
    """Return whether strategy always chooses the same number of dice to roll.

    >>> is_always_roll(always_roll_5)
    True
    >>> is_always_roll(always_roll(3))
    True
    >>> is_always_roll(catch_up)
    False
    """
    # BEGIN PROBLEM 7
    "*** YOUR CODE HERE ***"
    # 错误：压根就没有执行strategy
    # 如何判断每一次？:循环总次数
    # i = 0
    # num_dices_1 = strategy
    # while i < goal**2:
    #     num_dices = strategy
    #     if num_dices_1 == num_dices:
    #         i += 1
    #     else:
    #         return False
    # return True
    score, opponent_score = 0, 0
    num_dices_1 = strategy(score, opponent_score)
    while score < goal:
        while opponent_score < goal:
            # 错误1：
            # 知识点：❓
            """num_dices = strategy:这种调用方式相当于⭐将 num_dice 赋值为函数 strategy 对象本身，并没有执行函数⭐。
            在后续代码中，如果需要执行 strategy 函数并获取其返回值，需要使用 () 来调用。
            num_dices = strategy(score, opponent_score)：这种调用方式会执行 strategy 函数，并将 score 和 opponent_score 作为参数传递给函数。
            函数内部可以根据参数的不同值，返回不同的结果，这个结果会被赋值给 num_dice 变量。
            num_dices = strategy()：这种调用方式会执行 strategy 函数，但是没有传递任何参数。
            函数内部可能会根据函数内部的默认行为或者固定的返回值，返回不同的结果，这个结果会被赋值给 num_dice 变量。"""
            # num_dices = strategy
            # ⭐订正为：
            num_dices = strategy(score, opponent_score)
            if num_dices_1 == num_dices:
                opponent_score += 1
            else:
                return False
        score += 1
        # 错误2：
        # 知识点：嵌套循环
        opponent_score = 0
    return True

    # END PROBLEM 7


def make_averaged(original_function, total_samples=1000):
    """Return a function that returns the average value of ORIGINAL_FUNCTION
    called TOTAL_SAMPLES times.

    To implement this function, you will have to use *args syntax.

    >>> dice = make_test_dice(4, 2, 5, 1)
    >>> averaged_dice = make_averaged(roll_dice, 40)
    >>> averaged_dice(1, dice)  # The avg of 10 4's, 10 2's, 10 5's, and 10 1's
    3.0
    """
    # BEGIN PROBLEM 8
    "*** YOUR CODE HERE ***"

    def function(*args):
        i = 0
        sum = 0
        while i < total_samples:
            # 错误1：dice() takes 0 positional arguments but 1 was given
            sum += original_function(*args)
            # nnd，居然忘记了写i
            i += 1
        return sum / total_samples

    # 错误2：如果直接变成function，会导致无限循环。但其实，这里删掉（），删掉（original_function）是非常正确的，否则就会导致错误1。
    return function

    # END PROBLEM 8


def max_scoring_num_rolls(dice=six_sided, total_samples=1000):
    """Return the number of dice (1 to 10) that gives the highest average turn score
    by calling roll_dice with the provided DICE a total of TOTAL_SAMPLES times.
    Assume that the dice always return positive outcomes.

    >>> dice = make_test_dice(1, 6)
    >>> max_scoring_num_rolls(dice)
    1
    """

    # BEGIN PROBLEM 9
    "*** YOUR CODE HERE ***"
    average_tern = 0
    i = 1
    # 错误原因：
    """
    >>> from hog import *
    >>> dice = make_test_dice(1, 2, 2, 2, 2, 2, 2, 2)
    >>> max_scoring_num_rolls(dice, total_samples=1000)
        10

    # Error: expected
    #     4
    # but got
    #     10"""
    while i <= 10:
        # 错误：'>' not supported between instances of 'function' and 'int'
        # 原因：内部含有函数的函数无法直接计算，所以不能作为一个值去运用
        # 错误范例2：
        """
        >>> dice = make_test_dice(6, 5, 4, 3, 2, 1)  # dice sweeps from 1 through 6
            ensure turn_sanples is being used 3
            # Error: expected
            #     4
            # but got
            #     3"""
        # 这里totak_samples是调用，不能赋值？
        average_tern_next = make_averaged(roll_dice, total_samples)
        t = average_tern_next(i, dice)
        if t > average_tern:
            average_tern = t
            max_turn = i
            i += 1
        else:
            i += 1
    return max_turn
    # END PROBLEM 9


def winner(strategy0, strategy1):
    """Return 0 if strategy0 wins against strategy1, and 1 otherwise."""
    score0, score1 = play(strategy0, strategy1, square_update)
    if score0 > score1:
        return 0
    else:
        return 1


def average_win_rate(strategy, baseline=always_roll(6)):
    """Return the average win rate of STRATEGY against BASELINE. Averages the
    winrate when starting the game as player 0 and as player 1.
    """
    win_rate_as_player_0 = 1 - make_averaged(winner)(strategy, baseline)
    win_rate_as_player_1 = make_averaged(winner)(baseline, strategy)

    return (win_rate_as_player_0 + win_rate_as_player_1) / 2


def run_experiments():
    """Run a series of strategy experiments and report results."""
    six_sided_max = max_scoring_num_rolls(six_sided)
    print("Max scoring num rolls for six-sided dice:", six_sided_max)

    print("always_roll(6) win rate:", average_win_rate(always_roll(6)))  # near 0.5
    print("catch_up win rate:", average_win_rate(catch_up))
    print("always_roll(3) win rate:", average_win_rate(always_roll(3)))
    print("always_roll(8) win rate:", average_win_rate(always_roll(8)))

    print("tail_strategy win rate:", average_win_rate(tail_strategy))
    print("square_strategy win rate:", average_win_rate(square_strategy))
    print("final_strategy win rate:", average_win_rate(final_strategy))
    "*** You may add additional experiments as you wish ***"


def tail_strategy(score, opponent_score, threshold=12, num_rolls=6):
    """This strategy returns 0 dice if Pig Tail gives at least THRESHOLD
    points, and returns NUM_ROLLS otherwise. Ignore score and Square Swine.
    """
    # BEGIN PROBLEM 10
    # 实际是拼写错误。
    # TypeError: tail_strategy() missing 1 required positional argument: 'opponent_score'
    if tail_points(opponent_score) >= threshold:
        return 0
    else:
        return num_rolls  # Remove this line once implemented.
    # END PROBLEM 10


def square_strategy(score, opponent_score, threshold=12, num_rolls=6):
    """This strategy returns 0 dice when your score would increase by at least threshold."""
    # BEGIN PROBLEM 11
    if tail_points(opponent_score) >= threshold:
        return 0
    else:
        # 错误订正！这里的num_rolls应该直接为0
        if square_update(0, score, opponent_score) - score >= threshold:
            return 0
        else:
            return num_rolls
    # END PROBLEM 11


def final_strategy(score, opponent_score):
    """Write a brief description of your final strategy.
    *** YOUR DESCRIPTION HERE ***
    分别扔0，1，2个筛子，看分数。
    任何得分高于6的，则认相应的筛子数。
    """
    # BEGIN PROBLEM 12
    return 6  # Remove this line once implemented.
    # END PROBLEM 12


##########################
# Command Line Interface #
##########################

# NOTE: The function in this section does not need to be changed. It uses
# features of Python not yet covered in the course.


@main
def run(*args):
    """Read in the command-line argument and calls corresponding functions."""
    import argparse

    parser = argparse.ArgumentParser(description="Play Hog")
    parser.add_argument(
        "--run_experiments", "-r", action="store_true", help="Runs strategy experiments"
    )

    args = parser.parse_args()

    if args.run_experiments:
        run_experiments()
