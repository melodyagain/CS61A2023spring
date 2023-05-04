"""Typing test implementation"""

from utils import lower, split, remove_punctuation, lines_from_file
from ucb import main, interact, trace
from datetime import datetime


###########
# Phase 1 #
###########


def pick(paragraphs, select, k):
    """Return the Kth paragraph from PARAGRAPHS for which SELECT called on the
    paragraph returns True. If there are fewer than K such paragraphs, return
    the empty string.

    Arguments:
        paragraphs: a list of strings
        select: a function that returns True for paragraphs that can be selected
        k: an integer

    >>> ps = ['hi', 'how are you', 'fine']
    >>> s = lambda p: len(p) <= 4
    >>> pick(ps, s, 0)
    'hi'
    >>> pick(ps, s, 1)
    'fine'
    >>> pick(ps, s, 2)
    ''
    """
    # BEGIN PROBLEM 1
    "*** YOUR CODE HERE ***"
    selection = []
    for i in range(len(paragraphs)):
        if select(paragraphs[i]):
            # ⭐这里的错误要注意
            # selection += paragraphs[i]
            selection += [paragraphs[i]]
    if k > len(selection) - 1:
        return ""
    return selection[k]

    # END PROBLEM 1


def about(subject):
    """Return a select function that returns whether
    a paragraph contains one of the words in SUBJECT.

    Arguments:
        subject: a list of words related to a subject
    >>> about_dogs = about(['dog', 'dogs', 'pup', 'puppy'])
    >>> pick(['Cute Dog!', 'That is a cat.', 'Nice pup!'], about_dogs, 0)
    'Cute Dog!'
    >>> pick(['Cute Dog!', 'That is a cat.', 'Nice pup.'], about_dogs, 1)
    'Nice pup.'
    """
    assert all([lower(x) == x for x in subject]), "subjects should be lowercase."
    # BEGIN PROBLEM 2
    "*** YOUR CODE HERE ***"

    def select_from(paragraph):
        for i in range(len(subject)):
            # for k in range(len(paragraph)):
            # 可以直接判断dog in a dog吗？
            # 为什么有标点不行了
            """总结"""
            """split(),remove_punctuation(),lower()知识点缺失
            记得看一下这个文件utils.py: Utility functions for interacting with files and strings.
            救命，难怪说要仔细看所有描述。真是踩了前人所有的坑。
            """
            if subject[i] in split(remove_punctuation(lower(paragraph))):
                return True
        return False

    return select_from

    # END PROBLEM 2


def accuracy(typed, source):
    """Return the accuracy (percentage of words typed correctly) of TYPED
    when compared to the prefix of SOURCE that was typed.

    Arguments:
        typed: a string that may contain typos
        source: a string without errors

    >>> accuracy('Cute Dog!', 'Cute Dog.')
    50.0
    >>> accuracy('A Cute Dog!', 'Cute Dog.')
    0.0
    >>> accuracy('cute Dog.', 'Cute Dog.')
    50.0
    >>> accuracy('Cute Dog. I say!', 'Cute Dog.')
    50.0
    >>> accuracy('Cute', 'Cute Dog.')
    100.0
    >>> accuracy('', 'Cute Dog.')
    0.0
    >>> accuracy('', '')
    100.0
    """
    typed_words = split(typed)
    source_words = split(source)
    # BEGIN PROBLEM 3
    "*** YOUR CODE HERE ***"
    right = 0
    if typed == source == "":
        return 100.0
    elif typed == "" or source == "":
        return 0.0
    else:
        # don't repeat yourself
        for k in range(min(len(typed_words), len(source_words))):
            if typed_words[k] == source_words[k]:
                right += 1
    return right / len(typed_words) * 100
    # END PROBLEM 3


def wpm(typed, elapsed):
    """Return the words-per-minute (WPM) of the TYPED string.

    Arguments:
        typed: an entered string
        elapsed: an amount of time in seconds

    >>> wpm('hello friend hello buddy hello', 15)
    24.0
    >>> wpm('0123456789',60)
    2.0
    """
    assert elapsed > 0, "Elapsed time must be positive"
    # BEGIN PROBLEM 4
    "*** YOUR CODE HERE ***"
    k = len(typed)
    if k == 0:
        return 0.0
    else:
        return 60 / (elapsed / (k / 5))
    # END PROBLEM 4


