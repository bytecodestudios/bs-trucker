# Truck Group JOb

A compact FiveM trucker job built around the Snappy Phone party system. This resource demonstrates how to wire party-based job progression, trailer delivery flow, payout handling, and target-driven job interactions into a practical legal job setup.

## Overview

This resource is designed as a reference implementation for using Snappy Phone party exports inside a custom job. It includes:

- Party-based job assignment and tracking
- Trailer request and replacement flow
- Delivery route generation and marker/zone logic
- Configurable payouts, XP rewards, and drop-off locations
- Framework bridge support for compatible FiveM ecosystems

## Features

- Multiple delivery job zones and trailer spawn points
- Dynamic trailer and route assignment using configurable drop locations
- Party-aware reward distribution and task progression
- `ox_lib` and `ox_target` interaction flow for a polished in-game experience

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [snappy-phone](https://snappy.tebex.io/category/phone)
- [cad-pedspawner](https://github.com/cadburry6969/cad-pedspawner)

## Installation

1. Place the resource in your server resources folder.
2. Ensure all dependencies are installed and started before this resource.
3. Configure the job and delivery settings in the shared config files as needed.
4. Start the resource in your server.cfg.

## Usage

Once loaded, the resource provides a job flow centered around requesting trailers, attaching a trailer, driving to a generated drop-off point, and completing the delivery through the in-game interaction zone.

## Notes

This project is primarily intended as a practical example for developers integrating cad-groupsystem orsSnappy-phone party exports into their own job resources.