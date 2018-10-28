from __future__ import print_function

from cpython cimport array
cimport cython

from cpython.object cimport PyObject

from cysignals.memory cimport sig_malloc, sig_free

cdef extern from "Python.h":
    void Py_INCREF(PyObject *)
    PyObject * PyInt_FromLong(long ival)
    list PyList_New(Py_ssize_t size)
    void PyList_SET_ITEM(list l, Py_ssize_t, PyObject *)
    PyObject * PyTuple_GET_ITEM(PyObject *op, Py_ssize_t i)


@cython.wraparound(False)
@cython.boundscheck(False)
cpdef bint next_perm_cython_list(list l):
    """
    Obtain the next permutation under lex order of ``l``
    by mutating ``l``.
    """
    cdef Py_ssize_t n = len(l)

    if n <= 1:
        return False

    cdef Py_ssize_t one = n - 2
    cdef Py_ssize_t two = n - 1
    cdef Py_ssize_t j   = n - 1
    cdef unsigned int t

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
    cdef Py_ssize_t i
    n -= 1 # In the loop, we only need n-1, so just do it once here
    for i in range((n+1 - two) // 2 - 1, -1, -1):
        t = l[i + two]
        l[i + two] = l[n - i]
        l[n - i] = t

    return True

@cython.wraparound(False)
@cython.boundscheck(False)
cpdef int num_descents_cython_list(list l):
    cdef int s = 0
    cdef int i
    for i in range(len(l)-1):
        s += l[i+1] < l[i]
    return s

@cython.wraparound(False)
@cython.boundscheck(False)
def count_perm_by_descents_cython_list(int n):
    cdef list res = [0] * n
    cdef list l = list(range(n))
    res[num_descents_cython_list(l)] += 1
    while next_perm_cython_list(l):
        res[num_descents_cython_list(l)] += 1
    return res

@cython.wraparound(False)
@cython.boundscheck(False)
cpdef bint next_perm_cython_array(array.array l):
    """
    Obtain the next permutation under lex order of ``l``
    by mutating ``l``.

    Algorithm based on:
    http://marknelson.us/2002/03/01/next-permutation/

    INPUT:

    - ``l`` -- array of unsigned int (i.e., type ``'I'``)

    .. WARNING::

        This method mutates the array ``l``.

    OUTPUT:

    boolean; whether another permutation was obtained

    EXAMPLES::

        sage: from sage.combinat.permutation_cython import next_perm
        sage: from array import array
        sage: L = array('I', [1, 1, 2, 3])
        sage: while next_perm(L):
        ....:     print(L)
        array('I', [1L, 1L, 3L, 2L])
        array('I', [1L, 2L, 1L, 3L])
        array('I', [1L, 2L, 3L, 1L])
        array('I', [1L, 3L, 1L, 2L])
        array('I', [1L, 3L, 2L, 1L])
        array('I', [2L, 1L, 1L, 3L])
        array('I', [2L, 1L, 3L, 1L])
        array('I', [2L, 3L, 1L, 1L])
        array('I', [3L, 1L, 1L, 2L])
        array('I', [3L, 1L, 2L, 1L])
        array('I', [3L, 2L, 1L, 1L])
    """
    cdef Py_ssize_t n = len(l)

    if n <= 1:
        return False

    cdef Py_ssize_t one = n - 2
    cdef Py_ssize_t two = n - 1
    cdef Py_ssize_t j   = n - 1

    # Starting from the end, find the first o such that
    #   l[o] < l[o+1]
    while two > 0 and l.data.as_uints[one] >= l.data.as_uints[two]:
        one -= 1
        two -= 1

    if two == 0:
        return False

    #starting from the end, find the first j such that
    #l[j] > l[one]
    while l.data.as_uints[j] <= l.data.as_uints[one]:
        j -= 1

    #Swap positions one and j
    cdef unsigned int t
    t = l.data.as_uints[one]
    l.data.as_uints[one] = l.data.as_uints[j]
    l.data.as_uints[j] = t

    #Reverse the list between two and last
    #mset_list = mset_list[:two] + [x for x in reversed(mset_list[two:])]
    n -= 1 # In the loop, we only need n-1, so just do it once here
    cdef Py_ssize_t i
    for i in range((n+1 - two) // 2 - 1, -1, -1):
        t = l.data.as_uints[i + two]
        l.data.as_uints[i + two] = l.data.as_uints[n - i]
        l.data.as_uints[n - i] = t

    return True

cpdef list map_to_list(array.array l, values, int n):
    """
    Build a list by mapping the array ``l`` using ``values``.

    .. WARNING::

        There is no check of the input data at any point. Using wrong
        types or values with wrong length is likely to result in a Sage
        crash.

    INPUT:

    - ``l`` -- array of unsigned int (i.e., type ``'I'``)
    - ``values`` -- tuple; the values of the permutation
    - ``n`` -- int; the length of the array ``l``

    OUTPUT:

    A list representing the permutation.

    EXAMPLES::

        sage: from array import array
        sage: from sage.combinat.permutation_cython import map_to_list
        sage: l = array('I', [0, 1, 0, 3, 3, 0, 1])
        sage: map_to_list(l, ('a', 'b', 'c', 'd'), 7)
        ['a', 'b', 'a', 'd', 'd', 'a', 'b']
    """
    cdef int i
    cdef list ret = PyList_New(n)
    cdef PyObject * t
    for i in range(n):
        t = PyTuple_GET_ITEM(<PyObject *> values, l.data.as_uints[i])
        Py_INCREF(t)
        PyList_SET_ITEM(ret, i, t)
    return ret

@cython.wraparound(False)
@cython.boundscheck(False)
cpdef int num_descents_cython_array(array.array l):
    cdef unsigned int s = 0
    cdef int i
    for i in range(len(l)-1):
        # if the call below is replaced by this line
        # s += l[i+1] < l[i]
        # then it is much slower than lists!!
        s += l.data.as_uints[i+1] < l.data.as_uints[i]
    return s

@cython.wraparound(False)
@cython.boundscheck(False)
def count_perm_by_descents_cython_array(int n):
    cdef list res = [0] * n
    cdef array.array l = array.array('I', range(n))
    res[num_descents_cython_array(l)] += 1
    while next_perm_cython_array(l):
        res[num_descents_cython_array(l)] += 1
    return res

