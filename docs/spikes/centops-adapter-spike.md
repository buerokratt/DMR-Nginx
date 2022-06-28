# Introduction

This document outlines what we learnt in the spike [DMR: CentOps-to-NGINX converter [Spike]](https://github.com/buerokratt/DMR/issues/40)

## Background

DMR needs to keep its participant routing table up to date.
The single source of truth for participant information is CentOps, which makes this information available via a REST endpoint.
Consuming a REST endpoint and updating the routing table is not a problem for the .NET based DMR, but it is still unclear what would be the preferred way to do
this in Nginx based DMR where the participant routing table is stored as a configuration file.

## Spike goals

Figure out what are the possible solutions for updating DMR-Nginx participant routing table.

## Current situation

Participant routing is achieved via an upstream block in nginx configuration, e.g.

```
upstream Classifier {
    server 127.0.0.1:7140;
}

upstream MockBot {
    server 127.0.0.1:7285;
}
```

Updating this information requires modifying and reloading the nginx configuration file (`nginx -s reload`).

## Options
<style>
r { color: Red }
g { color: Green }
</style>

### Nginx Plus API
Nginx Plus has an API for modifying upstream configuration on-the-fly without reloading configuration or processes -
[Dynamic configuration API](https://docs.nginx.com/nginx/admin-guide/load-balancer/dynamic-configuration-api/)

+ <g>**No custom code**</g>: Production ready feature with commercial support.
+ <g>**No reload**</g>: Services and configuration does not need to be reloaded.

- <r>**Push based**</r>: Since configuration is managed during runtime, then how do we handle getting the configuration for initial startup?
- <r>**Subscription**</r>: Feature available only on paid version of Nginx.

### Custom Nginx module
There are already existing community provided custom modules that handle the same usecase that we have - updating upstream information
according to some external source.
E.g. [nginx-upsync-module](https://github.com/weibocom/nginx-upsync-module) that synchronizes with Consul or Etcd.
Depending on our requirements (authentication etc) we probably can not use an existing module and would need to create our own.

+ <g>**Nginx based solution**</g>: No external scripts or cron jobs required.
+ <g>**No reload**</g>: Services and configuration does not need to be reloaded.
+ <g>**Future extensibility**</g>: The sky is the limit.

- <r>**Custom code**</r>: Requires setting up pipelines for developing and publishing the module, need to provide support in the future.
- <r>**Out of comfort zone**</r>: Team has no experience with developing custom Nginx modules and the programming languages required for it.

### Custom adapter component
Create a custom adapter that queries participant information from CentOps and updates and reloads Nginx configuration.

+ <g>**Comfort zone**</g>: Can use technologies that team is already familiar with.

- <r>**Reload**</r>: Services and configuration needs to be reloaded for changes to take effect (Nginx is capable of doing a hot reload, but this still feels
  like an inferior solution).
- <r>**Complexity**</r>: Running a separate process/service for updating the configuration makes the overall solution more complex.

### Spike component
A quick spike was made that leverages .sh scripts (scheduled via cron) for querying participant information, writing it to files and reloading Nginx configuration.
The focus for the spike was on getting familiar with Nginx functionalities and therefore the solution (Custom adapter component) and technologies (scripts and cron) chosen for the spike were mainly due to time constraints and should not be used as a basis for determining the actual solution.

The spike did not take into consideration:
+ making sure that scheduled jobs do not overlap when the delay between cron jobs is smaller than time taken to run the job
+ updating only data that has changed (spike always overwrites all data)
+ authentication with CentOps
