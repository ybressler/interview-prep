"""
Easy: Can Reach Destination
Problem: Given a list of flights [src, dst] and airports, determine if you can
reach the destination airport from the source airport via any number of connections.

def can_reach(flights: list[list[str]], src: str, dst: str) -> bool:
    ...

For example:
    >>> flights = [["SEA", "JFK"], ["SEA", "DEN"]]
    >>> can_reach(flights, src="SEA", dst="JFK")
    True  # Direct flight

    >>> flights = [["SEA", "SFO"], ["SFO", "JFK"]]
    >>> can_reach(flights, src="SEA", dst="JFK")
    True  # SEA -> SFO -> JFK

    >>> flights = [["SEA","SFO"], ["SFO","LAX"], ["LAX","JFK"], ["SEA","DEN"]]
    >>> can_reach(flights, src="SEA", dst="JFK")
    True  # SEA -> SFO -> LAX -> JFK

    >>> can_reach(flights, src="DEN", dst="JFK")
    False  # No path from DEN to JFK
"""
from dataclasses import dataclass
from collections import defaultdict, deque
import pytest


def can_reach(flights: list[list[str]], src: str, dst: str) -> bool:
    ...


@dataclass
class TestCanReach:
    flights: list[list[str]]
    src: str
    dst: str
    expected: bool
    description: str = ""


@pytest.mark.parametrize(
    "testcase",
    [
        TestCanReach(
            flights=[["SEA", "SFO"], ["SFO", "LAX"], ["LAX", "JFK"], ["SEA", "DEN"]],
            src="SEA",
            dst="JFK",
            expected=True,
            description="multi-hop path exists"
        ),
        TestCanReach(
            flights=[["SEA", "SFO"], ["SFO", "LAX"], ["LAX", "JFK"], ["SEA", "DEN"]],
            src="DEN",
            dst="JFK",
            expected=False,
            description="no path from isolated node"
        ),
        TestCanReach(
            flights=[["SEA", "SFO"], ["SFO", "SEA"]],
            src="SEA",
            dst="SEA",
            expected=True,
            description="src equals dst"
        ),
        TestCanReach(
            flights=[],
            src="SEA",
            dst="JFK",
            expected=False,
            description="empty graph"
        ),
        TestCanReach(
            flights=[["SEA", "SFO"], ["SFO", "SEA"], ["SFO", "LAX"]],
            src="SEA",
            dst="LAX",
            expected=True,
            description="graph with cycle"
        ),
    ],
    ids=lambda tc: tc.description
)
def test_can_reach(testcase: TestCanReach):
    assert can_reach(testcase.flights, testcase.src, testcase.dst) == testcase.expected





"""
Medium: Cheapest Flight Within K Stops
Problem: Given flights [src, dst, price], find the cheapest price from src to dst 
with at most k stops (k stops = k+1 flights). Return -1 if no such route exists.

def cheapest_flight(flights: list[list], src: str, dst: str, k: int) -> int:
    ...

For example:
>>> flights = [["SEA","SFO",100], ["SFO","JFK",200], ["SEA","DEN",50], ["DEN","JFK",300]]
>>> cheapest_flight(flights, src="SEA", dst="JFK", k=1)
300  # SEA -> SFO -> JFK (1 stop, cost 300) beats SEA -> DEN -> JFK (1 stop, cost 350)

>>> cheapest_flight(flights, src="SEA", dst="JFK", k=0)
-1   # No direct flight SEA -> JFK
"""
from dataclasses import dataclass
from collections import defaultdict, deque
import pytest


def cheapest_flight(flights: list[list], src: str, dst: str, k: int) -> int:
    ...


@dataclass
class TestCheapestFlight:
    flights: list[list]
    src: str
    dst: str
    k: int
    expected: int
    description: str = ""


@pytest.mark.parametrize(
    "testcase",
    [
        TestCheapestFlight(
            flights=[["SEA", "SFO", 100], ["SFO", "JFK", 200], ["SEA", "DEN", 50], ["DEN", "JFK", 300]],
            src="SEA",
            dst="JFK",
            k=1,
            expected=300,
            description="choose cheaper 1-stop route"
        ),
        TestCheapestFlight(
            flights=[["SEA", "SFO", 100], ["SFO", "JFK", 200], ["SEA", "DEN", 50], ["DEN", "JFK", 300]],
            src="SEA",
            dst="JFK",
            k=0,
            expected=-1,
            description="no direct flight"
        ),
        TestCheapestFlight(
            flights=[["SEA", "SFO", 100], ["SFO", "LAX", 50], ["LAX", "JFK", 50], ["SEA", "JFK", 500]],
            src="SEA",
            dst="JFK",
            k=2,
            expected=200,
            description="2-stop cheaper than direct"
        ),
        TestCheapestFlight(
            flights=[["SEA", "SFO", 100], ["SFO", "LAX", 50], ["LAX", "JFK", 50], ["SEA", "JFK", 500]],
            src="SEA",
            dst="JFK",
            k=1,
            expected=500,
            description="k too small for cheap route, must take direct"
        ),
        TestCheapestFlight(
            flights=[["A", "B", 10], ["B", "C", 10], ["C", "D", 10], ["A", "D", 100]],
            src="A",
            dst="D",
            k=2,
            expected=30,
            description="exactly k stops optimal"
        ),
        TestCheapestFlight(
            flights=[],
            src="SEA",
            dst="JFK",
            k=5,
            expected=-1,
            description="empty graph"
        ),
    ],
    ids=lambda tc: tc.description
)
def test_cheapest_flight(testcase: TestCheapestFlight):
    assert cheapest_flight(testcase.flights, testcase.src, testcase.dst, testcase.k) == testcase.expected