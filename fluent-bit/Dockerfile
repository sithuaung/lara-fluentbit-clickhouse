FROM fluent/fluent-bit:latest

# Install dependencies needed for luarocks
USER root
RUN apk add --no-cache lua5.1-dev gcc musl-dev make luarocks

# Install lua-cjson
RUN luarocks --lua-version=5.1 install lua-cjson

# Switch back to fluent-bit user
USER fluent-bit