###########
# Phase 2 #
###########


def autocorrect(typed_word, word_list, diff_function, limit):
    """Returns the element of WORD_LIST that has the smallest difference
    from TYPED_WORD. Instead returns TYPED_WORD if that difference is greater
    than LIMIT.

    Arguments:
        typed_word: a string representing a word that may contain typos
        word_list: a list of strings representing source words
        diff_function: a function quantifying the difference between two words
        limit: a number

    >>> ten_diff = lambda w1, w2, limit: 10 # Always returns 10
    >>> autocorrect("hwllo", ["butter", "hello", "potato"], ten_diff, 20)
    'butter'
    >>> first_diff = lambda w1, w2, limit: (1 if w1[0] != w2[0] else 0) # Checks for matching first char
    >>> autocorrect("tosting", ["testing", "asking", "fasting"], first_diff, 10)
    'testing'
    """
    # BEGIN PROBLEM 5
    "*** YOUR CODE HERE ***"
    res = []
    if typed_word in word_list:
        return typed_word
    for word in word_list:
        # if min(word_list, key=diff_function(typed_word, word_list, limit)) > limit:
        # 要注意,diff是参数,不能直接调用函数
        res += [diff_function(typed_word, word, limit)]
    if min(res) > limit:
        return typed_word
    else:
        # return min(word_list, key=diff_function(typed_word, word, limit))
        return min(word_list, key=lambda word: diff_function(typed_word, word, limit))


# END PROBLEM 5


def feline_fixes(typed, source, limit):
    """A diff function for autocorrect that determines how many letters
    in TYPED need to be substituted to create SOURCE, then adds the difference in
    their lengths and returns the result.

    Arguments:
        typed: a starting word
        source: a string representing a desired goal word
        limit: a number representing an upper bound on the number of chars that must change

    >>> big_limit = 10
    >>> feline_fixes("nice", "rice", big_limit)    # Substitute: n -> r
    1
    >>> feline_fixes("range", "rungs", big_limit)  # Substitute: a -> u, e -> s
    2
    >>> feline_fixes("pill", "pillage", big_limit) # Don't substitute anything, length difference of 3.
    3
    >>> feline_fixes("roses", "arose", big_limit)  # Substitute: r -> a, o -> r, s -> o, e -> s, s -> e
    5
    >>> feline_fixes("rose", "hello", big_limit)   # Substitute: r->h, o->e, s->l, e->l, length difference of 1.
    5
    """
    # BEGIN PROBLEM 6
    # assert False, "Remove this line"
    t = len(typed)
    s = len(source)
    """三个问题"""
    """1.如果需要计数,在递归的函数中需要增加count
       2.一直弄错了count的初始值,其实应该在调用最初的时候就写为0,属于是形参和实参的问题? 
       3.一直在想为什么这题一定要用递归?
            递归可以让问题的解决方式更加清晰、简洁，同时也可以提高程序的可读性和可维护性"""

    def judge(k, count):
        if count + abs(s - t) > limit:
            return limit + 1
        if k == 0 and typed[k] != source[k]:
            count += 1
            return 1
        elif k == 0 and typed[k] == source[k]:
            return 0
        elif typed[k] != source[k]:
            # count += 1
            return judge(k - 1, count + 1) + 1
        elif typed[k] == source[k]:
            return judge(k - 1, count)

    return judge(min(t, s) - 1, 0) + abs(s - t)

    # END PROBLEM 6


