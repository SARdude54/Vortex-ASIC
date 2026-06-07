# Cache RTL Summary

## Introduction

## Cache RTL
- `VX_cache_cluster.sv` - Top level cache-bank/cache unit cluster wrapper. It takes requests from multiple core-sude inputs and distributes them across cache units. This module is Responsible for 3 major things:

    1. Core-side Arbitration
        * Groups requests by request lane.
        * Each request lane arbitrates `NUM_INPUTS` sources into `NUM_CACHES` cache units using `VX_mem_arb`
        * In this module, tags get expanded with arbitration-select bits so responses can route back to the correct source. 
    2. Cache unit instantiation
        * Instantiates `NUM_CACHES` copies of `VX_cache_wrap`.
        * Each cache unit produces `MEM_PORTS` memory-side ports.
        * Each cache unit produces `MEM_PORTS` memory-side ports.  
    3. Memory-side arbitration
        * Take memory requests from all cache units.
        * Arbitrates `NUM_CACHES` cache outputs down to the external `mem_bus_if[MEM_PORTS]`. 
        * Tags may be expanded so memory responses can be routed back to the right cache unit. 
- `VX_cache_wrap.sv` - Cache front-end wrapper. This modules decides whether requests go through the real cache or bypass it. 

    1. Bypass path:
        * `BYPASS_ENABLE = NC_ENABLE || PASSTHRU`.
        * Instantiates `VX_cache_bypass`.
        * Non-cacheable access is handled here such as IO accesses.
    2. Normal cache path
        * Instantiates `VX_cache`. 
        * Receives filtered/cacheable requests from `VX_cache_bypass` when bypass is enabled.
    3. Memory output selection
        * Merges cache/bypass outputs into the final memory bus
        * Applies read-only conversion for instruction caches using `ASSIGN_VX_MEM_BUS_RO_IF_FLAT_I` when `WRITE_ENABLE=0`. 

    * Data cache uses the bypass path for IO/non-cacheable memory
    * Instruction cache uses cache path unless paththrough is enabled

- `VX_cache_bypass.sv` - non-cacheable/passthrough request handler. This module is responsible for separating cacheable and non-cacheable requests. It also converts word-sized core requests into line-sized memory requests as well as merge bypass traffic with cache traffic. 
    1. Core requests switch
        * Using `VX_mem_switch.sv`, it splits `core_bus_in_if` into:
            * `core_bus_in_nc_if` - Non-cacheable path
            * `core_bus_in_nc_if` - cacheable path

        * Selection is based on:
             `core_req_nc_sel[i] = ~core_bus_in_if_req_data_flags[i][MEM_REQ_FLAG_IO];`
            * If `MEM_REQ_FLAG_IO` is set -> non-cacheable bypass path
            * Else cache path

    2. Non-cacheable request arbitration
        * Using `VX_mem_arb`, it arbitrates multple word-sized bypass requests down to `MEM_PORTS`
        * Converts `NUM_REQS` word requests to `MEM_PORTS` word requests. 
        * The tag is expanded so the respoinse can return to the correct orignal request lane.

    3. Word-to-line conversion
        * Converts a word request into a line-sized memory request. 
        * Ex: if WORD_SIZE = 16 bytes and LINE_SIZE = 64 bytes -> then WORDS_PER_LINE = 4
        * Bypass logic inserts the word into the correct word slot inside a full cache line-sized request. 
        * It stores the word-selected bits into the tag so the response can later extract the correct word

        * Word request:
            * addr = word address
            * data = one word
            * byteen = one word byte-enable

            Converts to:

        * Line request:
            * addr = line address
            * data = full line width where only one word slot is meaningful
            * byteen = full line byte-enable, only one word slot enabled
            * tag = original tag + word-selected bits

    4. Merge bypass and cache memory traffic
        * `mem_bus_out_src_if` -> `VX_mem_arb` -> `mem_bus_out_if`
        * This arbitrates bewtween non-cacheable bypass memory requests and cache-generated memory requests
        * When `CACHE_ENABLE=1`, there are two sources per memory port:
            * source 0 = bypass path
            * source 1 = cache path
        * Else, only bypass path exists.   

### Utility RTL
 
- `VX_mem_arb.sv` - This modules is responsible for handling memory bus arbitrations
    * Multiple input memory interfaces -> arbitration -> fewer output memory interfaces
    * Modifies tag when needed
    * If `NUM_INPUTS > NUM_OUTPUTS`, then several input ports are sharing fewer output ports, so the arbiter insert the selected input indedx into the tag: `original tag + arb select bits`
    * Then, it removes the those bits and routes the response back to the correct input on the response path

- `VX_mem_switch.sv` - This module will route requests based on an explcit select signal. It uses `bus_sel` to decide where each request should go. 
* Used in `VX_cache_bypass` to split requests into cacheable path to non-cacheable path. 