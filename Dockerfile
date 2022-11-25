FROM node:10 as builder
WORKDIR /maputnik
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Only copy package.json to prevent npm install from running on every build
COPY package.json ./
RUN npm install

# Build maputnik
# TODO:  we should also do a   npm run test   here (needs more dependencies)
COPY . .
RUN npm run build

#---------------------------------------------------------------------------

# Create a clean python-based image with just the build results
FROM python:3-slim
WORKDIR /maputnik

COPY --from=builder /maputnik/build/build .

EXPOSE 8888
CMD python -m http.server 8888
