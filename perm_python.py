from six.moves import range

def next_perm_python(l):
    """
    Obtain the next permutation under lex order of ``l``
    by mutating ``l``.
    """
    n = len(l)

    if n <= 1:
        return False

    one = n - 2
    two = n - 1
    j   = n - 1

    # Starting from the end, find the first o such that
    #   l[o] < l[o+1]
    while two > 0 and l[one] >= l[two]:
        one -= 1
        two -= 1

    if two == 0:
        return False

    #starting from the end, find the first j such that
    #l[j] > l[one]
    while l[j] <= l[one]:
        j -= 1

    #Swap positions one and j
    t = l[one]
    l[one] = l[j]
    l[j] = t

    #Reverse the list between two and last
    #mset_list = mset_list[:two] + [x for x in reversed(mset_list[two:])]
    n -= 1 # In the loop, we only need n-1, so just do it once here
    for i in range((n+1 - two) // 2 - 1, -1, -1):
        t = l[i + two]
        l[i + two] = l[n - i]
        l[n - i] = t

    return True

def num_descents_python(l):
    s = 0
    for i in range(len(l)-1):
        s += l[i+1] < l[i]
    return s

def count_perm_by_descents_python(n):
    res = [0] * n
    l = list(range(n))
    res[num_descents_python(l)] += 1
    while next_perm_python(l):
        res[num_descents_python(l)] += 1
    return res
