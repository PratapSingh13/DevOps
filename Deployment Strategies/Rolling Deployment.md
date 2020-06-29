# What are Rollig-Deployments ?
A rolling deployment is a deployment pattern (also known as an Incremental deployments, Batched deployments, or Ramped deployment) where new version is delivered, usually to one or more deployment targets at a time, untill all the targets have the updated version.

A typical process looks something like this:

* With two nodes running ```v1.0``` of your application, drain the first node to be updated, take it out of the load balancer pool and leave the remaining node to online to serve traffic.

![alt text](images/1.png "Title Text")