def minimum_mewtations(typed, source, limit):
    """A diff function that computes the edit distance from TYPED to SOURCE.
    This function takes in a string TYPED, a string SOURCE, and a number LIMIT.
    Arguments:
        typed: a starting word
        source: a string representing a desired goal word
        limit: a number representing an upper bound on the number of edits
    >>> big_limit = 10
    >>> minimum_mewtations("cats", "scat", big_limit)       # cats -> scats -> scat
    2
    >>> minimum_mewtations("ctas", "scat", big_limit)       # ctas -> sctas -> scaas ->scats ->scat
    4
    >>> minimum_mewtations("purng", "purring", big_limit)   # purng -> purrng -> purring
    2
    >>> minimum_mewtations("ckiteus", "kittens", big_limit) # ckiteus -> kiteus -> kitteus -> kittens
    3


    """

    # 替换和增加的计算方式不一样
    # 最小编辑策略
    # 太挫败了,完全没办法做到运算次数一致,绕不出来
    # assert False, "Remove this line"
    # BEGIN
    "*** YOUR CODE HERE ***"

    if (
        len(typed) == 0 or len(source) == 0
    ):  # Base cases should go here, you may add more base cases as needed.
        return min(len(typed) + len(source), limit + 1)
    # END
    # Recursive cases should go below here
    elif typed[0] == source[0]:  # Feel free to remove or add additional cases
        # BEGIN
        "*** YOUR CODE HERE ***"
        return min(minimum_mewtations(typed[1:], source[1:], limit), limit + 1)
        # END
    else:
        add = 1 + minimum_mewtations(typed, source[1:], limit)
        remove = 1 + minimum_mewtations(typed[1:], source, limit)
        substitute = 1 + minimum_mewtations(typed[1:], source[1:], limit)
    return min(add, remove, substitute, limit + 1)
    # BEGIN


# END


def final_diff(typed, source, limit):
    """A diff function that takes in a string TYPED, a string SOURCE, and a number LIMIT.
    If you implement this function, it will be used."""
    assert False, "Remove this line to use your final_diff function."


FINAL_DIFF_LIMIT = 6  # REPLACE THIS WITH YOUR LIMIT


###########
# Phase 3 #
###########


def report_progress(typed, prompt, user_id, upload):
    """Upload a report of your id and progress so far to the multiplayer server.
    Returns the progress so far.

    Arguments:
        typed: a list of the words typed so far
        prompt: a list of the words in the typing prompt
        user_id: a number representing the id of the current user
        upload: a function used to upload progress to the multiplayer server

    >>> print_progress = lambda d: print('ID:', d['id'], 'Progress:', d['progress'])
    >>> # The above function displays progress in the format ID: __, Progress: __
    >>> print_progress({'id': 1, 'progress': 0.6})
    ID: 1 Progress: 0.6
    >>> typed = ['how', 'are', 'you']
    >>> prompt = ['how', 'are', 'you', 'doing', 'today']
    >>> report_progress(typed, prompt, 2, print_progress)
    ID: 2 Progress: 0.6
    0.6
    >>> report_progress(['how', 'aree'], prompt, 3, print_progress)
    ID: 3 Progress: 0.2
    0.2
    """
    # BEGIN PROBLEM 8
    "*** YOUR CODE HERE ***"
    progress = 0
    if typed == [] or prompt == []:
        progress = 0.0
    for k in range(len(typed)):
        if typed[k] != prompt[k]:
            progress = k / len(prompt)
            break
        elif k + 1 == min(len(typed), len(prompt)):
            progress = (k + 1) / len(prompt)
            break
    d = {"id": user_id, "progress": progress}
    upload(d)
    return progress
    # return progress
    # END PROBLEM 8


def time_per_word(words, times_per_player):
    """Given timing data, return a match data abstraction, which contains a
    list of words and the amount of time each player took to type each word.

    Arguments:
        words: a list of words, in the order they are typed.
        times_per_player: A list of lists of timestamps including the time
                          the player started typing, followed by the time
                          the player finished typing each word.

    >>> p = [[75, 81, 84, 90, 92], [19, 29, 35, 36, 38]]
    >>> match = time_per_word(['collar', 'plush', 'blush', 'repute'], p)
    >>> get_all_words(match)
    ['collar', 'plush', 'blush', 'repute']
    >>> get_all_times(match)
    [[6, 3, 6, 2], [10, 6, 1, 2]]
    """
    # BEGIN PROBLEM 9
    "*** YOUR CODE HERE ***"
    # 嵌套循环
    times_per_word = []
    for i in range(len(times_per_player)):
        times_i_player = []
        for j in range(len(times_per_player[i]) - 1):
            times_i_player += [times_per_player[i][j + 1] - times_per_player[i][j]]
        times_per_word += [times_i_player]
    return match(words, times_per_word)
    # END PROBLEM 9


