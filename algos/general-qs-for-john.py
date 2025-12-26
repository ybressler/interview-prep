"""
Easy 1: Valid Sensor Readings
Problem: Given an array of sensor readings [timestamp, value] sorted by timestamp, return readings that are:
    - Within valid range [minVal, maxVal]
    - Not duplicates (same value within k milliseconds of previous valid reading)


```py3
def valid_readings(readings: list, minVal: int, maxVal: int, k: int):
    ...
```

For example:
```
    >>> readings = [[0,50],[5,50],[100,75],[105,200],[110,80]]
    >>> valid_readings(readings, minVal=0, maxVal=100, k=10)
    >>> [[0,50], [100,75], [110,80]]
```
"""
from dataclasses import dataclass
import pytest

def valid_readings(readings: list, minVal: int, maxVal: int, k: int):
    ...


@dataclass
class TestValidReadings:
    readings: list
    minVal: int
    maxVal: int
    k: int
    expected: list


@pytest.mark.parametrize(
    "testcase",
    [
        TestValidReadings(
            readings=[[0, 50], [5, 50], [100, 75], [105, 200], [110, 80]],
            minVal=0,
            maxVal=100,
            k=10,
            expected=[[0, 50], [100, 75], [110, 80]]
        )
    ]
)
def test_valid_readings(testcase: TestValidReadings):
    assert valid_readings(testcase.readings, testcase.minVal, testcase.maxVal, testcase.k) == testcase.expected


# If operating in a jupyter notebook:
for tc in [
        TestValidReadings(
            readings=[[0, 50], [5, 50], [100, 75], [105, 200], [110, 80]],
            minVal=0,
            maxVal=100,
            k=10,
            expected=[[0, 50], [100, 75], [110, 80]]
        )
    ]:
    result = valid_readings(tc.readings, tc.minVal, tc.maxVal, tc.k)
    assert result == tc.expected, f"Got {result}, expected {tc.expected}"
    print(f"✓ Passed")

# ---------------------------------------------------------------------------------------------------------

"""
# Easy 2: Sliding Window Sensor Average
Problem: Implement a class that processes a stream of sensor readings and returns the moving average of the last k readings.

```
MovingAverage(k=3)
    .next(10) → 10.0
    .next(20) → 15.0
    .next(30) → 20.0
    .next(40) → 30.0 
```
"""

class MovingAverage:
    def __init__(self, k: int):
        ...


    def next(self, val: int) -> float:
        ...


"""
Medium 1: Merge intervals...
"""

...



"""
Airport problem
"""