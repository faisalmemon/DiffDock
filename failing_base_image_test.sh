#!/bin/bash

docker run --rm --gpus all   -e NVIDIA_DISABLE_REQUIRE=true   -v $(pwd)/pre_flight_checks/test_geometric.py:/test_geometric.py   ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v1   python /test_geometric.py
