#!/bin/sh
cd "/home/yo/Desktop/code/llm/strata/Strata"
exec "/home/yo/Desktop/code/llm/strata/Strata/.venv/bin/python" "/home/yo/Desktop/code/llm/strata/Strata/serve/server.py" "--engine" "strata" "--config" "/home/yo/Desktop/code/llm/strata/Strata/strata-iq3_s.json" "--port" "8080" "--open"
