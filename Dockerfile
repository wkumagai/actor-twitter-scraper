# Dockerfile contains instructions how to build a Docker image that
# will contain all the code and configuration needed to run your actor.
# For a full Dockerfile reference,
# see https://docs.docker.com/engine/reference/builder/

# First, specify the base Docker image. Apify provides the following
# base images for your convenience:
#  apify/actor-node-basic (Node.js 10 on Alpine Linux, small and fast)
#  apify/actor-node-chrome (Node.js 10 + Chrome on Debian)
#  apify/actor-node-chrome-xvfb (Node.js 10 + Chrome + Xvfb on Debian)
# For more information, see https://apify.com/docs/actor#base-images
# Note that you can use any other image from Docker Hub.
# FROM apify/actor-node-chrome -> original version
FROM apify/actor-node:18

# Second, copy just package.json since it should be the only file
# that affects NPM install in the next step
COPY package.json ./

# --- ここを追加 ------------------------------
RUN apk add --no-cache python3 make g++
# --------------------------------------------

# Install NPM packages, skip optional and development dependencies to
# keep the image small. Avoid logging too much and print the dependency
# tree for debugging
RUN npm --quiet set progress=false \
 && npm install --only=prod --no-optional \
 && echo "Installed NPM packages:" \
 && npm list \
 && echo "Node.js version:" \
 && node --version \
 && echo "NPM version:" \
 && npm --version

# Next, copy the remaining files and directories with the source code.
# Since we do this after NPM install, quick build will be really fast
# for most source file changes.
COPY . ./

# Optionally, specify how to launch the source code of your actor.
# By default, Apify's base Docker images define the CMD instruction
# that runs the source code using the command specified
# in the "scripts.start" section of the package.json file.
# In short, the instruction looks something like this:
# CMD npm start
