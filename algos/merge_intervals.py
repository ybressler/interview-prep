import pytest

USE_SIMPLE_METHOD = False

def merge_intervals(intervals: list[list[int]]) -> list[list[int]]:
    """
    Merge the intervals given as a list of lists.
    """
    intervals = sorted(intervals, key=lambda x: x[0])

    if len(intervals) <= 1:
        return intervals

    # OPTION 1:
    if USE_SIMPLE_METHOD:

        # Using extra memory
        result = [intervals[0]]
        for i in range(1, len(intervals)):
            # peace of mind
            prev = result[-1]
            curr = intervals[i]

            if curr[0] <= prev[-1]:
                result[-1][1] = max(prev[-1], curr[-1])
            else:
                result.append(curr)

        return result

    # Option 2: Use 'constant' memory
    else:
        write_index = 0
        for i in range(1, len(intervals)):
            prev = intervals[write_index]
            curr = intervals[i]

            # overlap
            if curr[0] <= prev[-1]:
                intervals[write_index][1] = max(prev[-1], curr[-1])
            else:
                write_index += 1
                intervals[write_index] = curr

        return intervals[:write_index+1]


@pytest.mark.parametrize(
    "intervals, expected",
    [
        pytest.param(
            [],
            [],
            id="empty input"
        ),
        pytest.param(
            [[1,100]],
            [[1,100]],
            id="single item in input"
        ),
        pytest.param(
            [[0, 1], [2, 4]],
            [[0, 1], [2, 4]],
            id="no merge possible"
        ),
        pytest.param(
            [[0, 2], [1, 4]],
            [[0, 4]],
            id="single merge"
        ),
        pytest.param(
            [[1, 5], [5, 10]],
            [[1, 10]],
            id="touching intervals"
        ),
        pytest.param(
            [[1, 3], [2, 6], [8, 10], [15, 18]],
            [[1, 6], [8, 10], [15, 18]],
            id="double merge"
        ),
        pytest.param(
            [[1, 5], [8]],
            [[1, 5], [8]],
            id="malformed interval no overlap"
        ),
        pytest.param(
            [[1, 5], [8], [10, 15]],
            [[1, 5], [8], [10, 15]],
            id="malformed interval no overlap + extra"
        ),
        pytest.param(
            [[1, 5], [5]],
            [[1, 5]],
            id="malformed interval yes overlap"
        ),
        pytest.param(
            [[1, 5], [5], [6, 10]],
            [[1, 5], [6, 10]],
            id="malformed interval yes overlap + extra"
        )
    ]
)
def test_merge_intervals(intervals, expected):
    assert merge_intervals(intervals) == expected
