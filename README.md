# Eveyl

## Overview

A Rails app I created to experient with some of the Eve Online data sources:

* [Eve API](http://wiki.eve-id.net/API)
* [Eve Static Data Dump](http://wiki.eve-id.net/CCP_Static_Data_Dump)
* [Eve Central Order Data](http://eve-central.com/dumps)
* [Eve Data Market Relay](https://eve-market-data-relay.readthedocs.org/en/latest/)

Links:

* [Eve Online](http://www.eveonline.com/)
* [Wikipedia - Eve Online](http://en.wikipedia.org/wiki/Eve_Online)
* [Eve Development Network](http://wiki.eve-id.net/Main_Page)
* [Eve Central](http://eve-central.com)

## Current Functionality:

### Data Loading
  * Import a subset of the Eve Static Data Dump
  * Load nightly order data from Eve Central Dumps
  * Import real-time order data and history from EMDR (bandwidth/CPU intensive)
  * Load global and character specific data from the Eve API

### Order Stats
  * Calculate global/regional statistics from current order data:
    * Median Price
    * Mid Buy-Sell Price
    * Min/Max Buy Price
    * Weighted Average Price
    * Simulated 5% Buy/Sell
  * Estimate values (regional/global) for item types using the above statistics
  * Estimate material values (regional/global) for item types based on the above statistics
  * Track historical statistics per-region and globally
  * Allow statstics to be configured per-user for their display

### Views
  * Market Browser - Search by item name/region
    * Display all active orders matching the criteria (sorting by order fields)
    * Display historical price statistics (above) for each region
    * Display historical price data from EMDR, including interactive charts
    * Display history for each order, including price and volume changes

  * Display characters' assets with estimated sell and material value - useful for identifying what items to reprocess

  * Navigate regions/solar systems with data from the Eve API
    * Ship/Pod Kills/Jumps
    * Station data and ownership

  * Browse market groups to find items

  * Blueprints (in progress)
    * Calculate requirements for various research levels
    * Use the type values (above) to estimate the material cost and result value for items

  * In Progress
    * Character skill in training is displayed, but more detail would be useful
    * System sovereignty changes are tracked, but no display has been added
    * Basic Corporation displays work, but little detail
    * Code has been written to determine asteriods by security class, but this is not displayed

### API
A basic RESTful API was also written for retreiving data from the system.  This is used mainly for auto-complete and jQuery datatables.  More work needs to be done here.

## Rake Tasks

##### rake api:data
Sync with EVE API for active users (useful in a cron)

##### rake sde:import
Import data from the SDE (requires dump to be in SQLite3 format)

##### rake emdr:monitor
Monitor the EMDR feed for order data (Note that this can be a significant amount of data, requring both bandwidth and CPU)

##### rake eve_central:load_dump
Load an EVE Central nightly csv dump

##### rake orders:stats
Build stats based on the current order data (use after load_dump)

##### rake quality
Run [cane](https://github.com/square/cane) quality metrics

## Notes
I'd like to get an example application up on Heroku, but their free tier doesn't allow for enough rows

## License
Copyright (c) 2013 Brad Harrell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Credits
Brad Harrell: WrErase at gmail dot com
