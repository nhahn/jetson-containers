#!/usr/bin/env python3
#
# Find a container image that's compatible with the requested package(s),
# either locally, built from source, or pulled from DockerHub.
#
# For example, you can use this to automatically run a package without tracking
# down yourself exactly which container image/tag to run:
#
#   $ sudo docker run --runtime nvidia -it --rm $(./autotag pytorch)
#   $ ./run.sh $(./autotag pytorch)   # shorthand for full 'docker run' command
#
# Or interspersed with more run arguments:
#
#   $ ./run.sh --volume /my/dir:/mount $(./autotag tensorflow2)
#   $ ./run.sh --volume /my/dir:/mount $(./autotag tensorflow2) /bin/bash -c 'some cmd'
#
# By default, the most-recent local image will be preferred - then DockerHub will be checked.
# If a compatible image isn't found on DockerHub, the user will be asked if they want to build it.
#
import os
import sys
import pprint
import argparse

from jetson_containers import (find_package, find_packages, find_container, L4T_VERSION, JETPACK_VERSION, CUDA_VERSION)
  
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    
    parser.add_argument('packages', type=str, nargs='*', default=[], help="package(s) to run (if multiple, a container with all)")
    
    parser.add_argument('-u', '--user', type=str, default='dustynv', help="the DockerHub user for registry container images")
    parser.add_argument('-o', '--output', type=str, default='/tmp/autotag', help="file to save the selected container tag to")
    parser.add_argument('-q', '--quiet', action='store_true')
    parser.add_argument('-v', '--verbose', action='store_true')
    
    args = parser.parse_args()
    print(args)
    
    print(f"-- L4T_VERSION={L4T_VERSION}")
    print(f"-- JETPACK_VERSION={JETPACK_VERSION}")
    print(f"-- CUDA_VERSION={CUDA_VERSION}")

    if len(args.packages) == 0:
        print(f"-- Error:  no packages were specified")
        sys.exit(127)
        
    print(f"-- Finding compatible container image for {args.packages}")
    
    image = find_container(args.packages[0], user=args.user, verbose=args.verbose)
    
    if not image:
        print(f"-- Error:  couldn't find a compatible container image for '{args.packages[0]}'")
        sys.exit(127)
        
    if args.output:
        with open(args.output, 'w') as file:
            file.write(image)
            
    print(image)