def fastest_words(match):
    """Return a list of lists of which words each player typed fastest.

    Arguments:
        match: a match data abstraction as returned by time_per_word.

    >>> p0 = [5, 1, 3]
    >>> p1 = [4, 1, 6]
    >>> fastest_words(match(['Just', 'have', 'fun'], [p0, p1]))
    [['have', 'fun'], ['Just']]
    >>> p0  # input lists should not be mutated
    [5, 1, 3]
    >>> p1
    [4, 1, 6]
    """
    player_indices = range(
        len(get_all_times(match))
    )  # contains an *index* for each player
    word_indices = range(len(get_all_words(match)))  # contains an *index* for each word
    # BEGIN PROBLEM 10
    "*** YOUR CODE HERE ***"
    # 从第j个字开始
    grade = [None] * len(get_all_times(match))
    for k in player_indices:
        grade[k] = []
    for j in word_indices:
        min_word_i = get_all_times(match)[0][j]
        word = get_all_words(match)[j]
        k = 0
        # 在每个玩家中挑出这个字最快的人
        for i in player_indices:
            if get_all_times(match)[i][j] < min_word_i:
                min_word_i = get_all_times(match)[i][j]
                word = get_all_words(match)[j]
                k = i
        grade[k] += [word]
    return grade

    # END PROBLEM 10


def match(words, times):
    """A data abstraction containing all words typed and their times.

    Arguments:
        words: A list of strings, each string representing a word typed.
        times: A list of lists for how long it took for each player to type
            each word.
            times[i][j] = time it took for player i to type words[j].

    Example input:
        words: ['Hello', 'world']
        times: [[5, 1], [4, 2]]
    """
    assert all([type(w) == str for w in words]), "words should be a list of strings"
    assert all([type(t) == list for t in times]), "times should be a list of lists"
    assert all(
        [isinstance(i, (int, float)) for t in times for i in t]
    ), "times lists should contain numbers"
    assert all(
        [len(t) == len(words) for t in times]
    ), "There should be one word per time."
    return {"words": words, "times": times}


def get_word(match, word_index):
    """A utility function that gets the word with index word_index"""
    assert (
        0 <= word_index < len(get_all_words(match))
    ), "word_index out of range of words"
    return get_all_words(match)[word_index]


def time(match, player_num, word_index):
    """A utility function for the time it took player_num to type the word at word_index"""
    assert word_index < len(get_all_words(match)), "word_index out of range of words"
    assert player_num < len(get_all_times(match)), "player_num out of range of players"
    return get_all_times(match)[player_num][word_index]


def get_all_words(match):
    """A selector function for all the words in the match"""
    return match["words"]


def get_all_times(match):
    """A selector function for all typing times for all players"""
    return match["times"]


def match_string(match):
    """A helper function that takes in a match data abstraction and returns a string representation of it"""
    return f"match({get_all_words(match)}, {get_all_times(match)})"


enable_multiplayer = True  # Change to True when you're ready to race.

##########################
# Command Line Interface #
##########################


def run_typing_test(topics):
    """Measure typing speed and accuracy on the command line."""
    paragraphs = lines_from_file("data/sample_paragraphs.txt")
    select = lambda p: True
    if topics:
        select = about(topics)
    i = 0
    while True:
        source = pick(paragraphs, select, i)
        if not source:
            print("No more paragraphs about", topics, "are available.")
            return
        print("Type the following paragraph and then press enter/return.")
        print("If you only type part of it, you will be scored only on that part.\n")
        print(source)
        print()

        start = datetime.now()
        typed = input()
        if not typed:
            print("Goodbye.")
            return
        print()

        elapsed = (datetime.now() - start).total_seconds()
        print("Nice work!")
        print("Words per minute:", wpm(typed, elapsed))
        print("Accuracy:        ", accuracy(typed, source))

        print("\nPress enter/return for the next paragraph or type q to quit.")
        if input().strip() == "q":
            return
        i += 1


@main
def run(*args):
    """Read in the command-line argument and calls corresponding functions."""
    import argparse

    parser = argparse.ArgumentParser(description="Typing Test")
    parser.add_argument("topic", help="Topic word", nargs="*")
    parser.add_argument("-t", help="Run typing test", action="store_true")

    args = parser.parse_args()
    if args.t:
        run_typing_test(args.topic)
