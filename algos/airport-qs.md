# Easy: Can Reach Destination
Problem: Given a list of flights `[src, dst]` and airports, determine if you can
reach the destination airport from the source airport via any number of connections.

```py3
def can_reach(flights: list[list[str]], src: str, dst: str) -> bool:
    ...

```
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

Solution design:
```py3

result_set = {
    "SEA": {"SFO"},
    "SFO": {"JFK"},
}

```