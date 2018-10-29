# cython: wraparound = False
# cython: boundscheck = False

from cpython cimport array
from cysignals.signals cimport sig_check


cpdef bint next_perm_cython_list(list l) except -1:
    """
    Obtain the next permutation under lex order of ``l``
    by mutating ``l``.
    """
    cdef Py_ssize_t n = len(l)
    if n < 2:
        return False

    # Starting from the end, find the first one such that
    #   l[one] < l[one+1]
    cdef Py_ssize_t one = n - 2
    while l[one] >= l[one+1]:
        one -= 1
        if one < 0:
            return False

    # Starting from the end, find the first j such that
    #   l[j] > l[one]
    cdef Py_ssize_t j = n - 1
    while l[j] <= l[one]:
        j -= 1

    # Swap positions one and j
    l[one], l[j] = l[j], l[one]

    # Reverse the list after one
    cdef Py_ssize_t left = one + 1, right = n - 1
    while left < right:
        l[left], l[right] = l[right], l[left]
        left += 1
        right -= 1

    return True

cpdef Py_ssize_t num_descents_cython_list(list l) except -1:
    cdef Py_ssize_t s = 0
    cdef Py_ssize_t i
    for i in range(len(l) - 1):
        s += l[i+1] < l[i]
    return s

def count_perm_by_descents_cython_list(n):
    cdef list res = [0] * n
    cdef list l = list(range(n))
    res[num_descents_cython_list(l)] += 1
    while next_perm_cython_list(l):
        sig_check()
        res[num_descents_cython_list(l)] += 1
    return res


cpdef bint next_perm_cython_array(array.array a) except -1:
    """
    Obtain the next permutation under lex order of ``a``
    by mutating ``a``.
    """
    cdef Py_ssize_t n = len(a)
    cdef unsigned int* l = a.data.as_uints
    if n < 2:
        return False

    # Starting from the end, find the first one such that
    #   l[one] < l[one+1]
    cdef Py_ssize_t one = n - 2
    while l[one] >= l[one+1]:
        one -= 1
        if one < 0:
            return False

    # Starting from the end, find the first j such that
    #   l[j] > l[one]
    cdef Py_ssize_t j = n - 1
    while l[j] <= l[one]:
        j -= 1

    # Swap positions one and j
    l[one], l[j] = l[j], l[one]

    # Reverse the list after one
    cdef Py_ssize_t left = one + 1, right = n - 1
    while left < right:
        l[left], l[right] = l[right], l[left]
        left += 1
        right -= 1

    return True

cpdef Py_ssize_t num_descents_cython_array(array.array l) except -1:
    cdef Py_ssize_t s = 0
    cdef Py_ssize_t i
    for i in range(len(l) - 1):
        s += l.data.as_uints[i+1] < l.data.as_uints[i]
    return s

def count_perm_by_descents_cython_array(n):
    cdef list res = [0] * n
    cdef array.array l = array.array('I', range(n))
    res[num_descents_cython_array(l)] += 1
    while next_perm_cython_array(l):
        sig_check()
        res[num_descents_cython_array(l)] += 1
    return res


cpdef bint next_perm_cython_memoryview(unsigned int[::1] l) except -1:
    """
    Obtain the next permutation under lex order of ``l``
    by mutating ``l``
    """
    cdef Py_ssize_t n = len(l)
    if n < 2:
        return False

    # Starting from the end, find the first one such that
    #   l[one] < l[one+1]
    cdef Py_ssize_t one = n - 2
    while l[one] >= l[one+1]:
        one -= 1
        if one < 0:
            return False

    # Starting from the end, find the first j such that
    #   l[j] > l[one]
    cdef Py_ssize_t j = n - 1
    while l[j] <= l[one]:
        j -= 1

    # Swap positions one and j
    l[one], l[j] = l[j], l[one]

    # Reverse the list after one
    cdef Py_ssize_t left = one + 1, right = n - 1
    while left < right:
        l[left], l[right] = l[right], l[left]
        left += 1
        right -= 1

    return True

cpdef Py_ssize_t num_descents_cython_memoryview(unsigned int[::1] l) except -1:
    cdef Py_ssize_t s = 0
    cdef Py_ssize_t i
    for i in range(len(l) - 1):
        s += l[i+1] < l[i]
    return s

def count_perm_by_descents_cython_memoryview(n):
    cdef list res = [0] * n
    l_arr = array.array('I', range(n))
    cdef unsigned int[::1] l = l_arr
    res[num_descents_cython_memoryview(l)] += 1
    while next_perm_cython_memoryview(l):
        sig_check()
        res[num_descents_cython_memoryview(l)] += 1
    return res
