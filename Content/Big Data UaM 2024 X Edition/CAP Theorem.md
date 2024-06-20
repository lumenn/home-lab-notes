
**C** - Consistency - Meaning every time we read data it's the most recent or we return an error.
**A** - Availability - Meaning that every request returns a response, but we don't guarantee it's most recent.
**P** - Partition Tolerance - Meaning that system works even when there is no access to all nodes of distributed system.

It states that when creating distributed data store only two from those three requirements are possible to achieve. System can be:
- Consistent and Available 
- Available and Partition Tolerant 
- Partition Tolerant and Consistent
But never all three at the same time.


# C
Assuming multiple copies of data - there might be a situation when on node X we have updated some data, but due to network (or any other) errors on node Y that data is not yet updated. System which guarantees consistency will always return correct data, or will throw an error.

# A
Available system will always return data, but it doesn't guarantee that it's the most recent one. So when we have different data on different nodes, then based on which one will be queried this data will be returned.

# P
To make sure that our system will work - we need to make copies of the data on multiple nodes of the distributed system in case any of those nodes will go off, this way we are achieving tolerance for errors.